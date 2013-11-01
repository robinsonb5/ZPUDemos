library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library work;
use work.zpu_config.all;
use work.zpupkg.ALL;
use work.DMACache_pkg.ALL;
use work.DMACache_config.ALL;

entity VirtualToplevel is
	generic (
		sdram_rows : integer := 12;
		sdram_cols : integer := 8;
		sysclk_frequency : integer := 1000; -- Sysclk frequency * 10
		vga_bits : integer := 4
	);
	port (
		clk 			: in std_logic;
		reset_in 	: in std_logic;

		-- VGA
		vga_red 		: out unsigned(vga_bits-1 downto 0);
		vga_green 	: out unsigned(vga_bits-1 downto 0);
		vga_blue 	: out unsigned(vga_bits-1 downto 0);
		vga_hsync 	: out std_logic;
		vga_vsync 	: buffer std_logic;
		vga_window	: out std_logic;

		-- SDRAM
		sdr_data		: inout std_logic_vector(15 downto 0);
		sdr_addr		: out std_logic_vector((sdram_rows-1) downto 0);
		sdr_dqm 		: out std_logic_vector(1 downto 0);
		sdr_we 		: out std_logic;
		sdr_cas 		: out std_logic;
		sdr_ras 		: out std_logic;
		sdr_cs		: out std_logic;
		sdr_ba		: out std_logic_vector(1 downto 0);
--		sdr_clk		: out std_logic;
		sdr_cke		: out std_logic;

		-- SPI signals
		spi_miso		: in std_logic := '1'; -- Allow the SPI interface not to be plumbed in.
		spi_mosi		: out std_logic;
		spi_clk		: out std_logic;
		spi_cs 		: out std_logic;
		
		-- UART
		rxd	: in std_logic;
		txd	: out std_logic;
		
		-- Audio
		audio_l : out signed(15 downto 0);
		audio_r : out signed(15 downto 0)
);
end entity;

architecture rtl of VirtualToplevel is

constant sysclk_hz : integer := sysclk_frequency*1000;
constant uart_divisor : integer := sysclk_hz/1152;

signal reset : std_logic := '0';
signal reset_counter : unsigned(15 downto 0) := X"FFFF";


-- Interrupt signals

constant int_max : integer := 1;
signal int_status : std_logic_vector(int_max downto 0);
signal int_ack : std_logic;
signal int_req : std_logic;
signal int_enabled : std_logic :='0'; -- Disabled by default


-- SPI Clock counter
signal spi_tick : unsigned(8 downto 0);
signal spiclk_in : std_logic;
signal spi_fast : std_logic;


-- SPI signals
signal host_to_spi : std_logic_vector(7 downto 0);
signal spi_to_host : std_logic_vector(31 downto 0);
signal spi_wide : std_logic;
signal spi_trigger : std_logic;
signal spi_busy : std_logic;
signal spi_active : std_logic;


-- UART signals

signal ser_txdata : std_logic_vector(7 downto 0);
signal ser_txready : std_logic;
signal ser_rxdata : std_logic_vector(7 downto 0);
signal ser_rxrecv : std_logic;
signal ser_txgo : std_logic;
signal ser_rxint : std_logic;

-- ZPU signals

signal mem_busy           : std_logic;
signal mem_read             : std_logic_vector(wordSize-1 downto 0);
signal mem_write            : std_logic_vector(wordSize-1 downto 0);
signal mem_addr             : std_logic_vector(maxAddrBitIncIO downto 0);
signal mem_writeEnable      : std_logic; 
signal mem_writeEnableh      : std_logic; 
signal mem_writeEnableb      : std_logic; 
signal mem_readEnable       : std_logic;

signal zpu_to_rom : ZPU_ToROM;
signal zpu_from_rom : ZPU_FromROM;


-- Plumbing between DMA controller and SDRAM

signal vga_addr : std_logic_vector(31 downto 0);
signal vga_data : std_logic_vector(15 downto 0);
signal vga_req : std_logic;
signal vga_fill : std_logic;
signal vga_refresh : std_logic;
signal vga_newframe : std_logic;
signal vga_reservebank : std_logic; -- Keep bank clear for instant access.
signal vga_reserveaddr : std_logic_vector(31 downto 0); -- to SDRAM

signal dma_data : std_logic_vector(15 downto 0);


-- Plumbing between VGA controller and DMA controller

signal vgachannel_fromhost : DMAChannel_FromHost;
signal vgachannel_tohost : DMAChannel_ToHost;
signal spr0channel_fromhost : DMAChannel_FromHost;
signal spr0channel_tohost : DMAChannel_ToHost;


-- Audio channel plumbing

signal aud0_fromhost : DMAChannel_FromHost;
signal aud0_tohost : DMAChannel_ToHost;
signal aud1_fromhost : DMAChannel_FromHost;
signal aud1_tohost : DMAChannel_ToHost;
signal aud2_fromhost : DMAChannel_FromHost;
signal aud2_tohost : DMAChannel_ToHost;
signal aud3_fromhost : DMAChannel_FromHost;
signal aud3_tohost : DMAChannel_ToHost;


-- VGA register block signals
signal vga_reg_rw : std_logic;
signal vga_reg_req : std_logic;
signal vga_ack : std_logic;
signal vblank_int : std_logic;

-- Audio register block signals
signal audio_reg_req : std_logic;

-- Timer register block signals
signal timer_reg_req : std_logic;
signal timer_tick : std_logic;


-- SDRAM signals
signal sdr_ready : std_logic;
signal sdram_write : std_logic_vector(31 downto 0); -- 32-bit width for ZPU
signal sdram_addr : std_logic_vector(31 downto 0);
signal sdram_req : std_logic;
signal sdram_wr : std_logic;
signal sdram_read : std_logic_vector(31 downto 0);
signal sdram_ack : std_logic;

signal sdram_wrL : std_logic;
signal sdram_wrU : std_logic;
signal sdram_wrU2 : std_logic;

type sdram_states is (read1, read2, read3, write1, writeb, write2, write3, idle);
signal sdram_state : sdram_states;


begin

sdr_cke <='1';


-- ROM

--	myrom : entity work.SDBootstrap_ROM
	myrom : entity work.RS232Bootstrap_ROM
	generic map
	(
		maxAddrBit => 13
	)
	port map (
		clk => clk,
		from_zpu => zpu_to_rom,
		to_zpu => zpu_from_rom
	);


-- Reset counter.

process(clk)
begin
	if reset_in='0' then
		reset_counter<=X"FFFF";
		reset<='0';
	elsif rising_edge(clk) then
		reset_counter<=reset_counter-1;
		if reset_counter=X"0000" then
			reset<='1';
		end if;
	end if;
end process;


-- UART

myuart : entity work.simple_uart
	generic map(
		enable_tx=>true,
		enable_rx=>true
	)
	port map(
		clk => clk,
		reset => reset, -- active low
		txdata => ser_txdata,
		txready => ser_txready,
		txgo => ser_txgo,
		rxdata => ser_rxdata,
		rxint => ser_rxint,
		txint => open,
		clock_divisor => to_unsigned(uart_divisor,16),
		rxd => rxd,
		txd => txd
	);


-- SPI Timer
process(clk)
begin
	if rising_edge(clk) then
		spiclk_in<='0';
		spi_tick<=spi_tick+1;
		if (spi_fast='1' and spi_tick(4)='1') or spi_tick(8)='1' then
			spiclk_in<='1'; -- Momentary pulse for SPI host.
			spi_tick<='0'&X"00";
		end if;
	end if;
end process;


-- SPI host
spi : entity work.spi_interface
	port map(
		sysclk => clk,
		reset => reset,

		-- Host interface
		spiclk_in => spiclk_in,
		host_to_spi => host_to_spi,
		spi_to_host => spi_to_host,
		wide => spi_wide,
		trigger => spi_trigger,
		busy => spi_busy,

		-- Hardware interface
		miso => spi_miso,
		mosi => spi_mosi,
		spiclk_out => spi_clk
	);


-- DMA controller

	mydmacache : entity work.DMACache
		port map(
			clk => clk,
			reset_n => reset,

			channels_from_host(0) => vgachannel_fromhost,
			channels_to_host(0) => vgachannel_tohost,
			
			channels_from_host(1) => spr0channel_fromhost,
			channels_to_host(1) => spr0channel_tohost,

			channels_from_host(2) => aud0_fromhost,
			channels_to_host(2) => aud0_tohost,
			channels_from_host(3) => aud1_fromhost,
			channels_to_host(3) => aud1_tohost,
			channels_from_host(4) => aud2_fromhost,
			channels_to_host(4) => aud2_tohost,
			channels_from_host(5) => aud3_fromhost,
			channels_to_host(5) => aud3_tohost,

			data_out => dma_data,

			-- SDRAM interface
			sdram_addr=> vga_addr,
			sdram_reserveaddr(31 downto 0) => vga_reserveaddr,
			sdram_reserve => vga_reservebank,
			sdram_req => vga_req,
			sdram_ack => vga_ack,
			sdram_fill => vga_fill,
			sdram_data => vga_data
		);

	
-- SDRAM
mysdram : entity work.sdram_simple
	generic map
	(
		rows => sdram_rows,
		cols => sdram_cols
	)
	port map
	(
	-- Physical connections to the SDRAM
		sdata => sdr_data,
		sdaddr => sdr_addr,
		sd_we	=> sdr_we,
		sd_ras => sdr_ras,
		sd_cas => sdr_cas,
		sd_cs	=> sdr_cs,
		dqm => sdr_dqm,
		ba	=> sdr_ba,

	-- Housekeeping
		sysclk => clk,
		reset => reset_in,  -- Contributes to reset, so have to use reset_in here.
		reset_out => sdr_ready,

		vga_addr => vga_addr,
		vga_data => vga_data,
		vga_fill => vga_fill,
		vga_req => vga_req,
		vga_ack => vga_ack,
		vga_refresh => vga_refresh,
		vga_reservebank => vga_reservebank,
		vga_reserveaddr => vga_reserveaddr,

		vga_newframe => vga_newframe,
		datawr1 => sdram_write,
		addr1 => sdram_addr,
		req1 => sdram_req,
		wr1 => sdram_wr, -- active low
		wrL1 => sdram_wrL, -- lower byte
		wrU1 => sdram_wrU, -- upper byte
		wrU2 => sdram_wrU2, -- upper halfword, only written on longword accesses
		dataout1 => sdram_read,
		dtack1 => sdram_ack
	);

	
-- VGA controller
-- Video
	
	myvga : entity work.vga_controller
		generic map (
			enable_sprite => false,
			vga_bits => vga_bits
		)
		port map (
		clk => clk,
		reset => reset,

		reg_addr_in => mem_addr(7 downto 0),
		reg_data_in => mem_write,
--		reg_data_out => vga_reg_dataout,
		reg_rw => vga_reg_rw,
		reg_req => vga_reg_req,

		sdr_refresh => vga_refresh,

		dma_data => dma_data,
		vgachannel_fromhost => vgachannel_fromhost,
		vgachannel_tohost => vgachannel_tohost,
		spr0channel_fromhost => spr0channel_fromhost,
		spr0channel_tohost => spr0channel_tohost,

		hsync => vga_hsync,
		vsync => vga_vsync,
		vblank_int => vblank_int,
		red => vga_red,
		green => vga_green,
		blue => vga_blue,
		vga_window => vga_window
	);


-- Audio controller

myaudio : entity work.sound_wrapper
  generic map(
		clk_frequency => sysclk_frequency -- Prescale incoming clock
  )
  port map (
		clk => clk,
		reset => reset,

		reg_addr_in => mem_addr(7 downto 0),
		reg_data_in => mem_write,
		reg_rw => '0', -- we never read from the timers
		reg_req => audio_reg_req,

		dma_data => dma_data,
		channel0_fromhost => aud0_fromhost,
		channel0_tohost => aud0_tohost,
		channel1_fromhost => aud1_fromhost,
		channel1_tohost => aud1_tohost,
		channel2_fromhost => aud2_fromhost,
		channel2_tohost => aud2_tohost,
		channel3_fromhost => aud3_fromhost,
		channel3_tohost => aud3_tohost,

		audio_l => audio_l,
		audio_r => audio_r
	);

	
-- Timer controller
	
mytimer : entity work.timer_controller
  generic map(
		prescale => sysclk_frequency, -- Prescale incoming clock
		timers => 0
  )
  port map (
		clk => clk,
		reset => reset,

		reg_addr_in => mem_addr(7 downto 0),
		reg_data_in => mem_write,
		reg_rw => '0', -- we never read from the timers
		reg_req => timer_reg_req,

		ticks(0) => timer_tick -- Tick signal is used to trigger an interrupt
	);

	
-- Interrupt controller

intcontroller: entity work.interrupt_controller
generic map (
	max_int => int_max
)
port map (
	clk => clk,
	reset_n => reset,
	trigger(0) => timer_tick,
	ack => int_ack,
	int => int_req,
	status => int_status
);

	
-- Main CPU

	zpu: zpu_core 
	generic map (
		IMPL_MULTIPLY => true,
		IMPL_COMPARISON_SUB => true,
		IMPL_EQBRANCH => true,
		IMPL_STOREBH => true,
		IMPL_LOADBH => true,
		IMPL_CALL => true,
		IMPL_SHIFT => true,
		IMPL_XOR => true,
		REMAP_STACK => true, -- We need to remap the Boot ROM / Stack RAM so we can access SDRAM
		EXECUTE_RAM => true, -- We might need to execute code from SDRAM, too.
		maxAddrBitBRAM => 13
	)
	port map (
		clk                 => clk,
		reset               => not reset,
		in_mem_busy         => mem_busy,
		mem_read            => mem_read,
		mem_write           => mem_write,
		out_mem_addr        => mem_addr,
		out_mem_writeEnable => mem_writeEnable,
		out_mem_hEnable     => mem_writeEnableh,
		out_mem_bEnable     => mem_writeEnableb,
		out_mem_readEnable  => mem_readEnable,
		from_rom => zpu_from_rom,
		to_rom => zpu_to_rom
	);


process(clk)
begin
	if reset='0' then
		spi_cs<='1';
		spi_active<='0';
	elsif rising_edge(clk) then
		mem_busy<='1';
		ser_txgo<='0';
		vga_reg_req<='0';
		audio_reg_req<='0';
		spi_trigger<='0';

		-- Write from CPU?
		if mem_writeEnable='1' then -- Write to top half of memory map?  Decode peripherals.
			case mem_addr(31)&mem_addr(10 downto 8) is
				when X"C" =>	-- Timer controller at 0xFFFFFC00
					timer_reg_req<='1';
					mem_busy<='0';	-- Timer controller never blocks the CPU
				when X"D" =>	-- Audio controller at 0xFFFFFD00
					audio_reg_req<='1';
					mem_busy<='0';	-- Audio controller never blocks the CPU
				when X"E" =>	-- VGA controller at 0xFFFFFE00
					vga_reg_rw<='0';
					vga_reg_req<='1';
					mem_busy<='0'; -- VGA controller never blocks the CPU
				when X"F" =>	-- Misc Peripherals at 0xFFFFFFF00
					case mem_addr(7 downto 0) is
						when X"B0" => -- Interrupts
							int_enabled<=mem_write(0);
							mem_busy<='0';

							when X"C0" => -- UART
							ser_txdata<=mem_write(7 downto 0);
							ser_txgo<='1';
							mem_busy<='0';

						when X"D0" => -- SPI CS
							spi_cs<=not mem_write(0);
							spi_fast<=mem_write(8);
							mem_busy<='0';

						when X"D4" => -- SPI Data
							spi_wide<='0';
							spi_trigger<='1';
							host_to_spi<=mem_write(7 downto 0);
							spi_active<='1';
						
						when X"D8" => -- SPI Pump (32-bit read)
							spi_wide<='1';
							spi_trigger<='1';
							host_to_spi<=mem_write(7 downto 0);
							spi_active<='1';

						when others =>
							mem_busy<='0';
							null;
					end case;
				when others => -- SDRAM
					sdram_wrL<=mem_writeEnableb and not mem_addr(0);
					sdram_wrU<=mem_writeEnableb and mem_addr(0);
					sdram_wrU2<=mem_writeEnableh or mem_writeEnableb; -- Halfword access
					if mem_writeEnableb='1' then
						sdram_state<=writeb;
					else
						sdram_state<=write1;
					end if;
			end case;

		elsif mem_readEnable='1' then -- Read from CPU?
			case mem_addr(31)&mem_addr(10 downto 8) is

				when X"F" =>	-- Misc Peripherals at 0xFFFFFFF00
					case mem_addr(7 downto 0) is
						when X"C0" => -- UART
							mem_read<=(others=>'X');
							mem_read(9 downto 0)<=ser_rxrecv&ser_txready&ser_rxdata;
							ser_rxrecv<='0';	-- Clear rx flag.
							mem_busy<='0';

						when X"D0" => -- SPI Status
							mem_read<=(others=>'X');
							mem_read(15)<=spi_busy;
							mem_busy<='0';

						when X"D4" => -- SPI read (blocking)
							spi_active<='1';

						when X"D8" => -- SPI wide read (blocking)
							spi_wide<='1';
							spi_trigger<='1';
							spi_active<='1';
							host_to_spi<=X"FF";

						when others =>
							mem_busy<='0';
							null;
					end case;

				when others => -- SDRAM
					sdram_state<=read1;
			end case;
		end if;
		
	-- SPI cycles

	if spi_active='1' and spi_busy='0' then
		mem_read<=spi_to_host;
		spi_active<='0';
		mem_busy<='0';
	end if;

	-- SDRAM state machine
	
		case sdram_state is
			when read1 => -- read first word from RAM
				sdram_addr<=mem_Addr;
				sdram_wr<='1';
				sdram_req<='1';
				if sdram_ack='0' then
					mem_read<=sdram_read;
					sdram_req<='0';
					sdram_state<=idle;
					mem_busy<='0';
				end if;
			when write1 => -- write 32-bit word to SDRAM
				sdram_addr<=mem_Addr;
				sdram_wr<='0';
				sdram_req<='1';
				sdram_write<=mem_write; -- 32-bits now
				if sdram_ack='0' then -- done?
					sdram_req<='0';
					sdram_state<=idle;
					mem_busy<='0';
				end if;
			when writeb => -- write 8-bit value to SDRAM
				sdram_addr<=mem_Addr;
				sdram_wr<='0';
				sdram_req<='1';
				sdram_write<=mem_write; -- 32-bits now
				sdram_write(15 downto 8)<=mem_write(7 downto 0); -- 32-bits now
				if sdram_ack='0' then -- done?
					sdram_req<='0';
					sdram_state<=idle;
					mem_busy<='0';
				end if;
			when others =>
				null;

		end case;

		-- Set this after the read operation has potentially cleared it.
		if ser_rxint='1' then
			ser_rxrecv<='1';
		end if;

	end if; -- rising-edge(clk)

end process;
	
end architecture;

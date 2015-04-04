library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.zpupkg.ALL;
use work.DMACache_pkg.ALL;
use work.DMACache_config.ALL;

entity VirtualToplevel is
	generic (
		sdram_rows : integer := 12;
		sdram_cols : integer := 8;
		sysclk_frequency : integer := 1000 -- Sysclk frequency * 10
	);
	port (
		clk 			: in std_logic;
		reset_in 	: in std_logic;

		-- VGA
		vga_red 		: out unsigned(7 downto 0);
		vga_green 	: out unsigned(7 downto 0);
		vga_blue 	: out unsigned(7 downto 0);
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
		
		-- TFT signals
		tft_miso	: in std_logic;
		tft_mosi : out std_logic;
		tft_cs : out std_logic;
		tft_sck : out std_logic;
		tft_d_c : out std_logic;
		tft_led : out std_logic;
		tft_reset : out std_logic;

		-- Touchscreen signals
		ts_miso : in std_logic;
		ts_mosi : out std_logic;
		ts_cs : out std_logic;
		ts_sck : out std_logic;
		ts_irq : in std_logic;
		
		-- UART
		rxd	: in std_logic;
		txd	: out std_logic;
		
		-- AUDIO
		audio_l : out signed(15 downto 0);
		audio_r : out signed(15 downto 0)
);
end entity;

architecture rtl of VirtualToplevel is

constant sysclk_hz : integer := sysclk_frequency*1000;
constant uart_divisor : integer := sysclk_hz/1152;

signal reset : std_logic := '0';
signal reset_counter : unsigned(15 downto 0) := X"FFFF";

-- Millisecond counter
signal millisecond_counter : unsigned(31 downto 0) := X"00000000";
signal millisecond_tick : unsigned(19 downto 0);


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

-- TFT SPI signals
signal tft_host_to_spi : std_logic_vector(7 downto 0);
signal tft_spi_to_host : std_logic_vector(31 downto 0);
signal tft_spi_wide : std_logic;
signal tft_spi_trigger : std_logic;
signal tft_spi_busy : std_logic;
signal tft_spi_active : std_logic;
signal tft_spiclk_in : std_logic;

signal tft_dma : std_logic;
signal tft_dma_data : std_logic_vector(15 downto 0);
signal tft_even : std_logic;
signal tft_pending : std_logic;


-- Touchscreen SPI signals
signal ts_host_to_spi : std_logic_vector(7 downto 0);
signal ts_spi_to_host : std_logic_vector(31 downto 0);
signal ts_spi_trigger : std_logic;
signal ts_spi_busy : std_logic;
signal ts_spi_active : std_logic;
signal ts_spiclk_in : std_logic;


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
signal mem_addr             : std_logic_vector(31 downto 0);
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


-- VGA register block signals

signal vga_reg_addr : std_logic_vector(11 downto 0);
signal vga_reg_dataout : std_logic_vector(15 downto 0);
signal vga_reg_datain : std_logic_vector(15 downto 0);
signal vga_reg_rw : std_logic;
signal vga_reg_req : std_logic;
signal vga_reg_dtack : std_logic;
signal vga_ack : std_logic;
signal vblank_int : std_logic;


-- Interrupt signals

constant int_max : integer := 0;
signal int_triggers : std_logic_vector(int_max downto 0);
signal int_status : std_logic_vector(int_max downto 0);
signal int_ack : std_logic;
signal int_req : std_logic;
signal int_enabled : std_logic :='0'; -- Disabled by default
signal int_trigger : std_logic;


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
audio_l <= X"0000";
audio_r <= X"0000";

-- ROM

	myrom : entity work.RS232Bootstrap_ROM
--	myrom : entity work.SDBootstrap_ROM
	generic map
	(
		maxAddrBitBRAM => 13
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


-- Timer
process(clk)
begin
	if rising_edge(clk) then
		millisecond_tick<=millisecond_tick+1;
		if millisecond_tick=sysclk_frequency*100 then
			millisecond_counter<=millisecond_counter+1;
			millisecond_tick<=X"00000";
		end if;
		-- Generate refresh pulse
		vga_refresh<='0';
		vga_newframe<=millisecond_counter(4); -- Save current value for edge detection
		if millisecond_counter(4)='1' and vga_newframe='0' then
			vga_refresh<='1';
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
		
		tft_spiclk_in<=not tft_spiclk_in;
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
		trigger => spi_trigger,
		busy => spi_busy,

		-- Hardware interface
		miso => spi_miso,
		mosi => spi_mosi,
		spiclk_out => spi_clk
	);

-- Secondary SPI host for TFT ( FIXME - merge these!)
tft_spi : entity work.spi_interface
	port map(
		sysclk => clk,
		reset => reset,

		-- Host interface
		spiclk_in => tft_spiclk_in,
		host_to_spi => tft_host_to_spi,
		spi_to_host => tft_spi_to_host,
		trigger => tft_spi_trigger,
		busy => tft_spi_busy,

		-- Hardware interface
		miso => tft_miso,
		mosi => tft_mosi,
		spiclk_out => tft_sck
	);
	

-- Tertiary SPI host for Touchscreen ( FIXME - merge these!)
ts_spi : entity work.spi_interface
	port map(
		sysclk => clk,
		reset => reset,

		-- Host interface
		spiclk_in => spiclk_in,
		host_to_spi => ts_host_to_spi,
		spi_to_host => ts_spi_to_host,
		trigger => ts_spi_trigger,
		busy => ts_spi_busy,

		-- Hardware interface
		miso => ts_miso,
		mosi => ts_mosi,
		spiclk_out => ts_sck
	);


-- DMA controller

	mydmacache : entity work.DMACache
		port map(
			clk => clk,
			reset_n => reset,

			channels_from_host(0) => vgachannel_fromhost,
			channels_from_host(1) => spr0channel_fromhost,
			
			channels_to_host(0) => vgachannel_tohost,
			channels_to_host(1) => spr0channel_tohost,

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

-- Interrupt controller

intcontroller: entity work.interrupt_controller
generic map (
	max_int => int_max
)
port map (
	clk => clk,
	reset_n => reset,
	trigger => int_triggers, -- Again, thanks ISE.
	ack => int_ack,
	int => int_req,
	status => int_status
);

int_trigger<=int_req and int_enabled;
	
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

	
-- Main CPU

	zpu: zpu_core_flex
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
		interrupt			  => int_trigger, -- Thanks, ISE.  int_req and int_enabled,
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
		tft_cs<='1';
		tft_spi_active<='0';
		tft_dma<='0';
		ts_spi_active<='0';
		ts_cs<='1';
		int_enabled<='0';
	elsif rising_edge(clk) then
		mem_busy<='1';
		ser_txgo<='0';
		vga_reg_req<='0';
		spi_trigger<='0';
		tft_spi_trigger<='0';
		ts_spi_trigger<='0';
		vgachannel_fromhost.setaddr<='0';
		vgachannel_fromhost.setreqlen<='0';
		vgachannel_fromhost.req<='0';

		int_ack<='0';
		int_triggers(0)<='0';

		
		if tft_pending='1' then
			vgachannel_fromhost.req<='1';	
			tft_pending<='0';
		end if;

		if vgachannel_tohost.valid='1' then
			tft_dma<='1';
			tft_dma_data<=dma_data;
			tft_even<='0';
		end if;
		
		-- Handle TFT DMA
		if tft_dma='1' and tft_spi_busy='0' then
			if tft_even='1' then
				tft_host_to_spi<=tft_dma_data(7 downto 0);
				tft_spi_trigger<='1';
				tft_even<='0';
				tft_dma<='0';
				if vgachannel_tohost.done='1' then
					int_triggers(0)<='1';
				else
					vgachannel_fromhost.req<='1';
				end if;
			else
				tft_host_to_spi<=tft_dma_data(15 downto 8);
				tft_spi_trigger<='1';
				tft_even<='1';
			end if;
		end if;

	
		-- Write from CPU?
		if mem_writeEnable='1' then
			case mem_addr(31)&mem_addr(10 downto 8) is
				when X"E" =>	-- VGA controller at 0xFFFFFE00
					vga_reg_rw<='0';
					vga_reg_req<='1';
					mem_busy<='0';
				when X"F" =>	-- Peripherals at 0xFFFFFFF00
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

						when X"E0" => -- TFT control
							tft_cs <= mem_write(0);
							tft_d_c <= mem_write(1);
							tft_reset <= mem_write(2);
							tft_led <= mem_write(3);
							mem_busy<='0';
						
						when X"E4" => -- TFT SPI
							tft_spi_active<='1';
							tft_spi_trigger<='1';
							tft_host_to_spi<=mem_write(7 downto 0);

						when X"E8" => -- TFT Framebuffer address
							vgachannel_fromhost.addr<=mem_write;
							vgachannel_fromhost.setaddr<='1';
							mem_busy<='0';
							
						when X"EC" => -- TFT Framebuffer size
							vgachannel_fromhost.reqlen<=unsigned(mem_write(DMACache_ReqLenMaxBit downto 0));
							vgachannel_fromhost.setreqlen<='1';
							tft_pending<='1';
							mem_busy<='0';

						when X"F0" => -- Touchscreen control
							ts_cs <= mem_write(0);
							mem_busy<='0';
						
						when X"F4" => -- Touchscreen SPI
							ts_spi_active<='1';
							ts_spi_trigger<='1';
							ts_host_to_spi<=mem_write(7 downto 0);

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

				when X"F" =>	-- Peripherals
					case mem_addr(7 downto 0) is

						when X"B0" => -- Interrupt
							mem_read<=(others=>'X');
							mem_read(int_max downto 0)<=int_status;
							int_ack<='1';
							mem_busy<='0';

						when X"C0" => -- UART
							mem_read<=(others=>'X');
							mem_read(9 downto 0)<=ser_rxrecv&ser_txready&ser_rxdata;
							ser_rxrecv<='0';	-- Clear rx flag.
							mem_busy<='0';
							
						when X"C8" => -- Millisecond counter
							mem_read<=std_logic_vector(millisecond_counter);
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

						when X"F0" => -- Touchscreen SPI control
							mem_read<=(others=>'X');
							mem_read(0)<=ts_spi_busy;
							mem_read(1)<=ts_irq;
							mem_busy<='0';
							
						when X"F4" => -- Touschreen SPI read (blocking)
							ts_spi_active<='1';

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

	if tft_spi_active='1' and tft_spi_busy='0' then
		mem_read<=tft_spi_to_host;
		tft_spi_active<='0';
		mem_busy<='0';
	end if;

	if ts_spi_active='1' and ts_spi_busy='0' then
		mem_read<=ts_spi_to_host;
		ts_spi_active<='0';
		mem_busy<='0';
	end if;
	
	-- SDRAM state machine
	
		case sdram_state is
			when read1 => -- read first word from RAM
				sdram_addr<=mem_Addr;
				sdram_wr<='1';
				sdram_req<='1';
				if sdram_ack='0' then
					if mem_WriteEnableh='1' then -- halfword read						
						mem_read(31 downto 16) <= (others=>'0');
						mem_read(15 downto 0)<=sdram_read(31 downto 16);
					elsif mem_WriteEnableb='1' then -- Byte read
						mem_read(31 downto 8) <= (others=>'0');
						if mem_Addr(0)='0' then -- even address
							mem_read(7 downto 0)<=sdram_read(31 downto 24);
						else
							mem_read(7 downto 0)<=sdram_read(23 downto 16);
						end if;
					else
						mem_read<=sdram_read;
					end if;
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

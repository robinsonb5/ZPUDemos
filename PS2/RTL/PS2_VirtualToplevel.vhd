library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.zpupkg.ALL;

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

		-- PS/2 signals
		ps2k_clk_in : in std_logic := '1';
		ps2k_dat_in : in std_logic := '1';
		ps2k_clk_out : out std_logic;
		ps2k_dat_out : out std_logic;
		ps2m_clk_in : in std_logic := '1';
		ps2m_dat_in : in std_logic := '1';
		ps2m_clk_out : out std_logic;
		ps2m_dat_out : out std_logic;

		-- UART
		rxd	: in std_logic;
		txd	: out std_logic;
		
		-- Sound
		audio_l : out signed(15 downto 0);
		audio_r : out signed(15 downto 0)
);
end entity;

architecture rtl of VirtualToplevel is

constant sysclk_hz : integer := sysclk_frequency*1000;
constant uart_divisor : integer := sysclk_hz/1152;
constant maxAddrBit : integer := 31;

signal reset : std_logic := '0';
signal reset_counter : unsigned(15 downto 0) := X"FFFF";

-- UART signals

signal ser_txdata : std_logic_vector(7 downto 0);
signal ser_txready : std_logic;
signal ser_rxdata : std_logic_vector(7 downto 0);
signal ser_rxrecv : std_logic;
signal ser_txgo : std_logic;
signal ser_rxint : std_logic;

-- Interrupt signals

constant int_max : integer := 1;
signal int_triggers : std_logic_vector(int_max downto 0);
signal int_status : std_logic_vector(int_max downto 0);
signal int_ack : std_logic;
signal int_req : std_logic;
signal int_enabled : std_logic :='0'; -- Disabled by default
signal int_trigger : std_logic;


-- PS2 signals
signal ps2_int : std_logic;

signal ps2k_clk_db : std_logic;
signal ps2m_clk_db : std_logic;

signal kbdidle : std_logic;
signal kbdrecv : std_logic;
signal kbdrecvreg : std_logic;
signal kbdsendbusy : std_logic;
signal kbdsendtrigger : std_logic;
signal kbdsenddone : std_logic;
signal kbdsendbyte : std_logic_vector(7 downto 0);
signal kbdrecvbyte : std_logic_vector(10 downto 0);

signal mouseidle : std_logic;
signal mouserecv : std_logic;
signal mouserecvreg : std_logic;
signal mousesendbusy : std_logic;
signal mousesenddone : std_logic;
signal mousesendtrigger : std_logic;
signal mousesendbyte : std_logic_vector(7 downto 0);
signal mouserecvbyte : std_logic_vector(10 downto 0);


-- Timer register block signals
signal timer_reg_req : std_logic;
signal timer_tick : std_logic;

-- ZPU signals

signal mem_busy           : std_logic;
signal mem_read             : std_logic_vector(wordSize-1 downto 0);
signal mem_write            : std_logic_vector(wordSize-1 downto 0);
signal mem_addr             : std_logic_vector(maxAddrBit downto 0);
signal mem_writeEnable      : std_logic; 
signal mem_writeEnableh      : std_logic; 
signal mem_writeEnableb      : std_logic; 
signal mem_readEnable       : std_logic;

signal zpu_to_rom : ZPU_ToROM;
signal zpu_from_rom : ZPU_FromROM;

begin

audio_l <= X"0000";
audio_r <= X"0000";
sdr_cke <='0'; -- Disable SDRAM for now
sdr_cs <='1'; -- Disable SDRAM for now


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

-- PS2 devices

	mykeyboard : entity work.io_ps2_com
		generic map (
			clockFilter => 15,
			ticksPerUsec => 100
		)
		port map (
			clk => clk,
			reset => not reset, -- active high!
			ps2_clk_in => ps2k_clk_in,
			ps2_dat_in => ps2k_dat_in,
			ps2_clk_out => ps2k_clk_out,
			ps2_dat_out => ps2k_dat_out,
			
			inIdle => open,	-- Probably don't need this
			sendTrigger => kbdsendtrigger,
			sendByte => kbdsendbyte,
			sendBusy => kbdsendbusy,
			sendDone => kbdsenddone,
			recvTrigger => kbdrecv,
			recvByte => kbdrecvbyte
		);

--ps2m_db: entity work.Debounce
--	generic map(
--		bits => 4
--	)
--	port map(
--	clk => clk,
--	signal_in => ps2m_clk_in,
--	signal_out => ps2m_clk_db
--);
--

	mymouse : entity work.io_ps2_com
		generic map (
			clockFilter => 15,
			ticksPerUsec => sysclk_frequency/10
		)
		port map (
			clk => clk,
			reset => not reset, -- active high!
			ps2_clk_in => ps2m_clk_in,
			ps2_dat_in => ps2m_dat_in,
			ps2_clk_out => ps2m_clk_out,
			ps2_dat_out => ps2m_dat_out,
			
			inIdle => open,	-- Probably don't need this
			sendTrigger => mousesendtrigger,
			sendByte => mousesendbyte,
			sendBusy => mousesendbusy,
			sendDone => mousesenddone,
			recvTrigger => mouserecv,
			recvByte => mouserecvbyte
		);
	
	
-- Hello World ROM

	myrom : entity work.PS2_ROM
	generic map
	(
		maxAddrBitBRAM => 12
	)
	port map (
		clk => clk,
		from_zpu => zpu_to_rom,
		to_zpu => zpu_from_rom
	);

	
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
	trigger => int_triggers, -- Again, thanks ISE.
	ack => int_ack,
	int => int_req,
	status => int_status
);

int_triggers<=(0=>'0',
					1=>ps2_int,
					others => '0');

-- Main CPU

	zpu: zpu_core_flex
	generic map (
		IMPL_MULTIPLY => false,
		IMPL_COMPARISON_SUB => false,
		IMPL_EQBRANCH => false,
		IMPL_STOREBH => false,
		IMPL_LOADBH => false,
		IMPL_CALL => true,
		IMPL_SHIFT => false,
		IMPL_XOR => false,
		REMAP_STACK => false,
		EXECUTE_RAM => false,
		maxAddrBitBRAM => 12
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

int_trigger<=int_req and int_enabled;

process(clk)
begin
	if reset='0' then
		spi_cs<='1';
		int_enabled<='0';
		kbdrecvreg <='0';
		mouserecvreg <='0';
	elsif rising_edge(clk) then
		mem_busy<='1';
		ser_txgo<='0';
		int_ack<='0';
		kbdsendtrigger<='0';
		mousesendtrigger<='0';
		
		-- Write from CPU?
		if mem_writeEnable='1' then
			case mem_addr(31)&mem_addr(10 downto 8) is
				when X"C" =>	-- Timer controller at 0xFFFFFC00
					timer_reg_req<='1';
					mem_busy<='0';	-- Audio controller never blocks the CPU
				when X"F" =>	-- Peripherals
					case mem_addr(7 downto 0) is

						when X"B0" => -- Interrupts
							int_enabled<=mem_write(0);
							mem_busy<='0';

						when X"C0" => -- UART
							ser_txdata<=mem_write(7 downto 0);
							ser_txgo<='1';
							mem_busy<='0';

						-- Write to PS/2 registers
						when X"e0" =>
							kbdsendbyte<=mem_write(7 downto 0);
							kbdsendtrigger<='1';
							mem_busy<='0';

						when X"e4" =>
							mousesendbyte<=mem_write(7 downto 0);
							mousesendtrigger<='1';
							mem_busy<='0';
							
						when others =>
							mem_busy<='0';
							null;
					end case;
				when others =>
					null;
			end case;

		elsif mem_readEnable='1' then -- Read from CPU?
			case mem_addr(31 downto 28) is

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

						-- Read from PS/2 regs
						when X"E0" =>
							mem_read<=(others =>'X');
							mem_read(11 downto 0)<=kbdrecvreg & not kbdsendbusy & kbdrecvbyte(10 downto 1);
							kbdrecvreg<='0';
							mem_busy<='0';
							
						when X"E4" =>
							mem_read<=(others =>'X');
							mem_read(11 downto 0)<=mouserecvreg & not mousesendbusy & mouserecvbyte(10 downto 1);
							mouserecvreg<='0';
							mem_busy<='0';


						when others =>
							mem_busy<='0';
							null;
					end case;

				when others =>
					null;
			end case;
		end if;


		-- Set this after the read operation has potentially cleared it.
		if ser_rxint='1' then
			ser_rxrecv<='1';
		end if;

		-- PS2 interrupt
		ps2_int <= kbdrecv or kbdsenddone
			or mouserecv or mousesenddone;
			-- mouserecv or kbdsenddone or mousesenddone ; -- Momentary high pulses to indicate retrieved data.
		if kbdrecv='1' then
			kbdrecvreg <= '1'; -- remains high until cleared by a read
		end if;
		if mouserecv='1' then
			mouserecvreg <= '1'; -- remains high until cleared by a read
		end if;	
	
	end if; -- rising-edge(clk)

end process;
	
end architecture;

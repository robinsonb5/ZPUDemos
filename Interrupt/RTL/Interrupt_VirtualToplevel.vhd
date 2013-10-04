library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.zpu_config.all;
use work.zpupkg.ALL;

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
		txd	: out std_logic
);
end entity;

architecture rtl of VirtualToplevel is

constant sysclk_hz : integer := sysclk_frequency*1000;
constant uart_divisor : integer := sysclk_hz/1152;

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
signal int_status : std_logic_vector(int_max downto 0);
signal int_ack : std_logic;
signal int_req : std_logic;
signal int_enabled : std_logic :='0'; -- Disabled by default

-- Timer signals
signal second_counter : unsigned(31 downto 0) := X"00000000";
signal second_tick : std_logic;

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

begin

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


-- Hello World ROM

	myrom : entity work.Interrupt_ROM
	generic map
	(
		maxAddrBit => 11
	)
	port map (
		clk => clk,
		from_zpu => zpu_to_rom,
		to_zpu => zpu_from_rom
	);


-- Interrupt controller

intcontroller: entity work.interrupt_controller
generic map (
	max_int => int_max
)
port map (
	clk => clk,
	reset_n => reset,
	trigger(0) => second_tick,
	ack => int_ack,
	int => int_req,
	status => int_status
);
	

-- Main CPU

	zpu: zpu_core 
	generic map (
		IMPL_MULTIPLY => false,
		IMPL_COMPARISON_SUB => false,
		IMPL_EQBRANCH => false,
		IMPL_STOREBH => false,
		IMPL_LOADBH => false,
		IMPL_CALL => false,
		IMPL_SHIFT => false,
		IMPL_XOR => false,
		REMAP_STACK => false,
		EXECUTE_RAM => false,
		maxAddrBitBRAM => 11
	)
	port map (
		clk                 => clk,
		reset               => not reset,
		interrupt			  => int_req and int_enabled,
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

-- Timer
process(clk)
begin
	if rising_edge(clk) then
		second_counter<=second_counter+1;
		second_tick<='0';
		if second_counter=sysclk_frequency*100000 then
			second_tick<='1';
			second_counter<=(others=>'0');
		end if;
	end if;
end process;


process(clk)
begin
	if reset='0' then
		spi_cs<='1';
		int_enabled<='0';
	elsif rising_edge(clk) then
		mem_busy<='1';
		ser_txgo<='0';
		int_ack<='0';
		
		-- Write from CPU?
		if mem_writeEnable='1' then
			case mem_addr(31 downto 28) is
				when X"F" =>	-- Peripherals
					case mem_addr(7 downto 0) is

						when X"B0" => -- Interrupts
							int_enabled<=mem_write(0);
							mem_busy<='0';

						when X"C0" => -- UART
							ser_txdata<=mem_write(7 downto 0);
							ser_txgo<='1';
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

	end if; -- rising-edge(clk)

end process;
	
end architecture;

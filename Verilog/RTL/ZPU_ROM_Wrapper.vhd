library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.zpupkg.ALL;

entity ZPU_ROM_Wrapper is
	generic (
		maxAddrBit : integer := 31
	);
	port (
		clk 			: in std_logic;
		reset			: in std_logic;
		mem_busy		: in std_logic;
		mem_read		: in std_logic_vector(wordSize-1 downto 0);
		mem_write	: out std_logic_vector(wordSize-1 downto 0);
		mem_addr		: out std_logic_vector(maxAddrBit downto 0);
		mem_writeEnable	: out std_logic; 
		mem_writeEnableh	: out std_logic; 
		mem_writeEnableb	: out std_logic; 
		mem_readEnable	: out std_logic
);
end entity;

architecture rtl of ZPU_ROM_Wrapper is

-- ZPU signals

signal zpu_to_rom : ZPU_ToROM;
signal zpu_from_rom : ZPU_FromROM;

begin

-- Hello World ROM

	myrom : entity work.HelloWorld_ROM
	generic map
	(
		maxAddrBitBRAM => 10
	)
	port map (
		clk => clk,
		from_zpu => zpu_to_rom,
		to_zpu => zpu_from_rom
	);


-- Main CPU

	zpu: zpu_core_flex
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
		maxAddrBitBRAM => 10
	)
	port map (
		clk                 => clk,
		reset               => reset,
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
	
end architecture;

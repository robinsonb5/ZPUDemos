library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.zpupkg.ALL;

entity ZPU_LEDWrapper is
	generic (
		delay : integer := 1
	);
	port (
		clk 			: in std_logic;
		reset_in 	: in std_logic;
		led : out std_logic
	);
end entity;

architecture rtl of ZPU_LEDWrapper is

constant maxAddrBit : integer := 10;

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

-- Hello World ROM

	myrom : entity work.MultiZPU_ROM
	generic map
	(
		maxAddrBitBRAM => 8
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
		IMPL_COMPARISON_SUB => true,
		IMPL_EQBRANCH => true,
		IMPL_STOREBH => false,
		IMPL_LOADBH => false,
		IMPL_CALL => true,
		IMPL_SHIFT => true,
		IMPL_XOR => true,
		REMAP_STACK => false,
		EXECUTE_RAM => false,
		maxAddrBitBRAM => 8,
		maxAddrBit => maxAddrBit
	)
	port map (
		clk                 => clk,
		reset               => not reset_in,
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
	if rising_edge(clk) then
		mem_busy<='1';
		
		-- Write from CPU?
		if mem_writeEnable='1' then
			if mem_addr(MaxAddrBit)='1' then
				case mem_addr(7 downto 0) is
					when X"FC" => -- LED
						LED<=mem_write(0);
						mem_busy<='0';
						
					when others =>
						mem_busy<='0';
						null;
				end case;
			end if;

		elsif mem_readEnable='1' then -- Read from CPU?
			if mem_addr(MaxAddrBit)='1' then
				case mem_addr(7 downto 0) is
					when X"F8" => -- DELAY
						mem_read(31 downto 0)<=std_logic_vector(to_unsigned(delay,32));
						mem_busy<='0';

					when others =>
						mem_busy<='0';
						null;
				end case;
			end if;
		end if;

	end if; -- rising-edge(clk)

end process;
	
end architecture;

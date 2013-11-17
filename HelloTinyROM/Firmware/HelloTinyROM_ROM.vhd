-- ZPU
--
-- Copyright 2004-2008 oharboe - �yvind Harboe - oyvind.harboe@zylin.com
-- Modified by Alastair M. Robinson for the ZPUFlex project.
--
-- The FreeBSD license
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above
--    copyright notice, this list of conditions and the following
--    disclaimer in the documentation and/or other materials
--    provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE ZPU PROJECT ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
-- PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
-- ZPU PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
-- INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation
-- are those of the authors and should not be interpreted as representing
-- official policies, either expressed or implied, of the ZPU Project.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.zpu_config.all;
use work.zpupkg.all;

entity HelloTinyROM_ROM is
generic
	(
		maxAddrBitBRAM : integer := maxAddrBitBRAMLimit -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	areset : in std_logic := '0';
	from_zpu : in ZPU_ToROM;
	to_zpu : out ZPU_FromROM
);
end HelloTinyROM_ROM;

architecture arch of HelloTinyROM_ROM is

type ram_type is array(natural range 0 to ((2**(maxAddrBitBRAM+1))/4)-1) of std_logic_vector(wordSize-1 downto 0);

shared variable ram : ram_type :=
(
     0 => x"0b0b0b80",
     1 => x"e9040000",
     2 => x"00000000",
     3 => x"0b0b0b0b",
     4 => x"880d8004",
     5 => x"940471fd",
     6 => x"06087283",
     7 => x"06098105",
     8 => x"8205832b",
     9 => x"2a83ffff",
    10 => x"06520471",
    11 => x"fc060872",
    12 => x"83060981",
    13 => x"05830510",
    14 => x"10102a81",
    15 => x"ff065204",
    16 => x"71fc0608",
    17 => x"0b0b0b81",
    18 => x"f0738306",
    19 => x"10100508",
    20 => x"067381ff",
    21 => x"06738306",
    22 => x"09810583",
    23 => x"05101010",
    24 => x"2b0772fc",
    25 => x"060c5151",
    26 => x"04028405",
    27 => x"0b0b0b0b",
    28 => x"880c940b",
    29 => x"80f90400",
    30 => x"0002fc05",
    31 => x"0d828051",
    32 => x"81af2d80",
    33 => x"0b82900c",
    34 => x"0284050d",
    35 => x"0402f805",
    36 => x"0d7352c0",
    37 => x"0870882a",
    38 => x"70810651",
    39 => x"51517080",
    40 => x"2ef13871",
    41 => x"c00c7182",
    42 => x"900c0288",
    43 => x"050d0402",
    44 => x"f0050d75",
    45 => x"5372ab2d",
    46 => x"7081ff06",
    47 => x"52527080",
    48 => x"2ea23871",
    49 => x"81ff0681",
    50 => x"145452c0",
    51 => x"0870882a",
    52 => x"70810651",
    53 => x"51517080",
    54 => x"2ef13871",
    55 => x"c00c8114",
    56 => x"5481b504",
    57 => x"7382900c",
    58 => x"0290050d",
    59 => x"04000000",
    60 => x"00ffffff",
    61 => x"ff00ffff",
    62 => x"ffff00ff",
    63 => x"ffffff00",
    64 => x"48656c6c",
    65 => x"6f2c2077",
    66 => x"6f726c64",
    67 => x"210a0064",
	others => x"00000000"
);

begin

process (clk)
begin
	if (clk'event and clk = '1') then
		if (from_zpu.memAWriteEnable = '1') and (from_zpu.memBWriteEnable = '1') and (from_zpu.memAAddr=from_zpu.memBAddr) and (from_zpu.memAWrite/=from_zpu.memBWrite) then
			report "write collision" severity failure;
		end if;
	
		if (from_zpu.memAWriteEnable = '1') then
			ram(to_integer(unsigned(from_zpu.memAAddr(maxAddrBitBRAM downto 2)))) := from_zpu.memAWrite;
			to_zpu.memARead <= from_zpu.memAWrite;
		else
			to_zpu.memARead <= ram(to_integer(unsigned(from_zpu.memAAddr(maxAddrBitBRAM downto 2))));
		end if;
	end if;
end process;

process (clk)
begin
	if (clk'event and clk = '1') then
		if (from_zpu.memBWriteEnable = '1') then
			ram(to_integer(unsigned(from_zpu.memBAddr(maxAddrBitBRAM downto 2)))) := from_zpu.memBWrite;
			to_zpu.memBRead <= from_zpu.memBWrite;
		else
			to_zpu.memBRead <= ram(to_integer(unsigned(from_zpu.memBAddr(maxAddrBitBRAM downto 2))));
		end if;
	end if;
end process;


end arch;


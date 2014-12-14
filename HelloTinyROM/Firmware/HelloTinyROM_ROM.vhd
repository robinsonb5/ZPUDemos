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
     0 => x"880b0b0b",
     1 => x"0b81e004",
     2 => x"8804ff0d",
     3 => x"80040000",
     4 => x"80e0040b",
     5 => x"80f5040b",
     6 => x"81a2040b",
     7 => x"81b70404",
     8 => x"0b0b0b83",
     9 => x"80080b0b",
    10 => x"0b838408",
    11 => x"0b0b0b83",
    12 => x"88080b0b",
    13 => x"0b80cc08",
    14 => x"2d0b0b0b",
    15 => x"83880c0b",
    16 => x"0b0b8384",
    17 => x"0c0b0b0b",
    18 => x"83800c04",
    19 => x"0000001f",
    20 => x"00ffffff",
    21 => x"ff00ffff",
    22 => x"ffff00ff",
    23 => x"ffffff00",
    24 => x"71fd0608",
    25 => x"72830609",
    26 => x"81058205",
    27 => x"832b2a83",
    28 => x"ffff0652",
    29 => x"0471fd06",
    30 => x"0883ffff",
    31 => x"73830609",
    32 => x"81058205",
    33 => x"832b2b09",
    34 => x"067383ff",
    35 => x"ff067383",
    36 => x"06098105",
    37 => x"8205832b",
    38 => x"0b2b0772",
    39 => x"fc060c51",
    40 => x"510471fc",
    41 => x"06087283",
    42 => x"06098105",
    43 => x"83051010",
    44 => x"102a81ff",
    45 => x"06520471",
    46 => x"fc06080b",
    47 => x"0b0b80d0",
    48 => x"73830610",
    49 => x"10050806",
    50 => x"7381ff06",
    51 => x"73830609",
    52 => x"81058305",
    53 => x"1010102b",
    54 => x"0772fc06",
    55 => x"0c515104",
    56 => x"83807083",
    57 => x"90278e38",
    58 => x"80717084",
    59 => x"05530c0b",
    60 => x"0b0b81e2",
    61 => x"04885181",
    62 => x"fa0402fc",
    63 => x"050d0b0b",
    64 => x"0b82f051",
    65 => x"82b32d80",
    66 => x"0b83800c",
    67 => x"0284050d",
    68 => x"0402f805",
    69 => x"0d7352c0",
    70 => x"0870882a",
    71 => x"70810651",
    72 => x"51517080",
    73 => x"2ef13871",
    74 => x"c00c7183",
    75 => x"800c0288",
    76 => x"050d0402",
    77 => x"f0050d75",
    78 => x"53723370",
    79 => x"81ff0652",
    80 => x"5270802e",
    81 => x"a2387181",
    82 => x"ff068114",
    83 => x"5452c008",
    84 => x"70882a70",
    85 => x"81065151",
    86 => x"5170802e",
    87 => x"f13871c0",
    88 => x"0c811454",
    89 => x"82b90473",
    90 => x"83800c02",
    91 => x"90050d04",
    92 => x"48656c6c",
    93 => x"6f2c2077",
    94 => x"6f726c64",
    95 => x"210a0064",
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


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
     0 => x"80e60400",
     1 => x"00000000",
     2 => x"0b0b0b0b",
     3 => x"84080d80",
     4 => x"04910471",
     5 => x"fd060872",
     6 => x"83060981",
     7 => x"05820583",
     8 => x"2b2a83ff",
     9 => x"ff065204",
    10 => x"71fc0608",
    11 => x"72830609",
    12 => x"81058305",
    13 => x"1010102a",
    14 => x"81ff0652",
    15 => x"0471fc06",
    16 => x"080b0b0b",
    17 => x"81ec7383",
    18 => x"06101005",
    19 => x"08067381",
    20 => x"ff067383",
    21 => x"06098105",
    22 => x"83051010",
    23 => x"102b0772",
    24 => x"fc060c51",
    25 => x"51040284",
    26 => x"050b0b0b",
    27 => x"0b840c91",
    28 => x"0b80f504",
    29 => x"0002fc05",
    30 => x"0d81fc51",
    31 => x"81ab2d80",
    32 => x"0b828c0c",
    33 => x"0284050d",
    34 => x"0402f805",
    35 => x"0d7352c0",
    36 => x"0870882a",
    37 => x"70810651",
    38 => x"51517080",
    39 => x"2ef13871",
    40 => x"c00c7182",
    41 => x"8c0c0288",
    42 => x"050d0402",
    43 => x"f0050d75",
    44 => x"5372a82d",
    45 => x"7081ff06",
    46 => x"52527080",
    47 => x"2ea23871",
    48 => x"81ff0681",
    49 => x"145452c0",
    50 => x"0870882a",
    51 => x"70810651",
    52 => x"51517080",
    53 => x"2ef13871",
    54 => x"c00c8114",
    55 => x"5481b104",
    56 => x"73828c0c",
    57 => x"0290050d",
    58 => x"04000000",
    59 => x"00ffffff",
    60 => x"ff00ffff",
    61 => x"ffff00ff",
    62 => x"ffffff00",
    63 => x"48656c6c",
    64 => x"6f2c2077",
    65 => x"6f726c64",
    66 => x"210a0064",
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


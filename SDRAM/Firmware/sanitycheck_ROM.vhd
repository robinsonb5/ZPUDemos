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

entity sanitycheck_ROM is
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
end sanitycheck_ROM;

architecture arch of sanitycheck_ROM is

type ram_type is array(natural range 0 to ((2**(maxAddrBitBRAM+1))/4)-1) of std_logic_vector(wordSize-1 downto 0);

shared variable ram : ram_type :=
(
     0 => x"84808080",
     1 => x"e0040000",
     2 => x"00000000",
     3 => x"00000000",
     4 => x"00000000",
     5 => x"00000000",
     6 => x"00000000",
     7 => x"00000000",
     8 => x"00000000",
     9 => x"00000000",
    10 => x"00000000",
    11 => x"00000000",
    12 => x"00000000",
    13 => x"00000000",
    14 => x"00000000",
    15 => x"00000000",
    16 => x"00000000",
    17 => x"00000000",
    18 => x"00000000",
    19 => x"00000000",
    20 => x"00000000",
    21 => x"00000000",
    22 => x"00000000",
    23 => x"00000000",
    24 => x"8191d1ac",
    25 => x"f80b8480",
    26 => x"800c8480",
    27 => x"82228480",
    28 => x"80228480",
    29 => x"83338480",
    30 => x"82338480",
    31 => x"81338480",
    32 => x"803383fd",
    33 => x"db0b8480",
    34 => x"80238480",
    35 => x"800881a9",
    36 => x"0b848083",
    37 => x"34848080",
    38 => x"0880d50b",
    39 => x"84808134",
    40 => x"84808008",
    41 => x"80c4c4b3",
    42 => x"0b84a080",
    43 => x"0c84a2d5",
    44 => x"ccf70b84",
    45 => x"a0840cf8",
    46 => x"c4e6d5bb",
    47 => x"0b84a088",
    48 => x"0cfce6f7",
    49 => x"ddff0b84",
    50 => x"a08c0ca4",
    51 => x"b40b84a0",
    52 => x"842381ac",
    53 => x"f80b84a0",
    54 => x"8a2384a0",
    55 => x"822284a0",
    56 => x"842284a0",
    57 => x"8c2284a0",
    58 => x"8a221184",
    59 => x"808081a4",
    60 => x"04848080",
    61 => x"81f10400",
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


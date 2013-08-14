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
		maxAddrBit : integer := maxAddrBitBRAMLimit -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	areset : in std_logic := '0';
	from_zpu : in ZPU_ToROM;
	to_zpu : out ZPU_FromROM
);
end HelloTinyROM_ROM;

architecture arch of HelloTinyROM_ROM is

type ram_type is array(natural range 0 to ((2**(maxAddrBit+1))/4)-1) of std_logic_vector(wordSize-1 downto 0);

shared variable ram : ram_type :=
(
     0 => x"0b0b0b80",
     1 => x"df040000",
     2 => x"80048a04",
     3 => x"71fd0608",
     4 => x"72830609",
     5 => x"81058205",
     6 => x"832b2a83",
     7 => x"ffff0652",
     8 => x"0471fc06",
     9 => x"08728306",
    10 => x"09810583",
    11 => x"05101010",
    12 => x"2a81ff06",
    13 => x"520471fc",
    14 => x"06080b0b",
    15 => x"0b81dc73",
    16 => x"83061010",
    17 => x"05080673",
    18 => x"81ff0673",
    19 => x"83060981",
    20 => x"05830510",
    21 => x"10102b07",
    22 => x"72fc060c",
    23 => x"5151048a",
    24 => x"0b80e504",
    25 => x"0002fc05",
    26 => x"0d0b0b0b",
    27 => x"81ec5181",
    28 => x"9e2d800b",
    29 => x"81fc0c02",
    30 => x"84050d04",
    31 => x"02f8050d",
    32 => x"7352c008",
    33 => x"70882a70",
    34 => x"81065151",
    35 => x"5170802e",
    36 => x"f13871c0",
    37 => x"0c7181fc",
    38 => x"0c028805",
    39 => x"0d0402f0",
    40 => x"050d7553",
    41 => x"72a12d70",
    42 => x"81ff0652",
    43 => x"5270802e",
    44 => x"a2387181",
    45 => x"ff068114",
    46 => x"5452c008",
    47 => x"70882a70",
    48 => x"81065151",
    49 => x"5170802e",
    50 => x"f13871c0",
    51 => x"0c811454",
    52 => x"81a40473",
    53 => x"81fc0c02",
    54 => x"90050d04",
    55 => x"00ffffff",
    56 => x"ff00ffff",
    57 => x"ffff00ff",
    58 => x"ffffff00",
    59 => x"48656c6c",
    60 => x"6f2c2077",
    61 => x"6f726c64",
    62 => x"210a0000",
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
			ram(to_integer(unsigned(from_zpu.memAAddr(maxAddrBit downto 2)))) := from_zpu.memAWrite;
			to_zpu.memARead <= from_zpu.memAWrite;
		else
			to_zpu.memARead <= ram(to_integer(unsigned(from_zpu.memAAddr(maxAddrBit downto 2))));
		end if;
	end if;
end process;

process (clk)
begin
	if (clk'event and clk = '1') then
		if (from_zpu.memBWriteEnable = '1') then
			ram(to_integer(unsigned(from_zpu.memBAddr(maxAddrBit downto 2)))) := from_zpu.memBWrite;
			to_zpu.memBRead <= from_zpu.memBWrite;
		else
			to_zpu.memBRead <= ram(to_integer(unsigned(from_zpu.memBAddr(maxAddrBit downto 2))));
		end if;
	end if;
end process;


end arch;


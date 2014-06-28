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

entity RS232Bootstrap_ROM is
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
end RS232Bootstrap_ROM;

architecture arch of RS232Bootstrap_ROM is

type ram_type is array(natural range 0 to ((2**(maxAddrBitBRAM+1))/4)-1) of std_logic_vector(wordSize-1 downto 0);

shared variable ram : ram_type :=
(
     0 => x"84808080",
     1 => x"ee040000",
     2 => x"00000000",
     3 => x"84808080",
     4 => x"88080d80",
     5 => x"04848080",
     6 => x"80950471",
     7 => x"fd060872",
     8 => x"83060981",
     9 => x"05820583",
    10 => x"2b2a83ff",
    11 => x"ff065204",
    12 => x"71fc0608",
    13 => x"72830609",
    14 => x"81058305",
    15 => x"1010102a",
    16 => x"81ff0652",
    17 => x"0471fc06",
    18 => x"08848080",
    19 => x"86e07383",
    20 => x"06101005",
    21 => x"08067381",
    22 => x"ff067383",
    23 => x"06098105",
    24 => x"83051010",
    25 => x"102b0772",
    26 => x"fc060c51",
    27 => x"51040284",
    28 => x"05848080",
    29 => x"80880c84",
    30 => x"80808095",
    31 => x"0b848080",
    32 => x"85e90400",
    33 => x"02f8050d",
    34 => x"7352c008",
    35 => x"70882a70",
    36 => x"81065151",
    37 => x"5170802e",
    38 => x"f13871c0",
    39 => x"0c7183ff",
    40 => x"e0800c02",
    41 => x"88050d04",
    42 => x"02e8050d",
    43 => x"80785755",
    44 => x"75708405",
    45 => x"57085380",
    46 => x"5472982a",
    47 => x"73882b54",
    48 => x"5271802e",
    49 => x"a238c008",
    50 => x"70882a70",
    51 => x"81065151",
    52 => x"5170802e",
    53 => x"f13871c0",
    54 => x"0c811581",
    55 => x"15555583",
    56 => x"7425d638",
    57 => x"71ca3874",
    58 => x"83ffe080",
    59 => x"0c029805",
    60 => x"0d0402f8",
    61 => x"050dc008",
    62 => x"70892a70",
    63 => x"81065152",
    64 => x"5270802e",
    65 => x"f1387181",
    66 => x"ff0683ff",
    67 => x"e0800c02",
    68 => x"88050d04",
    69 => x"02fc050d",
    70 => x"7381df06",
    71 => x"c9055170",
    72 => x"80258438",
    73 => x"a7115172",
    74 => x"842b7107",
    75 => x"83ffe080",
    76 => x"0c028405",
    77 => x"0d0402ec",
    78 => x"050d029b",
    79 => x"05848080",
    80 => x"80b02d83",
    81 => x"ffe0a408",
    82 => x"810583ff",
    83 => x"e0a40c54",
    84 => x"7380d32e",
    85 => x"098106a6",
    86 => x"38800b83",
    87 => x"ffe0a40c",
    88 => x"800b83ff",
    89 => x"e0940c80",
    90 => x"0b83ffe0",
    91 => x"a80c800b",
    92 => x"83ffe090",
    93 => x"0c73c00c",
    94 => x"84808085",
    95 => x"e40483ff",
    96 => x"e0a40883",
    97 => x"ffe09008",
    98 => x"54527181",
    99 => x"2e098106",
   100 => x"b93880f4",
   101 => x"0bc00c73",
   102 => x"81df06c9",
   103 => x"05517080",
   104 => x"258438a7",
   105 => x"11517284",
   106 => x"2b710770",
   107 => x"83ffe090",
   108 => x"0c518371",
   109 => x"2585388a",
   110 => x"71315170",
   111 => x"10820583",
   112 => x"ffe09c0c",
   113 => x"84808085",
   114 => x"e404b013",
   115 => x"70c00c55",
   116 => x"718324a6",
   117 => x"3883ffe0",
   118 => x"a8087481",
   119 => x"df06c905",
   120 => x"52527080",
   121 => x"258438a7",
   122 => x"11517184",
   123 => x"2b710783",
   124 => x"ffe0a80c",
   125 => x"84808085",
   126 => x"e40483ff",
   127 => x"e09c0883",
   128 => x"05517171",
   129 => x"24a63883",
   130 => x"ffe09408",
   131 => x"7481df06",
   132 => x"c9055252",
   133 => x"70802584",
   134 => x"38a71151",
   135 => x"71842b71",
   136 => x"0783ffe0",
   137 => x"940c8480",
   138 => x"80859504",
   139 => x"ff135170",
   140 => x"82268197",
   141 => x"3883ffe0",
   142 => x"a8081081",
   143 => x"05517171",
   144 => x"2480df38",
   145 => x"83ffe0a0",
   146 => x"087481df",
   147 => x"06c90552",
   148 => x"52708025",
   149 => x"8438a711",
   150 => x"5171842b",
   151 => x"71077083",
   152 => x"ffe0a00c",
   153 => x"83ffe098",
   154 => x"08ff0583",
   155 => x"ffe0980c",
   156 => x"5283ffe0",
   157 => x"98088025",
   158 => x"80ea3883",
   159 => x"ffe09408",
   160 => x"51717184",
   161 => x"808080c5",
   162 => x"2d83ffe0",
   163 => x"94088105",
   164 => x"83ffe094",
   165 => x"0c810b83",
   166 => x"ffe0980c",
   167 => x"84808085",
   168 => x"e40483ff",
   169 => x"e09808bc",
   170 => x"3883ffe0",
   171 => x"a008842b",
   172 => x"7083ffe0",
   173 => x"a00c83ff",
   174 => x"e0940852",
   175 => x"52717184",
   176 => x"808080c5",
   177 => x"2d848080",
   178 => x"85e40486",
   179 => x"73259238",
   180 => x"80c20bc0",
   181 => x"0c848080",
   182 => x"808c2d84",
   183 => x"808085e4",
   184 => x"0474c00c",
   185 => x"0294050d",
   186 => x"0402f005",
   187 => x"0d80d251",
   188 => x"84808081",
   189 => x"842d80e5",
   190 => x"51848080",
   191 => x"81842d80",
   192 => x"e1518480",
   193 => x"8081842d",
   194 => x"80e45184",
   195 => x"80808184",
   196 => x"2d80f951",
   197 => x"84808081",
   198 => x"842d8a51",
   199 => x"84808081",
   200 => x"842dae51",
   201 => x"84808081",
   202 => x"842dbd84",
   203 => x"bf54c008",
   204 => x"70892a70",
   205 => x"81065153",
   206 => x"5371802e",
   207 => x"92387281",
   208 => x"ff065184",
   209 => x"808082b6",
   210 => x"2d848080",
   211 => x"86aa04ff",
   212 => x"145473ff",
   213 => x"2e098106",
   214 => x"d5388480",
   215 => x"8086a204",
   216 => x"00ffffff",
   217 => x"ff00ffff",
   218 => x"ffff00ff",
   219 => x"ffffff00",
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


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
     1 => x"8c0b8480",
     2 => x"8081e004",
     3 => x"84808080",
     4 => x"8c04ff0d",
     5 => x"80040400",
     6 => x"40000016",
     7 => x"00000000",
     8 => x"0b83ffe0",
     9 => x"80080b83",
    10 => x"ffe08408",
    11 => x"0b83ffe0",
    12 => x"88088480",
    13 => x"80809808",
    14 => x"2d0b83ff",
    15 => x"e0880c0b",
    16 => x"83ffe084",
    17 => x"0c0b83ff",
    18 => x"e0800c04",
    19 => x"00000000",
    20 => x"00000000",
    21 => x"00000000",
    22 => x"00000000",
    23 => x"00000000",
    24 => x"71fd0608",
    25 => x"72830609",
    26 => x"81058205",
    27 => x"832b2a83",
    28 => x"ffff0652",
    29 => x"0471fc06",
    30 => x"08728306",
    31 => x"09810583",
    32 => x"05101010",
    33 => x"2a81ff06",
    34 => x"520471fd",
    35 => x"060883ff",
    36 => x"ff738306",
    37 => x"09810582",
    38 => x"05832b2b",
    39 => x"09067383",
    40 => x"ffff0673",
    41 => x"83060981",
    42 => x"05820583",
    43 => x"2b0b2b07",
    44 => x"72fc060c",
    45 => x"51510471",
    46 => x"fc060884",
    47 => x"808087e4",
    48 => x"73830610",
    49 => x"10050806",
    50 => x"7381ff06",
    51 => x"73830609",
    52 => x"81058305",
    53 => x"1010102b",
    54 => x"0772fc06",
    55 => x"0c515104",
    56 => x"83ffe080",
    57 => x"7083ffe0",
    58 => x"ac278e38",
    59 => x"80717084",
    60 => x"05530c84",
    61 => x"808081e4",
    62 => x"04848080",
    63 => x"808c5184",
    64 => x"808086ea",
    65 => x"0402f805",
    66 => x"0d7352c0",
    67 => x"0870882a",
    68 => x"70810651",
    69 => x"51517080",
    70 => x"2ef13871",
    71 => x"c00c7183",
    72 => x"ffe0800c",
    73 => x"0288050d",
    74 => x"0402e805",
    75 => x"0d807857",
    76 => x"55757084",
    77 => x"05570853",
    78 => x"80547298",
    79 => x"2a73882b",
    80 => x"54527180",
    81 => x"2ea238c0",
    82 => x"0870882a",
    83 => x"70810651",
    84 => x"51517080",
    85 => x"2ef13871",
    86 => x"c00c8115",
    87 => x"81155555",
    88 => x"837425d6",
    89 => x"3871ca38",
    90 => x"7483ffe0",
    91 => x"800c0298",
    92 => x"050d0402",
    93 => x"f8050dc0",
    94 => x"0870892a",
    95 => x"70810651",
    96 => x"52527080",
    97 => x"2ef13871",
    98 => x"81ff0683",
    99 => x"ffe0800c",
   100 => x"0288050d",
   101 => x"0402fc05",
   102 => x"0d7381df",
   103 => x"06c90551",
   104 => x"70802584",
   105 => x"38a71151",
   106 => x"72842b71",
   107 => x"0783ffe0",
   108 => x"800c0284",
   109 => x"050d0402",
   110 => x"ec050d02",
   111 => x"9b058480",
   112 => x"8080f52d",
   113 => x"83ffe0a4",
   114 => x"08810583",
   115 => x"ffe0a40c",
   116 => x"547380d3",
   117 => x"2e098106",
   118 => x"a638800b",
   119 => x"83ffe0a4",
   120 => x"0c800b83",
   121 => x"ffe0940c",
   122 => x"800b83ff",
   123 => x"e0a80c80",
   124 => x"0b83ffe0",
   125 => x"900c73c0",
   126 => x"0c848080",
   127 => x"86e50483",
   128 => x"ffe0a408",
   129 => x"83ffe090",
   130 => x"08545271",
   131 => x"812e0981",
   132 => x"06b93880",
   133 => x"f40bc00c",
   134 => x"7381df06",
   135 => x"c9055170",
   136 => x"80258438",
   137 => x"a7115172",
   138 => x"842b7107",
   139 => x"7083ffe0",
   140 => x"900c5183",
   141 => x"71258538",
   142 => x"8a713151",
   143 => x"70108205",
   144 => x"83ffe09c",
   145 => x"0c848080",
   146 => x"86e504b0",
   147 => x"1370c00c",
   148 => x"55718324",
   149 => x"a63883ff",
   150 => x"e0a80874",
   151 => x"81df06c9",
   152 => x"05525270",
   153 => x"80258438",
   154 => x"a7115171",
   155 => x"842b7107",
   156 => x"83ffe0a8",
   157 => x"0c848080",
   158 => x"86e50483",
   159 => x"ffe09c08",
   160 => x"83055171",
   161 => x"7124a638",
   162 => x"83ffe094",
   163 => x"087481df",
   164 => x"06c90552",
   165 => x"52708025",
   166 => x"8438a711",
   167 => x"5171842b",
   168 => x"710783ff",
   169 => x"e0940c84",
   170 => x"80808696",
   171 => x"04ff1351",
   172 => x"70822681",
   173 => x"973883ff",
   174 => x"e0a80810",
   175 => x"81055171",
   176 => x"712480df",
   177 => x"3883ffe0",
   178 => x"a0087481",
   179 => x"df06c905",
   180 => x"52527080",
   181 => x"258438a7",
   182 => x"11517184",
   183 => x"2b710770",
   184 => x"83ffe0a0",
   185 => x"0c83ffe0",
   186 => x"9808ff05",
   187 => x"83ffe098",
   188 => x"0c5283ff",
   189 => x"e0980880",
   190 => x"2580ea38",
   191 => x"83ffe094",
   192 => x"08517171",
   193 => x"84808081",
   194 => x"b72d83ff",
   195 => x"e0940881",
   196 => x"0583ffe0",
   197 => x"940c810b",
   198 => x"83ffe098",
   199 => x"0c848080",
   200 => x"86e50483",
   201 => x"ffe09808",
   202 => x"bc3883ff",
   203 => x"e0a00884",
   204 => x"2b7083ff",
   205 => x"e0a00c83",
   206 => x"ffe09408",
   207 => x"52527171",
   208 => x"84808081",
   209 => x"b72d8480",
   210 => x"8086e504",
   211 => x"86732592",
   212 => x"3880c20b",
   213 => x"c00c8480",
   214 => x"8080922d",
   215 => x"84808086",
   216 => x"e50474c0",
   217 => x"0c029405",
   218 => x"0d0402f0",
   219 => x"050d80d2",
   220 => x"51848080",
   221 => x"82852d80",
   222 => x"e5518480",
   223 => x"8082852d",
   224 => x"80e15184",
   225 => x"80808285",
   226 => x"2d80e451",
   227 => x"84808082",
   228 => x"852d80f9",
   229 => x"51848080",
   230 => x"82852d8a",
   231 => x"51848080",
   232 => x"82852dae",
   233 => x"51848080",
   234 => x"82852dbd",
   235 => x"84bf54c0",
   236 => x"0870892a",
   237 => x"70810651",
   238 => x"53537180",
   239 => x"2e923872",
   240 => x"81ff0651",
   241 => x"84808083",
   242 => x"b72d8480",
   243 => x"8087ab04",
   244 => x"ff145473",
   245 => x"ff2e0981",
   246 => x"06d53884",
   247 => x"808087a3",
   248 => x"04000000",
   249 => x"00ffffff",
   250 => x"ff00ffff",
   251 => x"ffff00ff",
   252 => x"ffffff00",
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


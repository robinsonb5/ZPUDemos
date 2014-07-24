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
     0 => x"888080ed",
     1 => x"04000000",
     2 => x"00000000",
     3 => x"0b888080",
     4 => x"88080d80",
     5 => x"04888080",
     6 => x"950471fd",
     7 => x"06087283",
     8 => x"06098105",
     9 => x"8205832b",
    10 => x"2a83ffff",
    11 => x"06520471",
    12 => x"fc060872",
    13 => x"83060981",
    14 => x"05830510",
    15 => x"10102a81",
    16 => x"ff065204",
    17 => x"71fc0608",
    18 => x"0b888086",
    19 => x"ec738306",
    20 => x"10100508",
    21 => x"067381ff",
    22 => x"06738306",
    23 => x"09810583",
    24 => x"05101010",
    25 => x"2b0772fc",
    26 => x"060c5151",
    27 => x"04028405",
    28 => x"0b888080",
    29 => x"880c8880",
    30 => x"80950b88",
    31 => x"8084da04",
    32 => x"0002fc05",
    33 => x"0d7381df",
    34 => x"06c90551",
    35 => x"70802584",
    36 => x"38a71151",
    37 => x"72842b71",
    38 => x"0783ffe0",
    39 => x"800c0284",
    40 => x"050d0402",
    41 => x"ec050d02",
    42 => x"9b058880",
    43 => x"80af2d83",
    44 => x"ffe0a408",
    45 => x"810583ff",
    46 => x"e0a40c54",
    47 => x"7380d32e",
    48 => x"098106a8",
    49 => x"38800b83",
    50 => x"ffe0a40c",
    51 => x"800b83ff",
    52 => x"e0940c80",
    53 => x"0b83ffe0",
    54 => x"a80c800b",
    55 => x"83ffe090",
    56 => x"0c7387ff",
    57 => x"ffc00c88",
    58 => x"8084d504",
    59 => x"83ffe0a4",
    60 => x"0883ffe0",
    61 => x"90085452",
    62 => x"71812e09",
    63 => x"8106bb38",
    64 => x"80f40b87",
    65 => x"ffffc00c",
    66 => x"7381df06",
    67 => x"c9055170",
    68 => x"80258438",
    69 => x"a7115172",
    70 => x"842b7107",
    71 => x"7083ffe0",
    72 => x"900c5183",
    73 => x"71258538",
    74 => x"8a713151",
    75 => x"70108205",
    76 => x"83ffe09c",
    77 => x"0c888084",
    78 => x"d504b013",
    79 => x"7087ffff",
    80 => x"c00c5571",
    81 => x"8324a538",
    82 => x"83ffe0a8",
    83 => x"087481df",
    84 => x"06c90552",
    85 => x"52708025",
    86 => x"8438a711",
    87 => x"5171842b",
    88 => x"710783ff",
    89 => x"e0a80c88",
    90 => x"8084d504",
    91 => x"83ffe09c",
    92 => x"08830551",
    93 => x"717124a5",
    94 => x"3883ffe0",
    95 => x"94087481",
    96 => x"df06c905",
    97 => x"52527080",
    98 => x"258438a7",
    99 => x"11517184",
   100 => x"2b710783",
   101 => x"ffe0940c",
   102 => x"88808485",
   103 => x"04ff1351",
   104 => x"70822681",
   105 => x"933883ff",
   106 => x"e0a80810",
   107 => x"81055171",
   108 => x"712480dd",
   109 => x"3883ffe0",
   110 => x"a0087481",
   111 => x"df06c905",
   112 => x"52527080",
   113 => x"258438a7",
   114 => x"11517184",
   115 => x"2b710770",
   116 => x"83ffe0a0",
   117 => x"0c83ffe0",
   118 => x"9808ff05",
   119 => x"83ffe098",
   120 => x"0c5283ff",
   121 => x"e0980880",
   122 => x"2580ea38",
   123 => x"83ffe094",
   124 => x"08517171",
   125 => x"888080c4",
   126 => x"2d83ffe0",
   127 => x"94088105",
   128 => x"83ffe094",
   129 => x"0c810b83",
   130 => x"ffe0980c",
   131 => x"888084d5",
   132 => x"0483ffe0",
   133 => x"9808be38",
   134 => x"83ffe0a0",
   135 => x"08842b70",
   136 => x"83ffe0a0",
   137 => x"0c83ffe0",
   138 => x"94085252",
   139 => x"71718880",
   140 => x"80c42d88",
   141 => x"8084d504",
   142 => x"86732593",
   143 => x"3880c20b",
   144 => x"87ffffc0",
   145 => x"0c888080",
   146 => x"8c2d8880",
   147 => x"84d50474",
   148 => x"87ffffc0",
   149 => x"0c029405",
   150 => x"0d0402f0",
   151 => x"050d80d2",
   152 => x"51888085",
   153 => x"ca2d80e5",
   154 => x"51888085",
   155 => x"ca2d80e1",
   156 => x"51888085",
   157 => x"ca2d80e4",
   158 => x"51888085",
   159 => x"ca2d80f9",
   160 => x"51888085",
   161 => x"ca2d8a51",
   162 => x"888085ca",
   163 => x"2dae5188",
   164 => x"8085ca2d",
   165 => x"bd84bf54",
   166 => x"87ffffc0",
   167 => x"0870892a",
   168 => x"70810651",
   169 => x"53537180",
   170 => x"2e903872",
   171 => x"81ff0651",
   172 => x"888081a3",
   173 => x"2d888085",
   174 => x"9404ff14",
   175 => x"5473ff2e",
   176 => x"098106d4",
   177 => x"38888085",
   178 => x"8d0402f8",
   179 => x"050d7352",
   180 => x"87ffffc0",
   181 => x"0870882a",
   182 => x"70810651",
   183 => x"51517080",
   184 => x"2eee3871",
   185 => x"87ffffc0",
   186 => x"0c7183ff",
   187 => x"e0800c02",
   188 => x"88050d04",
   189 => x"02e8050d",
   190 => x"80785755",
   191 => x"75708405",
   192 => x"57085380",
   193 => x"5472982a",
   194 => x"73882b54",
   195 => x"5271802e",
   196 => x"a83887ff",
   197 => x"ffc00870",
   198 => x"882a7081",
   199 => x"06515151",
   200 => x"70802eee",
   201 => x"387187ff",
   202 => x"ffc00c81",
   203 => x"15811555",
   204 => x"55837425",
   205 => x"d03871c4",
   206 => x"387483ff",
   207 => x"e0800c02",
   208 => x"98050d04",
   209 => x"02f8050d",
   210 => x"87ffffc0",
   211 => x"0870892a",
   212 => x"70810651",
   213 => x"52527080",
   214 => x"2eee3871",
   215 => x"81ff0683",
   216 => x"ffe0800c",
   217 => x"0288050d",
   218 => x"04000000",
   219 => x"00ffffff",
   220 => x"ff00ffff",
   221 => x"ffff00ff",
   222 => x"ffffff00",
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


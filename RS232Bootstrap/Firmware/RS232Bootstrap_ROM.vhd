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
     0 => x"0ba08080",
     1 => x"ec040000",
     2 => x"00000000",
     3 => x"0ba08080",
     4 => x"880d8004",
     5 => x"a0808094",
     6 => x"0471fd06",
     7 => x"08728306",
     8 => x"09810582",
     9 => x"05832b2a",
    10 => x"83ffff06",
    11 => x"520471fc",
    12 => x"06087283",
    13 => x"06098105",
    14 => x"83051010",
    15 => x"102a81ff",
    16 => x"06520471",
    17 => x"fc06080b",
    18 => x"a08086a0",
    19 => x"73830610",
    20 => x"10050806",
    21 => x"7381ff06",
    22 => x"73830609",
    23 => x"81058305",
    24 => x"1010102b",
    25 => x"0772fc06",
    26 => x"0c515104",
    27 => x"0284050b",
    28 => x"a0808088",
    29 => x"0ca08080",
    30 => x"940ba080",
    31 => x"85d30400",
    32 => x"0002f805",
    33 => x"0d7352c0",
    34 => x"0870882a",
    35 => x"70810651",
    36 => x"51517080",
    37 => x"2ef13871",
    38 => x"c00c7183",
    39 => x"ffe0800c",
    40 => x"0288050d",
    41 => x"0402e805",
    42 => x"0d807857",
    43 => x"55757084",
    44 => x"05570853",
    45 => x"80547298",
    46 => x"2a73882b",
    47 => x"54527180",
    48 => x"2ea238c0",
    49 => x"0870882a",
    50 => x"70810651",
    51 => x"51517080",
    52 => x"2ef13871",
    53 => x"c00c8115",
    54 => x"81155555",
    55 => x"837425d6",
    56 => x"3871ca38",
    57 => x"7483ffe0",
    58 => x"800c0298",
    59 => x"050d0402",
    60 => x"f8050dc0",
    61 => x"0870892a",
    62 => x"70810651",
    63 => x"52527080",
    64 => x"2ef13871",
    65 => x"81ff0683",
    66 => x"ffe0800c",
    67 => x"0288050d",
    68 => x"0402fc05",
    69 => x"0d7381df",
    70 => x"06c90551",
    71 => x"70802584",
    72 => x"38a71151",
    73 => x"72842b71",
    74 => x"0783ffe0",
    75 => x"800c0284",
    76 => x"050d0402",
    77 => x"f0050d02",
    78 => x"9705a080",
    79 => x"80ae2d83",
    80 => x"ffe0a408",
    81 => x"810583ff",
    82 => x"e0a40c54",
    83 => x"7380d32e",
    84 => x"098106a2",
    85 => x"38800b83",
    86 => x"ffe0a40c",
    87 => x"800b83ff",
    88 => x"e0940c80",
    89 => x"0b83ffe0",
    90 => x"a80c800b",
    91 => x"83ffe090",
    92 => x"0ca08085",
    93 => x"ce0483ff",
    94 => x"e0a40852",
    95 => x"71812e09",
    96 => x"810680c0",
    97 => x"3883ffe0",
    98 => x"90087481",
    99 => x"df06c905",
   100 => x"52527080",
   101 => x"258438a7",
   102 => x"11517184",
   103 => x"2b710770",
   104 => x"83ffe090",
   105 => x"0c705252",
   106 => x"83722585",
   107 => x"388a7231",
   108 => x"51701082",
   109 => x"0583ffe0",
   110 => x"9c0c80f4",
   111 => x"0bc00ca0",
   112 => x"8085ce04",
   113 => x"718324a5",
   114 => x"3883ffe0",
   115 => x"a8087481",
   116 => x"df06c905",
   117 => x"52527080",
   118 => x"258438a7",
   119 => x"11517184",
   120 => x"2b710783",
   121 => x"ffe0a80c",
   122 => x"a08085ce",
   123 => x"0483ffe0",
   124 => x"9c088305",
   125 => x"51717124",
   126 => x"a53883ff",
   127 => x"e0940874",
   128 => x"81df06c9",
   129 => x"05525270",
   130 => x"80258438",
   131 => x"a7115171",
   132 => x"842b7107",
   133 => x"83ffe094",
   134 => x"0ca08085",
   135 => x"8c0483ff",
   136 => x"e09008ff",
   137 => x"11525370",
   138 => x"82268193",
   139 => x"3883ffe0",
   140 => x"a8081081",
   141 => x"05517171",
   142 => x"2480dd38",
   143 => x"83ffe0a0",
   144 => x"087481df",
   145 => x"06c90552",
   146 => x"52708025",
   147 => x"8438a711",
   148 => x"5171842b",
   149 => x"71077083",
   150 => x"ffe0a00c",
   151 => x"83ffe098",
   152 => x"08ff0583",
   153 => x"ffe0980c",
   154 => x"5283ffe0",
   155 => x"98088025",
   156 => x"80dc3883",
   157 => x"ffe09408",
   158 => x"517171a0",
   159 => x"8080c32d",
   160 => x"83ffe094",
   161 => x"08810583",
   162 => x"ffe0940c",
   163 => x"810b83ff",
   164 => x"e0980ca0",
   165 => x"8085ce04",
   166 => x"83ffe098",
   167 => x"08b03883",
   168 => x"ffe0a008",
   169 => x"842b7083",
   170 => x"ffe0a00c",
   171 => x"83ffe094",
   172 => x"08525271",
   173 => x"71a08080",
   174 => x"c32da080",
   175 => x"85ce0486",
   176 => x"73258b38",
   177 => x"80c20bc0",
   178 => x"0ca08080",
   179 => x"8c2d0290",
   180 => x"050d0402",
   181 => x"fc050d80",
   182 => x"d251a080",
   183 => x"81812d80",
   184 => x"e551a080",
   185 => x"81812d80",
   186 => x"e151a080",
   187 => x"81812d80",
   188 => x"e451a080",
   189 => x"81812d80",
   190 => x"f951a080",
   191 => x"81812d8a",
   192 => x"51a08081",
   193 => x"812da080",
   194 => x"81ef2d83",
   195 => x"ffe08008",
   196 => x"81ff0651",
   197 => x"a08082b3",
   198 => x"2da08086",
   199 => x"86040000",
   200 => x"00ffffff",
   201 => x"ff00ffff",
   202 => x"ffff00ff",
   203 => x"ffffff00",
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


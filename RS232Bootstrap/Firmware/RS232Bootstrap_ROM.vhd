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
		maxAddrBit : integer := maxAddrBitBRAMLimit -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	areset : in std_logic := '0';
	from_zpu : in ZPU_ToROM;
	to_zpu : out ZPU_FromROM
);
end RS232Bootstrap_ROM;

architecture arch of RS232Bootstrap_ROM is

type ram_type is array(natural range 0 to ((2**(maxAddrBit+1))/4)-1) of std_logic_vector(wordSize-1 downto 0);

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
    18 => x"a080869c",
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
    31 => x"85d10400",
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
    42 => x"0d775574",
    43 => x"70840556",
    44 => x"08538054",
    45 => x"72982a73",
    46 => x"882b5452",
    47 => x"71802ea2",
    48 => x"38c00870",
    49 => x"882a7081",
    50 => x"06515151",
    51 => x"70802ef1",
    52 => x"3871c00c",
    53 => x"81168115",
    54 => x"55568374",
    55 => x"25d63871",
    56 => x"ca387583",
    57 => x"ffe0800c",
    58 => x"0298050d",
    59 => x"0402f805",
    60 => x"0dc00870",
    61 => x"892a7081",
    62 => x"06515252",
    63 => x"70802ef1",
    64 => x"387181ff",
    65 => x"0683ffe0",
    66 => x"800c0288",
    67 => x"050d0402",
    68 => x"fc050d73",
    69 => x"81df06c9",
    70 => x"05517080",
    71 => x"258438a7",
    72 => x"11517284",
    73 => x"2b710783",
    74 => x"ffe0800c",
    75 => x"0284050d",
    76 => x"0402f005",
    77 => x"0d029705",
    78 => x"a08080ae",
    79 => x"2d83ffe0",
    80 => x"a4088105",
    81 => x"83ffe0a4",
    82 => x"0c547380",
    83 => x"d32e0981",
    84 => x"06a23880",
    85 => x"0b83ffe0",
    86 => x"a40c800b",
    87 => x"83ffe094",
    88 => x"0c800b83",
    89 => x"ffe0a80c",
    90 => x"800b83ff",
    91 => x"e0900ca0",
    92 => x"8085cc04",
    93 => x"83ffe0a4",
    94 => x"08527181",
    95 => x"2e098106",
    96 => x"80c03883",
    97 => x"ffe09008",
    98 => x"7481df06",
    99 => x"c9055252",
   100 => x"70802584",
   101 => x"38a71151",
   102 => x"71842b71",
   103 => x"077083ff",
   104 => x"e0900c70",
   105 => x"52528372",
   106 => x"2585388a",
   107 => x"72315170",
   108 => x"10820583",
   109 => x"ffe09c0c",
   110 => x"80f40bc0",
   111 => x"0ca08085",
   112 => x"cc047183",
   113 => x"24a53883",
   114 => x"ffe0a808",
   115 => x"7481df06",
   116 => x"c9055252",
   117 => x"70802584",
   118 => x"38a71151",
   119 => x"71842b71",
   120 => x"0783ffe0",
   121 => x"a80ca080",
   122 => x"85cc0483",
   123 => x"ffe09c08",
   124 => x"83055171",
   125 => x"7124a538",
   126 => x"83ffe094",
   127 => x"087481df",
   128 => x"06c90552",
   129 => x"52708025",
   130 => x"8438a711",
   131 => x"5171842b",
   132 => x"710783ff",
   133 => x"e0940ca0",
   134 => x"80858a04",
   135 => x"83ffe090",
   136 => x"08ff1152",
   137 => x"53708226",
   138 => x"81933883",
   139 => x"ffe0a808",
   140 => x"10810551",
   141 => x"71712480",
   142 => x"dd3883ff",
   143 => x"e0a00874",
   144 => x"81df06c9",
   145 => x"05525270",
   146 => x"80258438",
   147 => x"a7115171",
   148 => x"842b7107",
   149 => x"7083ffe0",
   150 => x"a00c83ff",
   151 => x"e09808ff",
   152 => x"0583ffe0",
   153 => x"980c5283",
   154 => x"ffe09808",
   155 => x"802580dc",
   156 => x"3883ffe0",
   157 => x"94085171",
   158 => x"71a08080",
   159 => x"c32d83ff",
   160 => x"e0940881",
   161 => x"0583ffe0",
   162 => x"940c810b",
   163 => x"83ffe098",
   164 => x"0ca08085",
   165 => x"cc0483ff",
   166 => x"e09808b0",
   167 => x"3883ffe0",
   168 => x"a008842b",
   169 => x"7083ffe0",
   170 => x"a00c83ff",
   171 => x"e0940852",
   172 => x"527171a0",
   173 => x"8080c32d",
   174 => x"a08085cc",
   175 => x"04867325",
   176 => x"8b3880c2",
   177 => x"0bc00ca0",
   178 => x"80808c2d",
   179 => x"0290050d",
   180 => x"0402fc05",
   181 => x"0d80d251",
   182 => x"a0808181",
   183 => x"2d80e551",
   184 => x"a0808181",
   185 => x"2d80e151",
   186 => x"a0808181",
   187 => x"2d80e451",
   188 => x"a0808181",
   189 => x"2d80f951",
   190 => x"a0808181",
   191 => x"2d8a51a0",
   192 => x"8081812d",
   193 => x"a08081ed",
   194 => x"2d83ffe0",
   195 => x"800881ff",
   196 => x"0651a080",
   197 => x"82b12da0",
   198 => x"80868404",
   199 => x"00ffffff",
   200 => x"ff00ffff",
   201 => x"ffff00ff",
   202 => x"ffffff00",
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


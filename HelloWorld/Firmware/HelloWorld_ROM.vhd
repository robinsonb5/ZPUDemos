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

entity HelloWorld_ROM is
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
end HelloWorld_ROM;

architecture arch of HelloWorld_ROM is

type ram_type is array(natural range 0 to ((2**(maxAddrBitBRAM+1))/4)-1) of std_logic_vector(wordSize-1 downto 0);

shared variable ram : ram_type :=
(
     0 => x"0b0b0b88",
     1 => x"e5040000",
     2 => x"00000000",
     3 => x"00000000",
     4 => x"00000000",
     5 => x"00000000",
     6 => x"00000000",
     7 => x"00000000",
     8 => x"88088c08",
     9 => x"90080b0b",
    10 => x"0b88e108",
    11 => x"2d900c8c",
    12 => x"0c880c04",
    13 => x"00000000",
    14 => x"00000000",
    15 => x"00000000",
    16 => x"71fd0608",
    17 => x"72830609",
    18 => x"81058205",
    19 => x"832b2a83",
    20 => x"ffff0652",
    21 => x"04000000",
    22 => x"00000000",
    23 => x"00000000",
    24 => x"71fd0608",
    25 => x"83ffff73",
    26 => x"83060981",
    27 => x"05820583",
    28 => x"2b2b0906",
    29 => x"7383ffff",
    30 => x"0b0b0b0b",
    31 => x"83a50400",
    32 => x"72098105",
    33 => x"72057373",
    34 => x"09060906",
    35 => x"73097306",
    36 => x"070a8106",
    37 => x"53510400",
    38 => x"00000000",
    39 => x"00000000",
    40 => x"72722473",
    41 => x"732e0753",
    42 => x"51040000",
    43 => x"00000000",
    44 => x"00000000",
    45 => x"00000000",
    46 => x"00000000",
    47 => x"00000000",
    48 => x"71737109",
    49 => x"71068106",
    50 => x"09810572",
    51 => x"0a100a72",
    52 => x"0a100a31",
    53 => x"050a8106",
    54 => x"51515351",
    55 => x"04000000",
    56 => x"72722673",
    57 => x"732e0753",
    58 => x"51040000",
    59 => x"00000000",
    60 => x"00000000",
    61 => x"00000000",
    62 => x"00000000",
    63 => x"00000000",
    64 => x"00000000",
    65 => x"00000000",
    66 => x"00000000",
    67 => x"00000000",
    68 => x"00000000",
    69 => x"00000000",
    70 => x"00000000",
    71 => x"00000000",
    72 => x"0b0b0b88",
    73 => x"ba040000",
    74 => x"00000000",
    75 => x"00000000",
    76 => x"00000000",
    77 => x"00000000",
    78 => x"00000000",
    79 => x"00000000",
    80 => x"720a722b",
    81 => x"0a535104",
    82 => x"00000000",
    83 => x"00000000",
    84 => x"00000000",
    85 => x"00000000",
    86 => x"00000000",
    87 => x"00000000",
    88 => x"72729f06",
    89 => x"0981050b",
    90 => x"0b0b889f",
    91 => x"05040000",
    92 => x"00000000",
    93 => x"00000000",
    94 => x"00000000",
    95 => x"00000000",
    96 => x"72722aff",
    97 => x"739f062a",
    98 => x"0974090a",
    99 => x"8106ff05",
   100 => x"06075351",
   101 => x"04000000",
   102 => x"00000000",
   103 => x"00000000",
   104 => x"71715351",
   105 => x"04067383",
   106 => x"06098105",
   107 => x"8205832b",
   108 => x"0b2b0772",
   109 => x"fc060c51",
   110 => x"51040000",
   111 => x"00000000",
   112 => x"72098105",
   113 => x"72050970",
   114 => x"81050906",
   115 => x"0a810653",
   116 => x"51040000",
   117 => x"00000000",
   118 => x"00000000",
   119 => x"00000000",
   120 => x"72098105",
   121 => x"72050970",
   122 => x"81050906",
   123 => x"0a098106",
   124 => x"53510400",
   125 => x"00000000",
   126 => x"00000000",
   127 => x"00000000",
   128 => x"71098105",
   129 => x"52040000",
   130 => x"00000000",
   131 => x"00000000",
   132 => x"00000000",
   133 => x"00000000",
   134 => x"00000000",
   135 => x"00000000",
   136 => x"72720981",
   137 => x"05055351",
   138 => x"04000000",
   139 => x"00000000",
   140 => x"00000000",
   141 => x"00000000",
   142 => x"00000000",
   143 => x"00000000",
   144 => x"72097206",
   145 => x"73730906",
   146 => x"07535104",
   147 => x"00000000",
   148 => x"00000000",
   149 => x"00000000",
   150 => x"00000000",
   151 => x"00000000",
   152 => x"71fc0608",
   153 => x"72830609",
   154 => x"81058305",
   155 => x"1010102a",
   156 => x"81ff0652",
   157 => x"04000000",
   158 => x"00000000",
   159 => x"00000000",
   160 => x"71fc0608",
   161 => x"0b0b0b8e",
   162 => x"84738306",
   163 => x"10100508",
   164 => x"060b0b0b",
   165 => x"88a20400",
   166 => x"00000000",
   167 => x"00000000",
   168 => x"88088c08",
   169 => x"90087575",
   170 => x"0b0b0b8a",
   171 => x"872d5050",
   172 => x"88085690",
   173 => x"0c8c0c88",
   174 => x"0c510400",
   175 => x"00000000",
   176 => x"88088c08",
   177 => x"90087575",
   178 => x"0b0b0b8b",
   179 => x"b92d5050",
   180 => x"88085690",
   181 => x"0c8c0c88",
   182 => x"0c510400",
   183 => x"00000000",
   184 => x"72097081",
   185 => x"0509060a",
   186 => x"8106ff05",
   187 => x"70547106",
   188 => x"73097274",
   189 => x"05ff0506",
   190 => x"07515151",
   191 => x"04000000",
   192 => x"72097081",
   193 => x"0509060a",
   194 => x"098106ff",
   195 => x"05705471",
   196 => x"06730972",
   197 => x"7405ff05",
   198 => x"06075151",
   199 => x"51040000",
   200 => x"05ff0504",
   201 => x"00000000",
   202 => x"00000000",
   203 => x"00000000",
   204 => x"00000000",
   205 => x"00000000",
   206 => x"00000000",
   207 => x"00000000",
   208 => x"04000000",
   209 => x"00000000",
   210 => x"00000000",
   211 => x"00000000",
   212 => x"00000000",
   213 => x"00000000",
   214 => x"00000000",
   215 => x"00000000",
   216 => x"71810552",
   217 => x"04000000",
   218 => x"00000000",
   219 => x"00000000",
   220 => x"00000000",
   221 => x"00000000",
   222 => x"00000000",
   223 => x"00000000",
   224 => x"04000000",
   225 => x"00000000",
   226 => x"00000000",
   227 => x"00000000",
   228 => x"00000000",
   229 => x"00000000",
   230 => x"00000000",
   231 => x"00000000",
   232 => x"02840572",
   233 => x"10100552",
   234 => x"04000000",
   235 => x"00000000",
   236 => x"00000000",
   237 => x"00000000",
   238 => x"00000000",
   239 => x"00000000",
   240 => x"00000000",
   241 => x"00000000",
   242 => x"00000000",
   243 => x"00000000",
   244 => x"00000000",
   245 => x"00000000",
   246 => x"00000000",
   247 => x"00000000",
   248 => x"717105ff",
   249 => x"05715351",
   250 => x"020d0400",
   251 => x"00000000",
   252 => x"00000000",
   253 => x"00000000",
   254 => x"00000000",
   255 => x"00000000",
   256 => x"10101010",
   257 => x"10101010",
   258 => x"10101010",
   259 => x"10101010",
   260 => x"10101010",
   261 => x"10101010",
   262 => x"10101010",
   263 => x"10101053",
   264 => x"51047381",
   265 => x"ff067383",
   266 => x"06098105",
   267 => x"83051010",
   268 => x"102b0772",
   269 => x"fc060c51",
   270 => x"51047272",
   271 => x"80728106",
   272 => x"ff050972",
   273 => x"06057110",
   274 => x"52720a10",
   275 => x"0a5372ed",
   276 => x"38515153",
   277 => x"51040000",
   278 => x"80040088",
   279 => x"da040400",
   280 => x"00000004",
   281 => x"5e8ea470",
   282 => x"8ea4278b",
   283 => x"38807170",
   284 => x"8405530c",
   285 => x"88e70488",
   286 => x"da5188fd",
   287 => x"04803d0d",
   288 => x"8e9451ad",
   289 => x"3f80e33f",
   290 => x"880881ff",
   291 => x"0651833f",
   292 => x"f439ff3d",
   293 => x"0d7352c0",
   294 => x"0870882a",
   295 => x"70810651",
   296 => x"51517080",
   297 => x"2ef13871",
   298 => x"c00c7188",
   299 => x"0c833d0d",
   300 => x"04fd3d0d",
   301 => x"75537233",
   302 => x"7081ff06",
   303 => x"52527080",
   304 => x"2ea13871",
   305 => x"81ff0681",
   306 => x"145452c0",
   307 => x"0870882a",
   308 => x"70810651",
   309 => x"51517080",
   310 => x"2ef13871",
   311 => x"c00c8114",
   312 => x"54d43973",
   313 => x"880c853d",
   314 => x"0d04ff3d",
   315 => x"0dc00870",
   316 => x"892a7081",
   317 => x"06515252",
   318 => x"70802ef1",
   319 => x"387181ff",
   320 => x"06880c83",
   321 => x"3d0d0494",
   322 => x"0802940c",
   323 => x"f93d0d80",
   324 => x"0b9408fc",
   325 => x"050c9408",
   326 => x"88050880",
   327 => x"25ab3894",
   328 => x"08880508",
   329 => x"30940888",
   330 => x"050c800b",
   331 => x"9408f405",
   332 => x"0c9408fc",
   333 => x"05088838",
   334 => x"810b9408",
   335 => x"f4050c94",
   336 => x"08f40508",
   337 => x"9408fc05",
   338 => x"0c94088c",
   339 => x"05088025",
   340 => x"ab389408",
   341 => x"8c050830",
   342 => x"94088c05",
   343 => x"0c800b94",
   344 => x"08f0050c",
   345 => x"9408fc05",
   346 => x"08883881",
   347 => x"0b9408f0",
   348 => x"050c9408",
   349 => x"f0050894",
   350 => x"08fc050c",
   351 => x"80539408",
   352 => x"8c050852",
   353 => x"94088805",
   354 => x"085181a7",
   355 => x"3f880870",
   356 => x"9408f805",
   357 => x"0c549408",
   358 => x"fc050880",
   359 => x"2e8c3894",
   360 => x"08f80508",
   361 => x"309408f8",
   362 => x"050c9408",
   363 => x"f8050870",
   364 => x"880c5489",
   365 => x"3d0d940c",
   366 => x"04940802",
   367 => x"940cfb3d",
   368 => x"0d800b94",
   369 => x"08fc050c",
   370 => x"94088805",
   371 => x"08802593",
   372 => x"38940888",
   373 => x"05083094",
   374 => x"0888050c",
   375 => x"810b9408",
   376 => x"fc050c94",
   377 => x"088c0508",
   378 => x"80258c38",
   379 => x"94088c05",
   380 => x"08309408",
   381 => x"8c050c81",
   382 => x"5394088c",
   383 => x"05085294",
   384 => x"08880508",
   385 => x"51ad3f88",
   386 => x"08709408",
   387 => x"f8050c54",
   388 => x"9408fc05",
   389 => x"08802e8c",
   390 => x"389408f8",
   391 => x"05083094",
   392 => x"08f8050c",
   393 => x"9408f805",
   394 => x"0870880c",
   395 => x"54873d0d",
   396 => x"940c0494",
   397 => x"0802940c",
   398 => x"fd3d0d81",
   399 => x"0b9408fc",
   400 => x"050c800b",
   401 => x"9408f805",
   402 => x"0c94088c",
   403 => x"05089408",
   404 => x"88050827",
   405 => x"ac389408",
   406 => x"fc050880",
   407 => x"2ea33880",
   408 => x"0b94088c",
   409 => x"05082499",
   410 => x"3894088c",
   411 => x"05081094",
   412 => x"088c050c",
   413 => x"9408fc05",
   414 => x"08109408",
   415 => x"fc050cc9",
   416 => x"399408fc",
   417 => x"0508802e",
   418 => x"80c93894",
   419 => x"088c0508",
   420 => x"94088805",
   421 => x"0826a138",
   422 => x"94088805",
   423 => x"0894088c",
   424 => x"05083194",
   425 => x"0888050c",
   426 => x"9408f805",
   427 => x"089408fc",
   428 => x"05080794",
   429 => x"08f8050c",
   430 => x"9408fc05",
   431 => x"08812a94",
   432 => x"08fc050c",
   433 => x"94088c05",
   434 => x"08812a94",
   435 => x"088c050c",
   436 => x"ffaf3994",
   437 => x"08900508",
   438 => x"802e8f38",
   439 => x"94088805",
   440 => x"08709408",
   441 => x"f4050c51",
   442 => x"8d399408",
   443 => x"f8050870",
   444 => x"9408f405",
   445 => x"0c519408",
   446 => x"f4050888",
   447 => x"0c853d0d",
   448 => x"940c0400",
   449 => x"00ffffff",
   450 => x"ff00ffff",
   451 => x"ffff00ff",
   452 => x"ffffff00",
   453 => x"48656c6c",
   454 => x"6f2c2077",
   455 => x"6f726c64",
   456 => x"210a0064",
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


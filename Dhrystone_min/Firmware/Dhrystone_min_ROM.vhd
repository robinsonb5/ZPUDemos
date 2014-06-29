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

entity Dhrystone_min_ROM is
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
end Dhrystone_min_ROM;

architecture arch of Dhrystone_min_ROM is

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
   161 => x"0b0b0ba0",
   162 => x"e4738306",
   163 => x"10100508",
   164 => x"060b0b0b",
   165 => x"88a20400",
   166 => x"00000000",
   167 => x"00000000",
   168 => x"88088c08",
   169 => x"90087575",
   170 => x"0b0b0b99",
   171 => x"d62d5050",
   172 => x"88085690",
   173 => x"0c8c0c88",
   174 => x"0c510400",
   175 => x"00000000",
   176 => x"88088c08",
   177 => x"90087575",
   178 => x"0b0b0b9b",
   179 => x"882d5050",
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
   224 => x"00000000",
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
   278 => x"800488da",
   279 => x"04040000",
   280 => x"00000004",
   281 => x"5d88da0b",
   282 => x"90b504f0",
   283 => x"3d0d933d",
   284 => x"5c80707d",
   285 => x"7084055f",
   286 => x"08724040",
   287 => x"40587d70",
   288 => x"84055f08",
   289 => x"57805976",
   290 => x"982a7788",
   291 => x"2b585574",
   292 => x"802e83ce",
   293 => x"387c802e",
   294 => x"80c63880",
   295 => x"5d7480e4",
   296 => x"2e81e938",
   297 => x"7480f82e",
   298 => x"81e23874",
   299 => x"80e42e81",
   300 => x"ed387480",
   301 => x"e42680d9",
   302 => x"387480e3",
   303 => x"2eb838a5",
   304 => x"5183cf3f",
   305 => x"745183ca",
   306 => x"3f821858",
   307 => x"81195983",
   308 => x"7925ffb3",
   309 => x"3874ffa6",
   310 => x"387f880c",
   311 => x"923d0d04",
   312 => x"74a52e09",
   313 => x"81069738",
   314 => x"810b811a",
   315 => x"5a5d8379",
   316 => x"25ff9438",
   317 => x"e0397b84",
   318 => x"1d710857",
   319 => x"5d567451",
   320 => x"83903f81",
   321 => x"18811a5a",
   322 => x"58837925",
   323 => x"fef938c5",
   324 => x"397480f3",
   325 => x"2e82d238",
   326 => x"7480f82e",
   327 => x"098106ff",
   328 => x"9e387e0b",
   329 => x"0b0ba68c",
   330 => x"0b0b0b0b",
   331 => x"a5bc585c",
   332 => x"54805a79",
   333 => x"7f2482d0",
   334 => x"387381b0",
   335 => x"38b00b0b",
   336 => x"0b0ba5bc",
   337 => x"34811656",
   338 => x"ff165675",
   339 => x"337b7081",
   340 => x"055d3481",
   341 => x"1a5a750b",
   342 => x"0b0ba5bc",
   343 => x"2e098106",
   344 => x"e738807b",
   345 => x"34790b0b",
   346 => x"0ba68c57",
   347 => x"53ff1354",
   348 => x"807325fe",
   349 => x"d7387570",
   350 => x"81055733",
   351 => x"70525582",
   352 => x"913f8118",
   353 => x"74ff1656",
   354 => x"5458e539",
   355 => x"7b841d71",
   356 => x"08415d53",
   357 => x"7480e42e",
   358 => x"098106fe",
   359 => x"95387e0b",
   360 => x"0b0ba68c",
   361 => x"0b0b0b0b",
   362 => x"a5bc585c",
   363 => x"54805a79",
   364 => x"7f2481ca",
   365 => x"387380ef",
   366 => x"38b00b0b",
   367 => x"0b0ba5bc",
   368 => x"34811656",
   369 => x"ff165675",
   370 => x"337b7081",
   371 => x"055d3481",
   372 => x"1a5a750b",
   373 => x"0b0ba5bc",
   374 => x"2e098106",
   375 => x"e738807b",
   376 => x"34790b0b",
   377 => x"0ba68c57",
   378 => x"53ff8239",
   379 => x"907436a0",
   380 => x"f4055372",
   381 => x"33767081",
   382 => x"05583490",
   383 => x"74355473",
   384 => x"eb38750b",
   385 => x"0b0ba5bc",
   386 => x"2efed738",
   387 => x"ff165675",
   388 => x"337b7081",
   389 => x"055d3481",
   390 => x"1a5a750b",
   391 => x"0b0ba5bc",
   392 => x"2efebf38",
   393 => x"fea2398a",
   394 => x"7436a0f4",
   395 => x"05537233",
   396 => x"76708105",
   397 => x"58348a74",
   398 => x"355473eb",
   399 => x"38750b0b",
   400 => x"0ba5bc2e",
   401 => x"fe9c38ff",
   402 => x"16567533",
   403 => x"7b708105",
   404 => x"5d34811a",
   405 => x"5a750b0b",
   406 => x"0ba5bc2e",
   407 => x"ff8038fe",
   408 => x"e3397788",
   409 => x"0c923d0d",
   410 => x"047b841d",
   411 => x"71087054",
   412 => x"585d54bd",
   413 => x"3f800bff",
   414 => x"115553fd",
   415 => x"f339ad51",
   416 => x"913f7e30",
   417 => x"54feae39",
   418 => x"ad51873f",
   419 => x"7e3054fd",
   420 => x"a839ff3d",
   421 => x"0d7352c0",
   422 => x"0870882a",
   423 => x"70810651",
   424 => x"51517080",
   425 => x"2ef13871",
   426 => x"c00c7188",
   427 => x"0c833d0d",
   428 => x"04fb3d0d",
   429 => x"80785755",
   430 => x"75708405",
   431 => x"57085380",
   432 => x"5472982a",
   433 => x"73882b54",
   434 => x"5271802e",
   435 => x"a238c008",
   436 => x"70882a70",
   437 => x"81065151",
   438 => x"5170802e",
   439 => x"f13871c0",
   440 => x"0c811581",
   441 => x"15555583",
   442 => x"7425d638",
   443 => x"71ca3874",
   444 => x"880c873d",
   445 => x"0d04c808",
   446 => x"880c0480",
   447 => x"3d0d80c1",
   448 => x"0b80f5d8",
   449 => x"34800b80",
   450 => x"f7f00c70",
   451 => x"880c823d",
   452 => x"0d04ff3d",
   453 => x"0d800b80",
   454 => x"f5d83352",
   455 => x"527080c1",
   456 => x"2e993871",
   457 => x"80f7f008",
   458 => x"0780f7f0",
   459 => x"0c80c20b",
   460 => x"80f5dc34",
   461 => x"70880c83",
   462 => x"3d0d0481",
   463 => x"0b80f7f0",
   464 => x"080780f7",
   465 => x"f00c80c2",
   466 => x"0b80f5dc",
   467 => x"3470880c",
   468 => x"833d0d04",
   469 => x"fd3d0d75",
   470 => x"70088a05",
   471 => x"535380f5",
   472 => x"d8335170",
   473 => x"80c12e8b",
   474 => x"3873f338",
   475 => x"70880c85",
   476 => x"3d0d04ff",
   477 => x"127080f5",
   478 => x"d4083174",
   479 => x"0c880c85",
   480 => x"3d0d04fc",
   481 => x"3d0d80f6",
   482 => x"80085574",
   483 => x"802e8c38",
   484 => x"76750871",
   485 => x"0c80f680",
   486 => x"0856548c",
   487 => x"155380f5",
   488 => x"d408528a",
   489 => x"51889c3f",
   490 => x"73880c86",
   491 => x"3d0d04fb",
   492 => x"3d0d7770",
   493 => x"085656b0",
   494 => x"5380f680",
   495 => x"08527451",
   496 => x"8ef23f85",
   497 => x"0b8c170c",
   498 => x"850b8c16",
   499 => x"0c750875",
   500 => x"0c80f680",
   501 => x"08547380",
   502 => x"2e8a3873",
   503 => x"08750c80",
   504 => x"f6800854",
   505 => x"8c145380",
   506 => x"f5d40852",
   507 => x"8a5187d3",
   508 => x"3f841508",
   509 => x"ad38860b",
   510 => x"8c160c88",
   511 => x"15528816",
   512 => x"085186df",
   513 => x"3f80f680",
   514 => x"08700876",
   515 => x"0c548c15",
   516 => x"7054548a",
   517 => x"52730851",
   518 => x"87a93f73",
   519 => x"880c873d",
   520 => x"0d047508",
   521 => x"54b05373",
   522 => x"5275518e",
   523 => x"873f7388",
   524 => x"0c873d0d",
   525 => x"04f33d0d",
   526 => x"80f4ec0b",
   527 => x"80f5a00c",
   528 => x"80f5a40b",
   529 => x"80f6800c",
   530 => x"80f4ec0b",
   531 => x"80f5a40c",
   532 => x"800b80f5",
   533 => x"a40b8405",
   534 => x"0c820b80",
   535 => x"f5a40b88",
   536 => x"050ca80b",
   537 => x"80f5a40b",
   538 => x"8c050c9f",
   539 => x"53a18852",
   540 => x"80f5b451",
   541 => x"8dbe3f9f",
   542 => x"53a1a852",
   543 => x"80f7d051",
   544 => x"8db23f8a",
   545 => x"0bb3b80c",
   546 => x"a48851f7",
   547 => x"de3fa1c8",
   548 => x"51f7d83f",
   549 => x"a48851f7",
   550 => x"d23fa5b8",
   551 => x"08802e83",
   552 => x"e638a1f8",
   553 => x"51f7c43f",
   554 => x"a48851f7",
   555 => x"be3fa5b4",
   556 => x"0852a2a4",
   557 => x"51f7b43f",
   558 => x"c80870a6",
   559 => x"d80c5681",
   560 => x"58800ba5",
   561 => x"b4082582",
   562 => x"c4388c3d",
   563 => x"5b80c10b",
   564 => x"80f5d834",
   565 => x"810b80f7",
   566 => x"f00c80c2",
   567 => x"0b80f5dc",
   568 => x"34825c83",
   569 => x"5a9f53a2",
   570 => x"d45280f5",
   571 => x"e0518cc4",
   572 => x"3f815d80",
   573 => x"0b80f5e0",
   574 => x"5380f7d0",
   575 => x"525586e7",
   576 => x"3f880875",
   577 => x"2e098106",
   578 => x"83388155",
   579 => x"7480f7f0",
   580 => x"0c7b7057",
   581 => x"55748325",
   582 => x"a0387410",
   583 => x"1015fd05",
   584 => x"5e8f3dfc",
   585 => x"05538352",
   586 => x"75518597",
   587 => x"3f811c70",
   588 => x"5d705755",
   589 => x"837524e2",
   590 => x"387d5474",
   591 => x"53a6dc52",
   592 => x"80f68851",
   593 => x"858d3f80",
   594 => x"f6800870",
   595 => x"085757b0",
   596 => x"53765275",
   597 => x"518bdd3f",
   598 => x"850b8c18",
   599 => x"0c850b8c",
   600 => x"170c7608",
   601 => x"760c80f6",
   602 => x"80085574",
   603 => x"802e8a38",
   604 => x"7408760c",
   605 => x"80f68008",
   606 => x"558c1553",
   607 => x"80f5d408",
   608 => x"528a5184",
   609 => x"be3f8416",
   610 => x"08839e38",
   611 => x"860b8c17",
   612 => x"0c881652",
   613 => x"88170851",
   614 => x"83c93f80",
   615 => x"f6800870",
   616 => x"08770c57",
   617 => x"8c167054",
   618 => x"558a5274",
   619 => x"08518493",
   620 => x"3f80c10b",
   621 => x"80f5dc33",
   622 => x"56567575",
   623 => x"26a23880",
   624 => x"c3527551",
   625 => x"84f73f88",
   626 => x"087d2e82",
   627 => x"af388116",
   628 => x"7081ff06",
   629 => x"80f5dc33",
   630 => x"52575574",
   631 => x"7627e038",
   632 => x"7d7a7d29",
   633 => x"35705d8a",
   634 => x"0580f5d8",
   635 => x"3380f5d4",
   636 => x"08595755",
   637 => x"7580c12e",
   638 => x"82c73878",
   639 => x"f7388118",
   640 => x"58a5b408",
   641 => x"7825fdc5",
   642 => x"38a6d808",
   643 => x"56c80870",
   644 => x"80f59c0c",
   645 => x"70773170",
   646 => x"a6d40c53",
   647 => x"a2f4525b",
   648 => x"f4c93fa6",
   649 => x"d4085680",
   650 => x"f7762580",
   651 => x"e038a5b4",
   652 => x"08707787",
   653 => x"e82935a6",
   654 => x"cc0c7671",
   655 => x"87e82935",
   656 => x"a6d00c76",
   657 => x"7184b929",
   658 => x"3580f684",
   659 => x"0c5aa384",
   660 => x"51f4983f",
   661 => x"a6cc0852",
   662 => x"a3b451f4",
   663 => x"8e3fa3bc",
   664 => x"51f4883f",
   665 => x"a6d00852",
   666 => x"a3b451f3",
   667 => x"fe3f80f6",
   668 => x"840852a3",
   669 => x"ec51f3f3",
   670 => x"3fa48851",
   671 => x"f3ed3f80",
   672 => x"0b880c8f",
   673 => x"3d0d04a4",
   674 => x"8c51fc99",
   675 => x"39a4bc51",
   676 => x"f3d93fa4",
   677 => x"f451f3d3",
   678 => x"3fa48851",
   679 => x"f3cd3fa6",
   680 => x"d408a5b4",
   681 => x"08707287",
   682 => x"e82935a6",
   683 => x"cc0c7171",
   684 => x"87e82935",
   685 => x"a6d00c71",
   686 => x"7184b929",
   687 => x"3580f684",
   688 => x"0c5b56a3",
   689 => x"8451f3a3",
   690 => x"3fa6cc08",
   691 => x"52a3b451",
   692 => x"f3993fa3",
   693 => x"bc51f393",
   694 => x"3fa6d008",
   695 => x"52a3b451",
   696 => x"f3893f80",
   697 => x"f6840852",
   698 => x"a3ec51f2",
   699 => x"fe3fa488",
   700 => x"51f2f83f",
   701 => x"800b880c",
   702 => x"8f3d0d04",
   703 => x"8f3df805",
   704 => x"52805180",
   705 => x"de3f9f53",
   706 => x"a5945280",
   707 => x"f5e05188",
   708 => x"a33f7778",
   709 => x"80f5d40c",
   710 => x"81177081",
   711 => x"ff0680f5",
   712 => x"dc335258",
   713 => x"565afdb3",
   714 => x"39760856",
   715 => x"b0537552",
   716 => x"76518880",
   717 => x"3f80c10b",
   718 => x"80f5dc33",
   719 => x"5656fcfa",
   720 => x"39ff1570",
   721 => x"78317c0c",
   722 => x"598059fd",
   723 => x"b139ff3d",
   724 => x"0d738232",
   725 => x"70307072",
   726 => x"07802588",
   727 => x"0c525283",
   728 => x"3d0d04fe",
   729 => x"3d0d7476",
   730 => x"71535452",
   731 => x"71822e83",
   732 => x"38835171",
   733 => x"812e9a38",
   734 => x"8172269f",
   735 => x"3871822e",
   736 => x"b8387184",
   737 => x"2ea93870",
   738 => x"730c7088",
   739 => x"0c843d0d",
   740 => x"0480e40b",
   741 => x"80f5d408",
   742 => x"258b3880",
   743 => x"730c7088",
   744 => x"0c843d0d",
   745 => x"0483730c",
   746 => x"70880c84",
   747 => x"3d0d0482",
   748 => x"730c7088",
   749 => x"0c843d0d",
   750 => x"0481730c",
   751 => x"70880c84",
   752 => x"3d0d0480",
   753 => x"3d0d7474",
   754 => x"14820571",
   755 => x"0c880c82",
   756 => x"3d0d04f7",
   757 => x"3d0d7b7d",
   758 => x"7f618512",
   759 => x"70822b75",
   760 => x"11707471",
   761 => x"70840553",
   762 => x"0c5a5a5d",
   763 => x"5b760c79",
   764 => x"80f8180c",
   765 => x"79861252",
   766 => x"57585a5a",
   767 => x"76762499",
   768 => x"3876b329",
   769 => x"822b7911",
   770 => x"51537673",
   771 => x"70840555",
   772 => x"0c811454",
   773 => x"757425f2",
   774 => x"387681cc",
   775 => x"2919fc11",
   776 => x"088105fc",
   777 => x"120c7a19",
   778 => x"70089fa0",
   779 => x"130c5856",
   780 => x"850b80f5",
   781 => x"d40c7588",
   782 => x"0c8b3d0d",
   783 => x"04fe3d0d",
   784 => x"02930533",
   785 => x"51800284",
   786 => x"05970533",
   787 => x"54527073",
   788 => x"2e883871",
   789 => x"880c843d",
   790 => x"0d047080",
   791 => x"f5d83481",
   792 => x"0b880c84",
   793 => x"3d0d04f8",
   794 => x"3d0d7a7c",
   795 => x"5956820b",
   796 => x"83195555",
   797 => x"74167033",
   798 => x"75335b51",
   799 => x"5372792e",
   800 => x"80c63880",
   801 => x"c10b8116",
   802 => x"81165656",
   803 => x"57827525",
   804 => x"e338ffa9",
   805 => x"177081ff",
   806 => x"06555973",
   807 => x"82268338",
   808 => x"87558153",
   809 => x"7680d22e",
   810 => x"98387752",
   811 => x"7551869d",
   812 => x"3f805372",
   813 => x"88082589",
   814 => x"38871580",
   815 => x"f5d40c81",
   816 => x"5372880c",
   817 => x"8a3d0d04",
   818 => x"7280f5d8",
   819 => x"34827525",
   820 => x"ffa238ff",
   821 => x"bd399408",
   822 => x"02940cf9",
   823 => x"3d0d800b",
   824 => x"9408fc05",
   825 => x"0c940888",
   826 => x"05088025",
   827 => x"ab389408",
   828 => x"88050830",
   829 => x"94088805",
   830 => x"0c800b94",
   831 => x"08f4050c",
   832 => x"9408fc05",
   833 => x"08883881",
   834 => x"0b9408f4",
   835 => x"050c9408",
   836 => x"f4050894",
   837 => x"08fc050c",
   838 => x"94088c05",
   839 => x"088025ab",
   840 => x"3894088c",
   841 => x"05083094",
   842 => x"088c050c",
   843 => x"800b9408",
   844 => x"f0050c94",
   845 => x"08fc0508",
   846 => x"8838810b",
   847 => x"9408f005",
   848 => x"0c9408f0",
   849 => x"05089408",
   850 => x"fc050c80",
   851 => x"5394088c",
   852 => x"05085294",
   853 => x"08880508",
   854 => x"5181a73f",
   855 => x"88087094",
   856 => x"08f8050c",
   857 => x"549408fc",
   858 => x"0508802e",
   859 => x"8c389408",
   860 => x"f8050830",
   861 => x"9408f805",
   862 => x"0c9408f8",
   863 => x"05087088",
   864 => x"0c54893d",
   865 => x"0d940c04",
   866 => x"94080294",
   867 => x"0cfb3d0d",
   868 => x"800b9408",
   869 => x"fc050c94",
   870 => x"08880508",
   871 => x"80259338",
   872 => x"94088805",
   873 => x"08309408",
   874 => x"88050c81",
   875 => x"0b9408fc",
   876 => x"050c9408",
   877 => x"8c050880",
   878 => x"258c3894",
   879 => x"088c0508",
   880 => x"3094088c",
   881 => x"050c8153",
   882 => x"94088c05",
   883 => x"08529408",
   884 => x"88050851",
   885 => x"ad3f8808",
   886 => x"709408f8",
   887 => x"050c5494",
   888 => x"08fc0508",
   889 => x"802e8c38",
   890 => x"9408f805",
   891 => x"08309408",
   892 => x"f8050c94",
   893 => x"08f80508",
   894 => x"70880c54",
   895 => x"873d0d94",
   896 => x"0c049408",
   897 => x"02940cfd",
   898 => x"3d0d810b",
   899 => x"9408fc05",
   900 => x"0c800b94",
   901 => x"08f8050c",
   902 => x"94088c05",
   903 => x"08940888",
   904 => x"050827ac",
   905 => x"389408fc",
   906 => x"0508802e",
   907 => x"a338800b",
   908 => x"94088c05",
   909 => x"08249938",
   910 => x"94088c05",
   911 => x"08109408",
   912 => x"8c050c94",
   913 => x"08fc0508",
   914 => x"109408fc",
   915 => x"050cc939",
   916 => x"9408fc05",
   917 => x"08802e80",
   918 => x"c9389408",
   919 => x"8c050894",
   920 => x"08880508",
   921 => x"26a13894",
   922 => x"08880508",
   923 => x"94088c05",
   924 => x"08319408",
   925 => x"88050c94",
   926 => x"08f80508",
   927 => x"9408fc05",
   928 => x"08079408",
   929 => x"f8050c94",
   930 => x"08fc0508",
   931 => x"812a9408",
   932 => x"fc050c94",
   933 => x"088c0508",
   934 => x"812a9408",
   935 => x"8c050cff",
   936 => x"af399408",
   937 => x"90050880",
   938 => x"2e8f3894",
   939 => x"08880508",
   940 => x"709408f4",
   941 => x"050c518d",
   942 => x"399408f8",
   943 => x"05087094",
   944 => x"08f4050c",
   945 => x"519408f4",
   946 => x"0508880c",
   947 => x"853d0d94",
   948 => x"0c049408",
   949 => x"02940cff",
   950 => x"3d0d800b",
   951 => x"9408fc05",
   952 => x"0c940888",
   953 => x"05088106",
   954 => x"ff117009",
   955 => x"7094088c",
   956 => x"05080694",
   957 => x"08fc0508",
   958 => x"119408fc",
   959 => x"050c9408",
   960 => x"88050881",
   961 => x"2a940888",
   962 => x"050c9408",
   963 => x"8c050810",
   964 => x"94088c05",
   965 => x"0c515151",
   966 => x"51940888",
   967 => x"0508802e",
   968 => x"8438ffbd",
   969 => x"399408fc",
   970 => x"05087088",
   971 => x"0c51833d",
   972 => x"0d940c04",
   973 => x"fc3d0d76",
   974 => x"70797b55",
   975 => x"5555558f",
   976 => x"72278c38",
   977 => x"72750783",
   978 => x"06517080",
   979 => x"2ea738ff",
   980 => x"125271ff",
   981 => x"2e983872",
   982 => x"70810554",
   983 => x"33747081",
   984 => x"055634ff",
   985 => x"125271ff",
   986 => x"2e098106",
   987 => x"ea387488",
   988 => x"0c863d0d",
   989 => x"04745172",
   990 => x"70840554",
   991 => x"08717084",
   992 => x"05530c72",
   993 => x"70840554",
   994 => x"08717084",
   995 => x"05530c72",
   996 => x"70840554",
   997 => x"08717084",
   998 => x"05530c72",
   999 => x"70840554",
  1000 => x"08717084",
  1001 => x"05530cf0",
  1002 => x"1252718f",
  1003 => x"26c93883",
  1004 => x"72279538",
  1005 => x"72708405",
  1006 => x"54087170",
  1007 => x"8405530c",
  1008 => x"fc125271",
  1009 => x"8326ed38",
  1010 => x"7054ff83",
  1011 => x"39fb3d0d",
  1012 => x"77797072",
  1013 => x"07830653",
  1014 => x"54527093",
  1015 => x"38717373",
  1016 => x"08545654",
  1017 => x"7173082e",
  1018 => x"80c43873",
  1019 => x"75545271",
  1020 => x"337081ff",
  1021 => x"06525470",
  1022 => x"802e9d38",
  1023 => x"72335570",
  1024 => x"752e0981",
  1025 => x"06953881",
  1026 => x"12811471",
  1027 => x"337081ff",
  1028 => x"06545654",
  1029 => x"5270e538",
  1030 => x"72335573",
  1031 => x"81ff0675",
  1032 => x"81ff0671",
  1033 => x"7131880c",
  1034 => x"5252873d",
  1035 => x"0d047109",
  1036 => x"70f7fbfd",
  1037 => x"ff140670",
  1038 => x"f8848281",
  1039 => x"80065151",
  1040 => x"51709738",
  1041 => x"84148416",
  1042 => x"71085456",
  1043 => x"54717508",
  1044 => x"2edc3873",
  1045 => x"755452ff",
  1046 => x"9639800b",
  1047 => x"880c873d",
  1048 => x"0d040000",
  1049 => x"00ffffff",
  1050 => x"ff00ffff",
  1051 => x"ffff00ff",
  1052 => x"ffffff00",
  1053 => x"30313233",
  1054 => x"34353637",
  1055 => x"38394142",
  1056 => x"43444546",
  1057 => x"00000000",
  1058 => x"44485259",
  1059 => x"53544f4e",
  1060 => x"45205052",
  1061 => x"4f475241",
  1062 => x"4d2c2053",
  1063 => x"4f4d4520",
  1064 => x"53545249",
  1065 => x"4e470000",
  1066 => x"44485259",
  1067 => x"53544f4e",
  1068 => x"45205052",
  1069 => x"4f475241",
  1070 => x"4d2c2031",
  1071 => x"27535420",
  1072 => x"53545249",
  1073 => x"4e470000",
  1074 => x"44687279",
  1075 => x"73746f6e",
  1076 => x"65204265",
  1077 => x"6e63686d",
  1078 => x"61726b2c",
  1079 => x"20566572",
  1080 => x"73696f6e",
  1081 => x"20322e31",
  1082 => x"20284c61",
  1083 => x"6e677561",
  1084 => x"67653a20",
  1085 => x"43290a00",
  1086 => x"50726f67",
  1087 => x"72616d20",
  1088 => x"636f6d70",
  1089 => x"696c6564",
  1090 => x"20776974",
  1091 => x"68202772",
  1092 => x"65676973",
  1093 => x"74657227",
  1094 => x"20617474",
  1095 => x"72696275",
  1096 => x"74650a00",
  1097 => x"45786563",
  1098 => x"7574696f",
  1099 => x"6e207374",
  1100 => x"61727473",
  1101 => x"2c202564",
  1102 => x"2072756e",
  1103 => x"73207468",
  1104 => x"726f7567",
  1105 => x"68204468",
  1106 => x"72797374",
  1107 => x"6f6e650a",
  1108 => x"00000000",
  1109 => x"44485259",
  1110 => x"53544f4e",
  1111 => x"45205052",
  1112 => x"4f475241",
  1113 => x"4d2c2032",
  1114 => x"274e4420",
  1115 => x"53545249",
  1116 => x"4e470000",
  1117 => x"55736572",
  1118 => x"2074696d",
  1119 => x"653a2025",
  1120 => x"640a0000",
  1121 => x"4d696372",
  1122 => x"6f736563",
  1123 => x"6f6e6473",
  1124 => x"20666f72",
  1125 => x"206f6e65",
  1126 => x"2072756e",
  1127 => x"20746872",
  1128 => x"6f756768",
  1129 => x"20446872",
  1130 => x"7973746f",
  1131 => x"6e653a20",
  1132 => x"00000000",
  1133 => x"2564200a",
  1134 => x"00000000",
  1135 => x"44687279",
  1136 => x"73746f6e",
  1137 => x"65732070",
  1138 => x"65722053",
  1139 => x"65636f6e",
  1140 => x"643a2020",
  1141 => x"20202020",
  1142 => x"20202020",
  1143 => x"20202020",
  1144 => x"20202020",
  1145 => x"20202020",
  1146 => x"00000000",
  1147 => x"56415820",
  1148 => x"4d495053",
  1149 => x"20726174",
  1150 => x"696e6720",
  1151 => x"2a203130",
  1152 => x"3030203d",
  1153 => x"20256420",
  1154 => x"0a000000",
  1155 => x"50726f67",
  1156 => x"72616d20",
  1157 => x"636f6d70",
  1158 => x"696c6564",
  1159 => x"20776974",
  1160 => x"686f7574",
  1161 => x"20277265",
  1162 => x"67697374",
  1163 => x"65722720",
  1164 => x"61747472",
  1165 => x"69627574",
  1166 => x"650a0000",
  1167 => x"4d656173",
  1168 => x"75726564",
  1169 => x"2074696d",
  1170 => x"6520746f",
  1171 => x"6f20736d",
  1172 => x"616c6c20",
  1173 => x"746f206f",
  1174 => x"62746169",
  1175 => x"6e206d65",
  1176 => x"616e696e",
  1177 => x"6766756c",
  1178 => x"20726573",
  1179 => x"756c7473",
  1180 => x"0a000000",
  1181 => x"506c6561",
  1182 => x"73652069",
  1183 => x"6e637265",
  1184 => x"61736520",
  1185 => x"6e756d62",
  1186 => x"6572206f",
  1187 => x"66207275",
  1188 => x"6e730a00",
  1189 => x"44485259",
  1190 => x"53544f4e",
  1191 => x"45205052",
  1192 => x"4f475241",
  1193 => x"4d2c2033",
  1194 => x"27524420",
  1195 => x"53545249",
  1196 => x"4e470000",
  1197 => x"000061a8",
  1198 => x"00000000",
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


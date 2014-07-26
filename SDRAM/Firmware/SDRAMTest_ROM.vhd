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

entity SDRAMTest_ROM is
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
end SDRAMTest_ROM;

architecture arch of SDRAMTest_ROM is

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
    19 => x"90ec7383",
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
    32 => x"8dd80400",
    33 => x"02c0050d",
    34 => x"0280c405",
    35 => x"5b80707c",
    36 => x"7084055e",
    37 => x"08725f5f",
    38 => x"5f5a7c70",
    39 => x"84055e08",
    40 => x"57805976",
    41 => x"982a7788",
    42 => x"2b585574",
    43 => x"802e82f3",
    44 => x"387b802e",
    45 => x"80d33880",
    46 => x"5c7480e4",
    47 => x"2e81de38",
    48 => x"7480f82e",
    49 => x"81d73874",
    50 => x"80e42e81",
    51 => x"e2387480",
    52 => x"e42680f1",
    53 => x"387480e3",
    54 => x"2e80c838",
    55 => x"a5518480",
    56 => x"8085882d",
    57 => x"74518480",
    58 => x"8085882d",
    59 => x"821a811a",
    60 => x"5a5a8379",
    61 => x"25ffac38",
    62 => x"74ff9f38",
    63 => x"7e848080",
    64 => x"96f80c02",
    65 => x"80c0050d",
    66 => x"0474a52e",
    67 => x"0981069b",
    68 => x"38810b81",
    69 => x"1a5a5c83",
    70 => x"7925ff87",
    71 => x"38848080",
    72 => x"81f8047a",
    73 => x"841c7108",
    74 => x"575c5474",
    75 => x"51848080",
    76 => x"85882d81",
    77 => x"1a811a5a",
    78 => x"5a837925",
    79 => x"fee53884",
    80 => x"808081f8",
    81 => x"047480f3",
    82 => x"2e81e538",
    83 => x"7480f82e",
    84 => x"098106ff",
    85 => x"87387d53",
    86 => x"8058777e",
    87 => x"24829638",
    88 => x"72802e81",
    89 => x"f9388756",
    90 => x"729c2a73",
    91 => x"842b5452",
    92 => x"71802e83",
    93 => x"388158b7",
    94 => x"12547189",
    95 => x"248438b0",
    96 => x"12547780",
    97 => x"f038ff16",
    98 => x"56758025",
    99 => x"db388119",
   100 => x"59837925",
   101 => x"fe8d3884",
   102 => x"808081f8",
   103 => x"047a841c",
   104 => x"7108405c",
   105 => x"527480e4",
   106 => x"2e098106",
   107 => x"fea0387d",
   108 => x"54805877",
   109 => x"7e248195",
   110 => x"3873802e",
   111 => x"81a03887",
   112 => x"56739c2a",
   113 => x"74842b55",
   114 => x"5271802e",
   115 => x"83388158",
   116 => x"b7125371",
   117 => x"89248438",
   118 => x"b0125377",
   119 => x"af38ff16",
   120 => x"56758025",
   121 => x"dc388119",
   122 => x"59837925",
   123 => x"fdb53884",
   124 => x"808081f8",
   125 => x"04735184",
   126 => x"80808588",
   127 => x"2dff1656",
   128 => x"758025fe",
   129 => x"e3388480",
   130 => x"80838e04",
   131 => x"72518480",
   132 => x"8085882d",
   133 => x"ff165675",
   134 => x"8025ffa5",
   135 => x"38848080",
   136 => x"83e60479",
   137 => x"84808096",
   138 => x"f80c0280",
   139 => x"c0050d04",
   140 => x"7a841c71",
   141 => x"08535c53",
   142 => x"84808085",
   143 => x"ad2d8119",
   144 => x"59837925",
   145 => x"fcdd3884",
   146 => x"808081f8",
   147 => x"04ad5184",
   148 => x"80808588",
   149 => x"2d7d0981",
   150 => x"055473fe",
   151 => x"e238b051",
   152 => x"84808085",
   153 => x"882d8119",
   154 => x"59837925",
   155 => x"fcb53884",
   156 => x"808081f8",
   157 => x"04ad5184",
   158 => x"80808588",
   159 => x"2d7d0981",
   160 => x"05538480",
   161 => x"8082e004",
   162 => x"02f8050d",
   163 => x"7352c008",
   164 => x"70882a70",
   165 => x"81065151",
   166 => x"5170802e",
   167 => x"f13871c0",
   168 => x"0c718480",
   169 => x"8096f80c",
   170 => x"0288050d",
   171 => x"0402e805",
   172 => x"0d807857",
   173 => x"55757084",
   174 => x"05570853",
   175 => x"80547298",
   176 => x"2a73882b",
   177 => x"54527180",
   178 => x"2ea238c0",
   179 => x"0870882a",
   180 => x"70810651",
   181 => x"51517080",
   182 => x"2ef13871",
   183 => x"c00c8115",
   184 => x"81155555",
   185 => x"837425d6",
   186 => x"3871ca38",
   187 => x"74848080",
   188 => x"96f80c02",
   189 => x"98050d04",
   190 => x"02f4050d",
   191 => x"74765253",
   192 => x"80712590",
   193 => x"38705272",
   194 => x"70840554",
   195 => x"08ff1353",
   196 => x"5171f438",
   197 => x"028c050d",
   198 => x"0402d405",
   199 => x"0d7c7e5c",
   200 => x"58810b84",
   201 => x"808090fc",
   202 => x"585a8359",
   203 => x"7608780c",
   204 => x"77087708",
   205 => x"56547375",
   206 => x"2e943877",
   207 => x"08537452",
   208 => x"84808091",
   209 => x"8c518480",
   210 => x"8081842d",
   211 => x"805a7756",
   212 => x"807b2590",
   213 => x"387a5575",
   214 => x"70840557",
   215 => x"08ff1656",
   216 => x"5474f438",
   217 => x"77087708",
   218 => x"56567575",
   219 => x"2e943877",
   220 => x"08537452",
   221 => x"84808091",
   222 => x"cc518480",
   223 => x"8081842d",
   224 => x"805aff19",
   225 => x"84185859",
   226 => x"788025ff",
   227 => x"9f387984",
   228 => x"808096f8",
   229 => x"0c02ac05",
   230 => x"0d0402e4",
   231 => x"050d787a",
   232 => x"55568157",
   233 => x"85aad5aa",
   234 => x"d5760cfa",
   235 => x"d5aad5aa",
   236 => x"0b8c170c",
   237 => x"cc7634b3",
   238 => x"0b8f1734",
   239 => x"75085372",
   240 => x"fce2d5aa",
   241 => x"d52e9238",
   242 => x"75085284",
   243 => x"8080928c",
   244 => x"51848080",
   245 => x"81842d80",
   246 => x"578c1608",
   247 => x"5574fad5",
   248 => x"aad4b32e",
   249 => x"93388c16",
   250 => x"08528480",
   251 => x"8092c851",
   252 => x"84808081",
   253 => x"842d8057",
   254 => x"75558074",
   255 => x"258e3874",
   256 => x"70840556",
   257 => x"08ff1555",
   258 => x"5373f438",
   259 => x"75085473",
   260 => x"fce2d5aa",
   261 => x"d52e9238",
   262 => x"75085284",
   263 => x"80809384",
   264 => x"51848080",
   265 => x"81842d80",
   266 => x"578c1608",
   267 => x"5372fad5",
   268 => x"aad4b32e",
   269 => x"93388c16",
   270 => x"08528480",
   271 => x"8093c051",
   272 => x"84808081",
   273 => x"842d8057",
   274 => x"76848080",
   275 => x"96f80c02",
   276 => x"9c050d04",
   277 => x"02c4050d",
   278 => x"605b8062",
   279 => x"90808029",
   280 => x"ff058480",
   281 => x"8093fc53",
   282 => x"405a8480",
   283 => x"8081842d",
   284 => x"80e1b357",
   285 => x"80fe5eae",
   286 => x"51848080",
   287 => x"85882d76",
   288 => x"1070962a",
   289 => x"81065657",
   290 => x"74802e85",
   291 => x"38768107",
   292 => x"5776952a",
   293 => x"81065877",
   294 => x"802e8538",
   295 => x"76813257",
   296 => x"7877077f",
   297 => x"06775e59",
   298 => x"8fffff58",
   299 => x"76bfffff",
   300 => x"06707a32",
   301 => x"822b7c11",
   302 => x"5157760c",
   303 => x"76107096",
   304 => x"2a810656",
   305 => x"5774802e",
   306 => x"85387681",
   307 => x"07577695",
   308 => x"2a810655",
   309 => x"74802e85",
   310 => x"38768132",
   311 => x"57ff1858",
   312 => x"778025c8",
   313 => x"387c578f",
   314 => x"ffff5876",
   315 => x"bfffff06",
   316 => x"707a3282",
   317 => x"2b7c0570",
   318 => x"08575e56",
   319 => x"74762e80",
   320 => x"ea38807a",
   321 => x"53848080",
   322 => x"948c525c",
   323 => x"84808081",
   324 => x"842d7454",
   325 => x"75537552",
   326 => x"84808094",
   327 => x"a0518480",
   328 => x"8081842d",
   329 => x"7b5a7610",
   330 => x"70962a81",
   331 => x"06575775",
   332 => x"802e8538",
   333 => x"76810757",
   334 => x"76952a81",
   335 => x"06557480",
   336 => x"2e853876",
   337 => x"813257ff",
   338 => x"18587780",
   339 => x"25ff9c38",
   340 => x"ff1e5e7d",
   341 => x"fea1388a",
   342 => x"51848080",
   343 => x"85882d7b",
   344 => x"84808096",
   345 => x"f80c02bc",
   346 => x"050d0481",
   347 => x"1a5a8480",
   348 => x"808aa604",
   349 => x"02cc050d",
   350 => x"7e605e58",
   351 => x"815a805b",
   352 => x"80c07a58",
   353 => x"5c85ada9",
   354 => x"89bb780c",
   355 => x"79598156",
   356 => x"97557676",
   357 => x"07822b78",
   358 => x"11515485",
   359 => x"ada989bb",
   360 => x"740c7510",
   361 => x"ff165656",
   362 => x"748025e6",
   363 => x"38761081",
   364 => x"1a5a5798",
   365 => x"7925d738",
   366 => x"7756807d",
   367 => x"2590387c",
   368 => x"55757084",
   369 => x"055708ff",
   370 => x"16565474",
   371 => x"f4388157",
   372 => x"ff8787a5",
   373 => x"c3780c97",
   374 => x"5976822b",
   375 => x"78117008",
   376 => x"5f56567c",
   377 => x"ff8787a5",
   378 => x"c32e80cc",
   379 => x"38740854",
   380 => x"7385ada9",
   381 => x"89bb2e94",
   382 => x"38807508",
   383 => x"54765384",
   384 => x"808094c8",
   385 => x"525a8480",
   386 => x"8081842d",
   387 => x"7610ff1a",
   388 => x"5a577880",
   389 => x"25c3387a",
   390 => x"822b5675",
   391 => x"b1387b52",
   392 => x"84808094",
   393 => x"e8518480",
   394 => x"8081842d",
   395 => x"7b848080",
   396 => x"96f80c02",
   397 => x"b4050d04",
   398 => x"7a770777",
   399 => x"10ff1b5b",
   400 => x"585b7880",
   401 => x"25ff9238",
   402 => x"8480808c",
   403 => x"97047552",
   404 => x"84808095",
   405 => x"a4518480",
   406 => x"8081842d",
   407 => x"75992a81",
   408 => x"32810670",
   409 => x"09810571",
   410 => x"07700970",
   411 => x"9f2c7d06",
   412 => x"79109fff",
   413 => x"fffc0660",
   414 => x"812a415a",
   415 => x"5d575859",
   416 => x"75da3879",
   417 => x"09810570",
   418 => x"7b079f2a",
   419 => x"55567bbf",
   420 => x"26843873",
   421 => x"9d388170",
   422 => x"53848080",
   423 => x"94e8525c",
   424 => x"84808081",
   425 => x"842d7b84",
   426 => x"808096f8",
   427 => x"0c02b405",
   428 => x"0d048480",
   429 => x"8095bc51",
   430 => x"84808081",
   431 => x"842d7b52",
   432 => x"84808094",
   433 => x"e8518480",
   434 => x"8081842d",
   435 => x"7b848080",
   436 => x"96f80c02",
   437 => x"b4050d04",
   438 => x"02dc050d",
   439 => x"810b8480",
   440 => x"8090fc58",
   441 => x"58835976",
   442 => x"08800c80",
   443 => x"08770856",
   444 => x"5473752e",
   445 => x"94388008",
   446 => x"53745284",
   447 => x"8080918c",
   448 => x"51848080",
   449 => x"81842d80",
   450 => x"58807057",
   451 => x"55757084",
   452 => x"05570881",
   453 => x"165654a0",
   454 => x"807524f1",
   455 => x"38800877",
   456 => x"08565675",
   457 => x"752e9438",
   458 => x"80085374",
   459 => x"52848080",
   460 => x"91cc5184",
   461 => x"80808184",
   462 => x"2d8058ff",
   463 => x"19841858",
   464 => x"59788025",
   465 => x"ffa13877",
   466 => x"802e8d38",
   467 => x"84808096",
   468 => x"88518480",
   469 => x"8081842d",
   470 => x"815785aa",
   471 => x"d5aad50b",
   472 => x"800cfad5",
   473 => x"aad5aa0b",
   474 => x"8c0ccc0b",
   475 => x"8034b30b",
   476 => x"8f348008",
   477 => x"5574fce2",
   478 => x"d5aad52e",
   479 => x"92388008",
   480 => x"52848080",
   481 => x"928c5184",
   482 => x"80808184",
   483 => x"2d80578c",
   484 => x"085877fa",
   485 => x"d5aad4b3",
   486 => x"2e92388c",
   487 => x"08528480",
   488 => x"8092c851",
   489 => x"84808081",
   490 => x"842d8057",
   491 => x"80705755",
   492 => x"75708405",
   493 => x"57088116",
   494 => x"5654a080",
   495 => x"7524f138",
   496 => x"80085978",
   497 => x"fce2d5aa",
   498 => x"d52e9238",
   499 => x"80085284",
   500 => x"80809384",
   501 => x"51848080",
   502 => x"81842d80",
   503 => x"578c0854",
   504 => x"73fad5aa",
   505 => x"d4b32e80",
   506 => x"ea388c08",
   507 => x"52848080",
   508 => x"93c05184",
   509 => x"80808184",
   510 => x"2da08052",
   511 => x"80518480",
   512 => x"808af42d",
   513 => x"84808096",
   514 => x"f8085484",
   515 => x"808096f8",
   516 => x"08802e8d",
   517 => x"38848080",
   518 => x"96ac5184",
   519 => x"80808184",
   520 => x"2d735280",
   521 => x"51848080",
   522 => x"88d42d84",
   523 => x"808096f8",
   524 => x"08802efd",
   525 => x"a7388480",
   526 => x"8096c451",
   527 => x"84808081",
   528 => x"842d810b",
   529 => x"84808090",
   530 => x"fc585883",
   531 => x"59848080",
   532 => x"8de70476",
   533 => x"802effa1",
   534 => x"38848080",
   535 => x"96dc5184",
   536 => x"80808184",
   537 => x"2d848080",
   538 => x"8ff90400",
   539 => x"00ffffff",
   540 => x"ff00ffff",
   541 => x"ffff00ff",
   542 => x"ffffff00",
   543 => x"00000000",
   544 => x"55555555",
   545 => x"aaaaaaaa",
   546 => x"ffffffff",
   547 => x"53616e69",
   548 => x"74792063",
   549 => x"6865636b",
   550 => x"20666169",
   551 => x"6c656420",
   552 => x"28626566",
   553 => x"6f726520",
   554 => x"63616368",
   555 => x"65207265",
   556 => x"66726573",
   557 => x"6829206f",
   558 => x"6e203078",
   559 => x"25642028",
   560 => x"676f7420",
   561 => x"30782564",
   562 => x"290a0000",
   563 => x"53616e69",
   564 => x"74792063",
   565 => x"6865636b",
   566 => x"20666169",
   567 => x"6c656420",
   568 => x"28616674",
   569 => x"65722063",
   570 => x"61636865",
   571 => x"20726566",
   572 => x"72657368",
   573 => x"29206f6e",
   574 => x"20307825",
   575 => x"64202867",
   576 => x"6f742030",
   577 => x"78256429",
   578 => x"0a000000",
   579 => x"42797465",
   580 => x"20636865",
   581 => x"636b2066",
   582 => x"61696c65",
   583 => x"64202862",
   584 => x"65666f72",
   585 => x"65206361",
   586 => x"63686520",
   587 => x"72656672",
   588 => x"65736829",
   589 => x"20617420",
   590 => x"30202867",
   591 => x"6f742030",
   592 => x"78256429",
   593 => x"0a000000",
   594 => x"42797465",
   595 => x"20636865",
   596 => x"636b2066",
   597 => x"61696c65",
   598 => x"64202862",
   599 => x"65666f72",
   600 => x"65206361",
   601 => x"63686520",
   602 => x"72656672",
   603 => x"65736829",
   604 => x"20617420",
   605 => x"33202867",
   606 => x"6f742030",
   607 => x"78256429",
   608 => x"0a000000",
   609 => x"42797465",
   610 => x"20636865",
   611 => x"636b2066",
   612 => x"61696c65",
   613 => x"64202861",
   614 => x"66746572",
   615 => x"20636163",
   616 => x"68652072",
   617 => x"65667265",
   618 => x"73682920",
   619 => x"61742030",
   620 => x"2028676f",
   621 => x"74203078",
   622 => x"2564290a",
   623 => x"00000000",
   624 => x"42797465",
   625 => x"20636865",
   626 => x"636b2066",
   627 => x"61696c65",
   628 => x"64202861",
   629 => x"66746572",
   630 => x"20636163",
   631 => x"68652072",
   632 => x"65667265",
   633 => x"73682920",
   634 => x"61742033",
   635 => x"2028676f",
   636 => x"74203078",
   637 => x"2564290a",
   638 => x"00000000",
   639 => x"43686563",
   640 => x"6b696e67",
   641 => x"206d656d",
   642 => x"6f727900",
   643 => x"30782564",
   644 => x"20676f6f",
   645 => x"64207265",
   646 => x"6164732c",
   647 => x"20000000",
   648 => x"4572726f",
   649 => x"72206174",
   650 => x"20307825",
   651 => x"642c2065",
   652 => x"78706563",
   653 => x"74656420",
   654 => x"30782564",
   655 => x"2c20676f",
   656 => x"74203078",
   657 => x"25640a00",
   658 => x"42616420",
   659 => x"64617461",
   660 => x"20666f75",
   661 => x"6e642061",
   662 => x"74203078",
   663 => x"25642028",
   664 => x"30782564",
   665 => x"290a0000",
   666 => x"53445241",
   667 => x"4d207369",
   668 => x"7a652028",
   669 => x"61737375",
   670 => x"6d696e67",
   671 => x"206e6f20",
   672 => x"61646472",
   673 => x"65737320",
   674 => x"6661756c",
   675 => x"74732920",
   676 => x"69732030",
   677 => x"78256420",
   678 => x"6d656761",
   679 => x"62797465",
   680 => x"730a0000",
   681 => x"416c6961",
   682 => x"73657320",
   683 => x"666f756e",
   684 => x"64206174",
   685 => x"20307825",
   686 => x"640a0000",
   687 => x"28416c69",
   688 => x"61736573",
   689 => x"2070726f",
   690 => x"6261626c",
   691 => x"79207369",
   692 => x"6d706c79",
   693 => x"20696e64",
   694 => x"69636174",
   695 => x"65207468",
   696 => x"61742052",
   697 => x"414d0a69",
   698 => x"7320736d",
   699 => x"616c6c65",
   700 => x"72207468",
   701 => x"616e2036",
   702 => x"34206d65",
   703 => x"67616279",
   704 => x"74657329",
   705 => x"0a000000",
   706 => x"46697273",
   707 => x"74207374",
   708 => x"61676520",
   709 => x"73616e69",
   710 => x"74792063",
   711 => x"6865636b",
   712 => x"20706173",
   713 => x"7365642e",
   714 => x"0a000000",
   715 => x"41646472",
   716 => x"65737320",
   717 => x"63686563",
   718 => x"6b207061",
   719 => x"73736564",
   720 => x"2e0a0000",
   721 => x"4c465352",
   722 => x"20636865",
   723 => x"636b2070",
   724 => x"61737365",
   725 => x"642e0a0a",
   726 => x"00000000",
   727 => x"42797465",
   728 => x"20286471",
   729 => x"6d292063",
   730 => x"6865636b",
   731 => x"20706173",
   732 => x"7365640a",
   733 => x"00000000",
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


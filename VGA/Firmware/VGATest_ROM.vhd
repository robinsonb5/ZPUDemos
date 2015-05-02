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

entity VGATest_ROM is
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
end VGATest_ROM;

architecture arch of VGATest_ROM is

type ram_type is array(natural range 0 to ((2**(maxAddrBitBRAM+1))/4)-1) of std_logic_vector(wordSize-1 downto 0);

shared variable ram : ram_type :=
(
     0 => x"84808080",
     1 => x"8c0b8480",
     2 => x"8081e004",
     3 => x"00848080",
     4 => x"808c04ff",
     5 => x"0d800404",
     6 => x"40000017",
     7 => x"00000000",
     8 => x"84808099",
     9 => x"d0088480",
    10 => x"8099d408",
    11 => x"84808099",
    12 => x"d8088480",
    13 => x"80809808",
    14 => x"2d848080",
    15 => x"99d80c84",
    16 => x"808099d4",
    17 => x"0c848080",
    18 => x"99d00c04",
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
    47 => x"808093c4",
    48 => x"73830610",
    49 => x"10050806",
    50 => x"7381ff06",
    51 => x"73830609",
    52 => x"81058305",
    53 => x"1010102b",
    54 => x"0772fc06",
    55 => x"0c515104",
    56 => x"84808099",
    57 => x"d0708480",
    58 => x"809af027",
    59 => x"8e388071",
    60 => x"70840553",
    61 => x"0c848080",
    62 => x"81e50484",
    63 => x"8080808c",
    64 => x"51848080",
    65 => x"86fb0402",
    66 => x"c0050d02",
    67 => x"80c4055b",
    68 => x"80707c70",
    69 => x"84055e08",
    70 => x"725f5f5f",
    71 => x"5a7c7084",
    72 => x"055e0857",
    73 => x"80597698",
    74 => x"2a77882b",
    75 => x"58557480",
    76 => x"2e82f338",
    77 => x"7b802e80",
    78 => x"d338805c",
    79 => x"7480e42e",
    80 => x"81de3874",
    81 => x"80f82e81",
    82 => x"d7387480",
    83 => x"e42e81e2",
    84 => x"387480e4",
    85 => x"2680f138",
    86 => x"7480e32e",
    87 => x"80c838a5",
    88 => x"51848080",
    89 => x"868b2d74",
    90 => x"51848080",
    91 => x"868b2d82",
    92 => x"1a811a5a",
    93 => x"5a837925",
    94 => x"ffac3874",
    95 => x"ff9f387e",
    96 => x"84808099",
    97 => x"d00c0280",
    98 => x"c0050d04",
    99 => x"74a52e09",
   100 => x"81069b38",
   101 => x"810b811a",
   102 => x"5a5c8379",
   103 => x"25ff8738",
   104 => x"84808082",
   105 => x"fb047a84",
   106 => x"1c710857",
   107 => x"5c547451",
   108 => x"84808086",
   109 => x"8b2d811a",
   110 => x"811a5a5a",
   111 => x"837925fe",
   112 => x"e5388480",
   113 => x"8082fb04",
   114 => x"7480f32e",
   115 => x"81e53874",
   116 => x"80f82e09",
   117 => x"8106ff87",
   118 => x"387d5380",
   119 => x"58777e24",
   120 => x"82963872",
   121 => x"802e81f9",
   122 => x"38875672",
   123 => x"9c2a7384",
   124 => x"2b545271",
   125 => x"802e8338",
   126 => x"8158b712",
   127 => x"54718924",
   128 => x"8438b012",
   129 => x"547780f0",
   130 => x"38ff1656",
   131 => x"758025db",
   132 => x"38811959",
   133 => x"837925fe",
   134 => x"8d388480",
   135 => x"8082fb04",
   136 => x"7a841c71",
   137 => x"08405c52",
   138 => x"7480e42e",
   139 => x"098106fe",
   140 => x"a0387d54",
   141 => x"8058777e",
   142 => x"24819538",
   143 => x"73802e81",
   144 => x"a0388756",
   145 => x"739c2a74",
   146 => x"842b5552",
   147 => x"71802e83",
   148 => x"388158b7",
   149 => x"12537189",
   150 => x"248438b0",
   151 => x"125377af",
   152 => x"38ff1656",
   153 => x"758025dc",
   154 => x"38811959",
   155 => x"837925fd",
   156 => x"b5388480",
   157 => x"8082fb04",
   158 => x"73518480",
   159 => x"80868b2d",
   160 => x"ff165675",
   161 => x"8025fee3",
   162 => x"38848080",
   163 => x"84910472",
   164 => x"51848080",
   165 => x"868b2dff",
   166 => x"16567580",
   167 => x"25ffa538",
   168 => x"84808084",
   169 => x"e9047984",
   170 => x"808099d0",
   171 => x"0c0280c0",
   172 => x"050d047a",
   173 => x"841c7108",
   174 => x"535c5384",
   175 => x"808086b0",
   176 => x"2d811959",
   177 => x"837925fc",
   178 => x"dd388480",
   179 => x"8082fb04",
   180 => x"ad518480",
   181 => x"80868b2d",
   182 => x"7d098105",
   183 => x"5473fee2",
   184 => x"38b05184",
   185 => x"8080868b",
   186 => x"2d811959",
   187 => x"837925fc",
   188 => x"b5388480",
   189 => x"8082fb04",
   190 => x"ad518480",
   191 => x"80868b2d",
   192 => x"7d098105",
   193 => x"53848080",
   194 => x"83e30402",
   195 => x"f8050d73",
   196 => x"52c00870",
   197 => x"882a7081",
   198 => x"06515151",
   199 => x"70802ef1",
   200 => x"3871c00c",
   201 => x"71848080",
   202 => x"99d00c02",
   203 => x"88050d04",
   204 => x"02e8050d",
   205 => x"80785755",
   206 => x"75708405",
   207 => x"57085380",
   208 => x"5472982a",
   209 => x"73882b54",
   210 => x"5271802e",
   211 => x"a238c008",
   212 => x"70882a70",
   213 => x"81065151",
   214 => x"5170802e",
   215 => x"f13871c0",
   216 => x"0c811581",
   217 => x"15555583",
   218 => x"7425d638",
   219 => x"71ca3874",
   220 => x"84808099",
   221 => x"d00c0298",
   222 => x"050d0402",
   223 => x"dc050d80",
   224 => x"52848080",
   225 => x"0bfc800c",
   226 => x"81127055",
   227 => x"59848080",
   228 => x"56805584",
   229 => x"fe538114",
   230 => x"83ffff06",
   231 => x"70777084",
   232 => x"05590cfe",
   233 => x"14545472",
   234 => x"8025eb38",
   235 => x"81155583",
   236 => x"df7525df",
   237 => x"38805780",
   238 => x"5584fe53",
   239 => x"fc8008fe",
   240 => x"14545272",
   241 => x"8025f538",
   242 => x"81155583",
   243 => x"df7525e9",
   244 => x"38811757",
   245 => x"b17725df",
   246 => x"38805875",
   247 => x"55805784",
   248 => x"fe538114",
   249 => x"83ffff06",
   250 => x"70767084",
   251 => x"05580cfe",
   252 => x"14545472",
   253 => x"8025eb38",
   254 => x"81175783",
   255 => x"df7725df",
   256 => x"38811858",
   257 => x"937825d3",
   258 => x"38811952",
   259 => x"80518480",
   260 => x"8090842d",
   261 => x"84808087",
   262 => x"880402f4",
   263 => x"050d7476",
   264 => x"52538071",
   265 => x"25903870",
   266 => x"52727084",
   267 => x"055408ff",
   268 => x"13535171",
   269 => x"f438028c",
   270 => x"050d0402",
   271 => x"d4050d7c",
   272 => x"7e5c5881",
   273 => x"0b848080",
   274 => x"93d4585a",
   275 => x"83597608",
   276 => x"780c7708",
   277 => x"77085654",
   278 => x"73752e94",
   279 => x"38770853",
   280 => x"74528480",
   281 => x"8093e451",
   282 => x"84808082",
   283 => x"872d805a",
   284 => x"7756807b",
   285 => x"2590387a",
   286 => x"55757084",
   287 => x"055708ff",
   288 => x"16565474",
   289 => x"f4387708",
   290 => x"77085656",
   291 => x"75752e94",
   292 => x"38770853",
   293 => x"74528480",
   294 => x"8094a451",
   295 => x"84808082",
   296 => x"872d805a",
   297 => x"ff198418",
   298 => x"58597880",
   299 => x"25ff9f38",
   300 => x"79848080",
   301 => x"99d00c02",
   302 => x"ac050d04",
   303 => x"02e4050d",
   304 => x"787a5556",
   305 => x"815785aa",
   306 => x"d5aad576",
   307 => x"0cfad5aa",
   308 => x"d5aa0b8c",
   309 => x"170ccc76",
   310 => x"84808081",
   311 => x"b72db30b",
   312 => x"8f178480",
   313 => x"8081b72d",
   314 => x"75085372",
   315 => x"fce2d5aa",
   316 => x"d52e9238",
   317 => x"75085284",
   318 => x"808094e4",
   319 => x"51848080",
   320 => x"82872d80",
   321 => x"578c1608",
   322 => x"5574fad5",
   323 => x"aad4b32e",
   324 => x"93388c16",
   325 => x"08528480",
   326 => x"8095a051",
   327 => x"84808082",
   328 => x"872d8057",
   329 => x"75558074",
   330 => x"258e3874",
   331 => x"70840556",
   332 => x"08ff1555",
   333 => x"5373f438",
   334 => x"75085473",
   335 => x"fce2d5aa",
   336 => x"d52e9238",
   337 => x"75085284",
   338 => x"808095dc",
   339 => x"51848080",
   340 => x"82872d80",
   341 => x"578c1608",
   342 => x"5372fad5",
   343 => x"aad4b32e",
   344 => x"93388c16",
   345 => x"08528480",
   346 => x"80969851",
   347 => x"84808082",
   348 => x"872d8057",
   349 => x"76848080",
   350 => x"99d00c02",
   351 => x"9c050d04",
   352 => x"02c4050d",
   353 => x"605b8062",
   354 => x"90808029",
   355 => x"ff058480",
   356 => x"8096d453",
   357 => x"405a8480",
   358 => x"8082872d",
   359 => x"80e1b357",
   360 => x"80fe5eae",
   361 => x"51848080",
   362 => x"868b2d76",
   363 => x"1070962a",
   364 => x"81065657",
   365 => x"74802e85",
   366 => x"38768107",
   367 => x"5776952a",
   368 => x"81065877",
   369 => x"802e8538",
   370 => x"76813257",
   371 => x"7877077f",
   372 => x"06775e59",
   373 => x"8fffff58",
   374 => x"76bfffff",
   375 => x"06707a32",
   376 => x"822b7c11",
   377 => x"5157760c",
   378 => x"76107096",
   379 => x"2a810656",
   380 => x"5774802e",
   381 => x"85387681",
   382 => x"07577695",
   383 => x"2a810655",
   384 => x"74802e85",
   385 => x"38768132",
   386 => x"57ff1858",
   387 => x"778025c8",
   388 => x"387c578f",
   389 => x"ffff5876",
   390 => x"bfffff06",
   391 => x"707a3282",
   392 => x"2b7c0570",
   393 => x"08575e56",
   394 => x"74762e80",
   395 => x"ea38807a",
   396 => x"53848080",
   397 => x"96e4525c",
   398 => x"84808082",
   399 => x"872d7454",
   400 => x"75537552",
   401 => x"84808096",
   402 => x"f8518480",
   403 => x"8082872d",
   404 => x"7b5a7610",
   405 => x"70962a81",
   406 => x"06575775",
   407 => x"802e8538",
   408 => x"76810757",
   409 => x"76952a81",
   410 => x"06557480",
   411 => x"2e853876",
   412 => x"813257ff",
   413 => x"18587780",
   414 => x"25ff9c38",
   415 => x"ff1e5e7d",
   416 => x"fea1388a",
   417 => x"51848080",
   418 => x"868b2d7b",
   419 => x"84808099",
   420 => x"d00c02bc",
   421 => x"050d0481",
   422 => x"1a5a8480",
   423 => x"808cd204",
   424 => x"02cc050d",
   425 => x"7e605e58",
   426 => x"815a805b",
   427 => x"80c07a58",
   428 => x"5c85ada9",
   429 => x"89bb780c",
   430 => x"79598156",
   431 => x"97557676",
   432 => x"07822b78",
   433 => x"11515485",
   434 => x"ada989bb",
   435 => x"740c7510",
   436 => x"ff165656",
   437 => x"748025e6",
   438 => x"38761081",
   439 => x"1a5a5798",
   440 => x"7925d738",
   441 => x"7756807d",
   442 => x"2590387c",
   443 => x"55757084",
   444 => x"055708ff",
   445 => x"16565474",
   446 => x"f4388157",
   447 => x"ff8787a5",
   448 => x"c3780c97",
   449 => x"5976822b",
   450 => x"78117008",
   451 => x"5f56567c",
   452 => x"ff8787a5",
   453 => x"c32e80cc",
   454 => x"38740854",
   455 => x"7385ada9",
   456 => x"89bb2e94",
   457 => x"38807508",
   458 => x"54765384",
   459 => x"808097a0",
   460 => x"525a8480",
   461 => x"8082872d",
   462 => x"7610ff1a",
   463 => x"5a577880",
   464 => x"25c3387a",
   465 => x"822b5675",
   466 => x"b1387b52",
   467 => x"84808097",
   468 => x"c0518480",
   469 => x"8082872d",
   470 => x"7b848080",
   471 => x"99d00c02",
   472 => x"b4050d04",
   473 => x"7a770777",
   474 => x"10ff1b5b",
   475 => x"585b7880",
   476 => x"25ff9238",
   477 => x"8480808e",
   478 => x"c3047552",
   479 => x"84808097",
   480 => x"fc518480",
   481 => x"8082872d",
   482 => x"75992a81",
   483 => x"32810670",
   484 => x"09810571",
   485 => x"07700970",
   486 => x"9f2c7d06",
   487 => x"79109fff",
   488 => x"fffc0660",
   489 => x"812a415a",
   490 => x"5d575859",
   491 => x"75da3879",
   492 => x"09810570",
   493 => x"7b079f2a",
   494 => x"55567bbf",
   495 => x"26843873",
   496 => x"9d388170",
   497 => x"53848080",
   498 => x"97c0525c",
   499 => x"84808082",
   500 => x"872d7b84",
   501 => x"808099d0",
   502 => x"0c02b405",
   503 => x"0d048480",
   504 => x"80989451",
   505 => x"84808082",
   506 => x"872d7b52",
   507 => x"84808097",
   508 => x"c0518480",
   509 => x"8082872d",
   510 => x"7b848080",
   511 => x"99d00c02",
   512 => x"b4050d04",
   513 => x"02d4050d",
   514 => x"7c578170",
   515 => x"84808093",
   516 => x"d45b595b",
   517 => x"835a7808",
   518 => x"770c7608",
   519 => x"79085654",
   520 => x"73752e94",
   521 => x"38760853",
   522 => x"74528480",
   523 => x"8093e451",
   524 => x"84808082",
   525 => x"872d8058",
   526 => x"76569fff",
   527 => x"55757084",
   528 => x"055708ff",
   529 => x"16565474",
   530 => x"8025f238",
   531 => x"76087908",
   532 => x"56567575",
   533 => x"2e943876",
   534 => x"08537452",
   535 => x"84808094",
   536 => x"a4518480",
   537 => x"8082872d",
   538 => x"8058ff1a",
   539 => x"841a5a5a",
   540 => x"798025ff",
   541 => x"a1387781",
   542 => x"fd38775b",
   543 => x"815885aa",
   544 => x"d5aad577",
   545 => x"0cfad5aa",
   546 => x"d5aa0b8c",
   547 => x"180ccc77",
   548 => x"84808081",
   549 => x"b72db30b",
   550 => x"8f188480",
   551 => x"8081b72d",
   552 => x"76085574",
   553 => x"fce2d5aa",
   554 => x"d52e9238",
   555 => x"76085284",
   556 => x"808094e4",
   557 => x"51848080",
   558 => x"82872d80",
   559 => x"588c1708",
   560 => x"5978fad5",
   561 => x"aad4b32e",
   562 => x"93388c17",
   563 => x"08528480",
   564 => x"8095a051",
   565 => x"84808082",
   566 => x"872d8058",
   567 => x"76569fff",
   568 => x"55757084",
   569 => x"055708ff",
   570 => x"16565474",
   571 => x"8025f238",
   572 => x"76085a79",
   573 => x"fce2d5aa",
   574 => x"d52e9238",
   575 => x"76085284",
   576 => x"808095dc",
   577 => x"51848080",
   578 => x"82872d80",
   579 => x"588c1708",
   580 => x"5473fad5",
   581 => x"aad4b32e",
   582 => x"80ee388c",
   583 => x"17085284",
   584 => x"80809698",
   585 => x"51848080",
   586 => x"82872d80",
   587 => x"58775ba0",
   588 => x"80527651",
   589 => x"8480808d",
   590 => x"a02d8480",
   591 => x"8099d008",
   592 => x"54848080",
   593 => x"99d00880",
   594 => x"e9388480",
   595 => x"8099d008",
   596 => x"5b735276",
   597 => x"51848080",
   598 => x"8b802d84",
   599 => x"808099d0",
   600 => x"08be3884",
   601 => x"808099d0",
   602 => x"085b7a84",
   603 => x"808099d0",
   604 => x"0c02ac05",
   605 => x"0d048480",
   606 => x"8098e051",
   607 => x"84808082",
   608 => x"872d8480",
   609 => x"8090fc04",
   610 => x"77802eff",
   611 => x"a0388480",
   612 => x"80998451",
   613 => x"84808082",
   614 => x"872d8480",
   615 => x"8092af04",
   616 => x"84808099",
   617 => x"a0518480",
   618 => x"8082872d",
   619 => x"84808092",
   620 => x"ea048480",
   621 => x"8099b851",
   622 => x"84808082",
   623 => x"872d8480",
   624 => x"8092d104",
   625 => x"00ffffff",
   626 => x"ff00ffff",
   627 => x"ffff00ff",
   628 => x"ffffff00",
   629 => x"00000000",
   630 => x"55555555",
   631 => x"aaaaaaaa",
   632 => x"ffffffff",
   633 => x"53616e69",
   634 => x"74792063",
   635 => x"6865636b",
   636 => x"20666169",
   637 => x"6c656420",
   638 => x"28626566",
   639 => x"6f726520",
   640 => x"63616368",
   641 => x"65207265",
   642 => x"66726573",
   643 => x"6829206f",
   644 => x"6e203078",
   645 => x"25642028",
   646 => x"676f7420",
   647 => x"30782564",
   648 => x"290a0000",
   649 => x"53616e69",
   650 => x"74792063",
   651 => x"6865636b",
   652 => x"20666169",
   653 => x"6c656420",
   654 => x"28616674",
   655 => x"65722063",
   656 => x"61636865",
   657 => x"20726566",
   658 => x"72657368",
   659 => x"29206f6e",
   660 => x"20307825",
   661 => x"64202867",
   662 => x"6f742030",
   663 => x"78256429",
   664 => x"0a000000",
   665 => x"42797465",
   666 => x"20636865",
   667 => x"636b2066",
   668 => x"61696c65",
   669 => x"64202862",
   670 => x"65666f72",
   671 => x"65206361",
   672 => x"63686520",
   673 => x"72656672",
   674 => x"65736829",
   675 => x"20617420",
   676 => x"30202867",
   677 => x"6f742030",
   678 => x"78256429",
   679 => x"0a000000",
   680 => x"42797465",
   681 => x"20636865",
   682 => x"636b2066",
   683 => x"61696c65",
   684 => x"64202862",
   685 => x"65666f72",
   686 => x"65206361",
   687 => x"63686520",
   688 => x"72656672",
   689 => x"65736829",
   690 => x"20617420",
   691 => x"33202867",
   692 => x"6f742030",
   693 => x"78256429",
   694 => x"0a000000",
   695 => x"42797465",
   696 => x"20636865",
   697 => x"636b2066",
   698 => x"61696c65",
   699 => x"64202861",
   700 => x"66746572",
   701 => x"20636163",
   702 => x"68652072",
   703 => x"65667265",
   704 => x"73682920",
   705 => x"61742030",
   706 => x"2028676f",
   707 => x"74203078",
   708 => x"2564290a",
   709 => x"00000000",
   710 => x"42797465",
   711 => x"20636865",
   712 => x"636b2066",
   713 => x"61696c65",
   714 => x"64202861",
   715 => x"66746572",
   716 => x"20636163",
   717 => x"68652072",
   718 => x"65667265",
   719 => x"73682920",
   720 => x"61742033",
   721 => x"2028676f",
   722 => x"74203078",
   723 => x"2564290a",
   724 => x"00000000",
   725 => x"43686563",
   726 => x"6b696e67",
   727 => x"206d656d",
   728 => x"6f727900",
   729 => x"30782564",
   730 => x"20676f6f",
   731 => x"64207265",
   732 => x"6164732c",
   733 => x"20000000",
   734 => x"4572726f",
   735 => x"72206174",
   736 => x"20307825",
   737 => x"642c2065",
   738 => x"78706563",
   739 => x"74656420",
   740 => x"30782564",
   741 => x"2c20676f",
   742 => x"74203078",
   743 => x"25640a00",
   744 => x"42616420",
   745 => x"64617461",
   746 => x"20666f75",
   747 => x"6e642061",
   748 => x"74203078",
   749 => x"25642028",
   750 => x"30782564",
   751 => x"290a0000",
   752 => x"53445241",
   753 => x"4d207369",
   754 => x"7a652028",
   755 => x"61737375",
   756 => x"6d696e67",
   757 => x"206e6f20",
   758 => x"61646472",
   759 => x"65737320",
   760 => x"6661756c",
   761 => x"74732920",
   762 => x"69732030",
   763 => x"78256420",
   764 => x"6d656761",
   765 => x"62797465",
   766 => x"730a0000",
   767 => x"416c6961",
   768 => x"73657320",
   769 => x"666f756e",
   770 => x"64206174",
   771 => x"20307825",
   772 => x"640a0000",
   773 => x"28416c69",
   774 => x"61736573",
   775 => x"2070726f",
   776 => x"6261626c",
   777 => x"79207369",
   778 => x"6d706c79",
   779 => x"20696e64",
   780 => x"69636174",
   781 => x"65207468",
   782 => x"61742052",
   783 => x"414d0a69",
   784 => x"7320736d",
   785 => x"616c6c65",
   786 => x"72207468",
   787 => x"616e2036",
   788 => x"34206d65",
   789 => x"67616279",
   790 => x"74657329",
   791 => x"0a000000",
   792 => x"46697273",
   793 => x"74207374",
   794 => x"61676520",
   795 => x"73616e69",
   796 => x"74792063",
   797 => x"6865636b",
   798 => x"20706173",
   799 => x"7365642e",
   800 => x"0a000000",
   801 => x"42797465",
   802 => x"20286471",
   803 => x"6d292063",
   804 => x"6865636b",
   805 => x"20706173",
   806 => x"7365640a",
   807 => x"00000000",
   808 => x"4c465352",
   809 => x"20636865",
   810 => x"636b2070",
   811 => x"61737365",
   812 => x"642e0a0a",
   813 => x"00000000",
   814 => x"41646472",
   815 => x"65737320",
   816 => x"63686563",
   817 => x"6b207061",
   818 => x"73736564",
   819 => x"2e0a0000",
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


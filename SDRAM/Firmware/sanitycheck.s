.section ".fixed_vectors","ax"
	im SanityCheck
	poppc

.section ".text","ax"

	.globl	SanityCheck
SanityCheck:
	im 0x12345678
	nop
	im 0x10000
	store
	im 0x10002
	loadh
	im 0x10000
	loadh
	im 0x10003
	loadb
	im 0x10002
	loadb
	im 0x10001
	loadb
	im 0x10000
	loadb

	im 0xfedb
	nop
	im 0x10000
	storeh
	im 0x10000
	load

	im 0xa9
	nop
	im 0x10003
	storeb
	im 0x10000
	load

	im 0x55
	nop
	im 0x10001
	storeb
	im 0x10000
	load

	; Exhaustive storeh / loadh test

.hloop:
	im 0x00112233
	nop
	im 0x11000
	store

	im 0x44556677
	nop
	im 0x11004
	store

	im 0x8899aabb
	nop
	im 0x11008
	store

	im 0xccddeeff
	nop
	im 0x1100c
	store

	im	0x1234
	nop
	im 0x11004
	storeh
	im	0x5678
	nop
	im	0x1100a
	storeh

	im 0x11002
	loadh
	im 0x11004
	loadh
	im 0x1100c
	loadh
	im 0x1100a
	loadh

	addsp 4

	im .hloop
	poppc

finalloop:
	im finalloop
	poppc

.end


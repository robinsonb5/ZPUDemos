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

finalloop:
	im finalloop
	poppc

.end


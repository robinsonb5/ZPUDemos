
all:
	make -C ZPUSim
	make -C Dhrystone_fast
	make -C Dhrystone_min
	make -C HelloTinyROM
	make -C HelloWorld
	make -C HelloTinyZPU
	make -C Interrupt
	make -C RS232Bootstrap
	make -C SDBootstrap
	make -C SDRAM
	make -C VGA
	make -C Apps

clean:
	make -C ZPUSim clean
	make -C Dhrystone_fast clean
	make -C Dhrystone_min clean
	make -C HelloTinyROM clean
	make -C HelloWorld clean
	make -C HelloTinyZPU clean
	make -C Interrupt clean
	make -C RS232Bootstrap clean
	make -C SDBootstrap clean
	make -C SDRAM clean
	make -C VGA clean
	make -C Apps clean



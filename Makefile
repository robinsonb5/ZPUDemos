BOARDS_ALTERA_BRAM = "\"de0 de0_nano de1 de2 coreboard chameleon64 mist c3board\""
BOARDS_ALTERA_SDRAM = "\"de0 de0_nano de1 de2 coreboard chameleon64 mist c3board\""
BOARDS_XILINX_BRAM = "\"minimig ems11_bb37\""
BOARDS_XILINX_SDRAM = "\"ems11_bb37\""

all: bram sdram utils

utils:
	make -C ZPUSim
	make -C Apps

bram:
	# Projects that don't require SDRAM first.
	make -C Dhrystone_fast BOARDS_ALTERA=$(BOARDS_ALTERA_BRAM) BOARDS_XILINX=$(BOARDS_XILINX_BRAM)
	make -C Dhrystone_min BOARDS_ALTERA=$(BOARDS_ALTERA_BRAM) BOARDS_XILINX=$(BOARDS_XILINX_BRAM)
	make -C HelloTinyROM BOARDS_ALTERA=$(BOARDS_ALTERA_BRAM) BOARDS_XILINX=$(BOARDS_XILINX_BRAM)
	make -C HelloWorld BOARDS_ALTERA=$(BOARDS_ALTERA_BRAM) BOARDS_XILINX=$(BOARDS_XILINX_BRAM)
	make -C HelloTinyZPU BOARDS_ALTERA=$(BOARDS_ALTERA_BRAM) BOARDS_XILINX=$(BOARDS_XILINX_BRAM)
	make -C Interrupt BOARDS_ALTERA=$(BOARDS_ALTERA_BRAM) BOARDS_XILINX=$(BOARDS_XILINX_BRAM)
	make -C PS2 BOARDS_ALTERA=$(BOARDS_ALTERA_BRAM) BOARDS_XILINX=$(BOARDS_XILINX_BRAM)

sdram:
	make -C RS232Bootstrap BOARDS_ALTERA=$(BOARDS_ALTERA_SDRAM) BOARDS_XILINX=$(BOARDS_XILINX_SDRAM)
	make -C SDBootstrap BOARDS_ALTERA=$(BOARDS_ALTERA_SDRAM) BOARDS_XILINX=$(BOARDS_XILINX_SDRAM)
	make -C SDRAM BOARDS_ALTERA=$(BOARDS_ALTERA_SDRAM) BOARDS_XILINX=$(BOARDS_XILINX_SDRAM)
	make -C VGA BOARDS_ALTERA=$(BOARDS_ALTERA_SDRAM) BOARDS_XILINX=$(BOARDS_XILINX_SDRAM)

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



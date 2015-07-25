PROJECT=
MANIFEST=manifest.rtl
BOARDS_ALTERA = # Passed in from parent makefile
BOARDS_XILINX = # Passed in from parent makefile

ALL: fpga
	for BOARD in ${BOARDS_ALTERA}; do \
		make -f ../Scripts/quartus.mak PROJECT=$(PROJECT) MANIFEST=$(MANIFEST) BOARD=$$BOARD; \
	done
	for BOARD in ${BOARDS_XILINX}; do \
		make -f ../Scripts/ise.mak PROJECT=$(PROJECT) MANIFEST=$(MANIFEST) BOARD=$$BOARD; \
	done
	make -C Firmware

clean:
	for BOARD in ${BOARDS_ALTERA}; do \
		make -f ../Scripts/quartus.mak PROJECT=$(PROJECT) MANIFEST=$(MANIFEST) BOARD=$$BOARD clean; \
	done
	for BOARD in ${BOARDS_XILINX}; do \
		make -f ../Scripts/quartus.mak PROJECT=$(PROJECT) MANIFEST=$(MANIFEST) BOARD=$$BOARD clean; \
	done
	make -C Firmware clean

fpga:
	mkdir fpga


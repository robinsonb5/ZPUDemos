PROJECT=RS232Bootstrap
MANIFEST=manifest.rtl
BOARDS = de1 de2 coreboard chameleon64 mist
ALL: fpga
	make -C Firmware
	for BOARD in ${BOARDS}; do \
		make -f ../Scripts/quartus.mak PROJECT=$(PROJECT) MANIFEST=$(MANIFEST) BOARD=$$BOARD; \
	done

clean:
	make -C Firmware clean
	for BOARD in ${BOARDS}; do \
		make -f ../Scripts/quartus.mak PROJECT=$(PROJECT) MANIFEST=$(MANIFEST) BOARD=$$BOARD clean; \
	done

fpga:
	mkdir fpga


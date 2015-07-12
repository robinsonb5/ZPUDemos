
BOARD=de1
BOARDDIR=../Board/$(BOARD)
PROJECT=HelloWorld
MANIFEST=manifest.rtl
SCRIPTSDIR=../Scripts

PROJECTDIR=fpga/$(BOARD)
TARGET=$(PROJECTDIR)/$(PROJECT)

ALL: $(TARGET).xise

clean:
	rm -rf $(PROJECTDIR)

$(TARGET).xise: $(PROJECTDIR) $(MANIFEST) $(BOARDDIR)/template.xise
	cp $(BOARDDIR)/template.xise $(TARGET).xise
	echo >${TARGET}_addfiles.tcl project open ${PROJECT}.xise
	bash $(SCRIPTSDIR)/expandtemplate_ise.sh $(MANIFEST) >>$(TARGET)_addfiles.tcl
#	cat ${MANIFEST} | while read a; \
#		do echo >>$(TARGET)_addfiles.tcl xfile add \"../../$${a}\" ; \
#	done
	echo >>${TARGET}_addfiles.tcl project save
	echo >>${TARGET}_addfiles.tcl project close
	cd ${PROJECTDIR}; xtclsh ${PROJECT}_addfiles.tcl

$(PROJECTDIR):
	mkdir $(PROJECTDIR)
	mkdir $(PROJECTDIR)/Working



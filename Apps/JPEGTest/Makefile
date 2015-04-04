BASE	= zpu-elf
BUILD_DIR=zpu_obj
ARCH = board=phi

CC      = $(BASE)-gcc
LD      = $(BASE)-gcc
AS      = $(BASE)-as
CP      = $(BASE)-objcopy
DUMP    = $(BASE)-objdump


JPEGTEST_PRJ = JPEGTest

ZPUFLEXDIR = ../../ZPUFlex
# we use crt0.s from here
STARTUP_DIR = $(ZPUFLEXDIR)/Firmware/startup

STARTUP_SRC = $(STARTUP_DIR)/crt0.s # $(STARTUP_DIR)/premain.s
STARTUP_OBJ = $(patsubst $(STARTUP_DIR)/%.s,$(BUILD_DIR)/%.o,$(STARTUP_SRC))

COMMON_DIR = ../../Common_Firmware
COMMON_SRC = small_printf.c uart.c spi.c swap.c fat.c rafile.c syscalls.c malloc.c

COMMON_OBJ = $(patsubst %.c,$(BUILD_DIR)/%.o,$(COMMON_SRC))

JPEGDIR = jpeg-6b

JPEGTEST_SRC_C = main.c junixio.c # memset.c strncpy.c memcpy.c
JPEGTEST_OBJ_C = $(patsubst %.c,$(BUILD_DIR)/%.o,$(JPEGTEST_SRC_C))
JPEGLIB_OBJ = jpeg-6b/libjpeg.a
JPEGTEST_OBJ = $(STARTUP_OBJ) $(JPEGTEST_OBJ_C) $(COMMON_OBJ) $(JPEGLIB_OBJ)

LINKMAP  = $(ZPUFLEXDIR)/Firmware/standalone_simple.ld
LIBDIR   = 

# Commandline options for each tool.
#ZPUOPTS= -mno-poppcrel -mno-compare -mno-byteop -mno-shortop -mno-callpcrel \
#  -mno-call -mno-neqbranch -mno-pushspadd \
#  -mno-neg -mno-mod -mno-div

ZPUOPTS= # -mno-poppcrel -mno-pushspadd -mno-callpcrel -mno-mult -mno-div # -mno-neg

INCLUDE = -I. -I$(COMMON_DIR) -Ijpeg-6b/
CFLAGS  = -g -m$(ARCH) $(INCLUDE) -c -O6 $(ZPUOPTS) -ffunction-sections -fdata-sections # -DDISABLE_PRINTF -DDISABLE_UART
AFLAGS  = 
LFLAGS  = -nostartfiles -T$(LINKMAP) -m$(ARCH) -O6 -Wl,--relax -Wl,--gc-sections
CP_HEXFLAGS = -Oihex
CP_SRECFLAGS = -Osrec

# Libraries.
LIBS       =

# Our target.
all: $(BUILD_DIR) $(JPEGTEST_PRJ).bin $(JPEGTEST_PRJ).srec

$(JPEGDIR)/libjpeg.a:
	make -C $(JPEGDIR) libjpeg.a

mif: $(JPEGTEST_PRJ).mif

clean:
	rm -f $(BUILD_DIR)/*.o *.hex *.elf *.map *.lst *.srec $(PRJ).mif *~ */*.o *.bin
	make -C $(JPEGDIR) clean

# Convert ELF binary to bin file.
%.bin: %.elf
	$(CP) -O binary $< $@

# Convert ELF binary to Intel HEX file.
%.hex: %.elf
	$(CP) $(CPFLAGS) $< $@

# Convert ELF binary to SREC file
%.srec: %.elf
	$(CP) $(CP_SRECFLAGS) $< $@

# Convert SREC to .mif file
%.mif: %.srec
	srec_cat $< -o $@ -mif 32

# Link - this produces an ELF binary.

$(JPEGTEST_PRJ).elf: $(JPEGTEST_OBJ)
	$(LD) $(LFLAGS) -o $@ $+ $(LIBS)

$(BUILD_DIR)/%.o: %.c Makefile
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: $(COMMON_DIR)/%.c Makefile
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: $(STARTUP_DIR)/%.s Makefile
	$(AS) -o $@ $<

$(BUILD_DIR):
	mkdir $(BUILD_DIR)



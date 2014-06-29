BASE	= zpu-elf
CC      = $(BASE)-gcc
LD      = $(BASE)-gcc
AS      = $(BASE)-as
CP      = $(BASE)-objcopy
DUMP    = $(BASE)-objdump

ZPUFLEXDIR = ../../ZPUFlex

# we use crt0.s from here
STARTUP_DIR = $(ZPUFLEXDIR)/Firmware/startup

# we fetch ROM prologue / epilogue from here
RTL_DIR = $(ZPUFLEXDIR)/RTL/

# we use printf from here
COMMON_DIR = ../../Common_Firmware


BUILD_DIR=zpu_obj

STARTUP_SRC = $(STARTUP_DIR)/crt0.s
STARTUP_OBJ = $(patsubst $(STARTUP_DIR)/%.s,$(BUILD_DIR)/%.o,$(STARTUP_SRC))

COMMON_SRC = syscalls.c small_printf.c uart.c malloc.c spi.c fat.c swap.c rafile.c interrupts.c
COMMON_OBJ = $(patsubst %.c,$(BUILD_DIR)/%.o,$(COMMON_SRC))
 
MAIN_PRJ = TFTTest
MAIN_SRC = main.c driver.c tft.c
MAIN_OBJ = $(COMMON_OBJ) $(patsubst %.c,$(BUILD_DIR)/%.o,$(MAIN_SRC))

LINKMAP  = $(ZPUFLEXDIR)/Firmware/standalone_simple.ld


# Commandline options for each tool.
ZPUFLAGS = -DDEBUG
CFLAGS  = -I. -I$(COMMON_DIR) $(ZPUFLAGS) -c -Os -ffunction-sections -fdata-sections -DRAMTOP=0x7fffff # -DPRINTF_HEX_ONLY -DDISABLE_UART_RX

LFLAGS  = -nostartfiles -Wl,--relax -Wl,--gc-sections -Os
LIBS = -lgcc

# Our target.
all: $(BUILD_DIR) $(MAIN_PRJ).bin $(MAIN_PRJ).srec
 
clean:
	rm -f $(BUILD_DIR)/*.o *.hex *.elf *.map *.lst *.srec $(MAIN_PRJ).rom *~ */*.o *.bin


# Convert ELF binary to bin file.
%.bin: %.elf
	$(CP) -O binary $< $@

%.srec: %.elf
	$(CP) -O srec $< $@

# Link - this produces an ELF binary.

$(MAIN_PRJ).elf: $(STARTUP_OBJ) $(MAIN_OBJ)
	$(LD) $(LFLAGS) -T $(LINKMAP) -o $@ $+ $(LIBS)

$(BUILD_DIR)/%.o: %.c Makefile
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: $(COMMON_DIR)/%.c Makefile
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: %.s
	$(AS) -o $@ $<

$(BUILD_DIR)/%.o: $(STARTUP_DIR)/%.s
	$(AS) -o $@ $<

$(BUILD_DIR):
	mkdir $(BUILD_DIR)


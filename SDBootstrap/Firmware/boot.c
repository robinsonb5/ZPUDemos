/*	Firmware for loading files from SD card.
	Part of the ZPUTest project by Alastair M. Robinson.
	SPI and FAT code borrowed from the Minimig project.

	This boot ROM ends up stored in the ZPU stack RAM
	which in the current incarnation of the project is
	memory-mapped to 0x04000000
	Halfword and byte writes to the stack RAM aren't
	currently supported in hardware, so if you use
    hardware storeh/storeb, and initialised global
    variables in the boot ROM should be declared as
    int, not short or char.
	Uninitialised globals will automatically end up
	in SDRAM thanks to the linker script, which in most
	cases solves the problem.
*/


#include "stdarg.h"

#include "uart.h"
#include "spi.h"
#include "vga.h"
#include "minfat.h"
#include "small_printf.h"


void _boot();
void _break();

/* Load files named in a manifest file */

static unsigned char Manifest[2048];

int main(int argc,char **argv)
{
	int i;
	HW_VGA(FRAMEBUFFERPTR)=0x00000;

	puts("Initializing SD card\n");
	if(spi_init())
	{
		puts("Hunting for partition\n");
		FindDrive();
		if(LoadFile("MANIFESTMST",Manifest))
		{
			unsigned char *buffer=Manifest;
			int ptr;
			puts("Parsing manifest\n");
			while(1)
			{
				unsigned char c=0;
				ptr=0;
				// Parse address
				while((c=*buffer++)!=' ')
				{
					HW_UART(REG_UART)=c;
					if(c=='#') // Comment line?
						break;
					if(c=='G')
						_boot();

					if(c=='\n')
						_break(); // Halt CPU

					if(c=='L')
						buffer=Manifest;

					c=(c&~32)-('0'-32); // Convert to upper case
					if(c>='9')
						c-='A'-'0';
					ptr<<=4;
					ptr|=c;
				}
				// Parse filename
				if(c!='#')
				{
					int i;
					while((c=*buffer++)==' ')
						;
					--buffer;
					// c-1 is now the filename pointer

//					printf("Loading file %s to %d\n",fn,(long)ptr);
//					buffer[11]=0;
					LoadFile(buffer,(unsigned char *)ptr);
					HW_VGA(FRAMEBUFFERPTR)=ptr;
				}

				// Hunt for newline character
				while((c=*buffer++)!='\n')
					;
			}
		}
		else
		{
			puts("Loading manifest failed\n");
		}
	}
	puts("Returning\n");

	return(0);
}


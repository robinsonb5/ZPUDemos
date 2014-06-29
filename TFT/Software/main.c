#include <stdlib.h>

#include "uart.h"
#include "small_printf.h"

#include "driver.h"
#include "tft.h"
#include "spi.h"
#include "interrupts.h"
#include "timer.h"

unsigned short *framebuffer;

static int framecounter=0;
static int prevtime;

void frame_interrupt()
{
	static int c=0;
	DisableInterrupts();
	int ints=GetInterrupts();

	++c;
	if((c&31)==0)
	{
		framecounter=HW_TIMER(REG_MILLISECONDS)-prevtime;
		prevtime=HW_TIMER(REG_MILLISECONDS);
	}

	TFT_FillBitmap(0,319,0,239,framebuffer);
	EnableInterrupts();
}


int main(int argc, char **argv)
{
	int c=0;
	
	printf("Hello, world!\n");

	framebuffer=(unsigned short *)malloc(320*240*2);
	printf("Framebuffer allocated at %d\n",framebuffer);

	HW_SPI(HW_SPI_CS)=(1<<HW_SPI_FAST);
	TFT_Reset_Write(0);
	CyDelayUs(2);
	TFT_Reset_Write(1);
	TFT_LED_Write(1);
	TFT_CS_Write(0);
	TFT_Init(1); // 0 - vert  1 - horizontal	

	TFT_DrawString("Hello, world!",   20, 20,   1,  WHITE);
//	while(1)
//		TFT_FillRectangle(32, 64, 64, 64,c++);		// X, Y, length, width, colour

	SetIntHandler(frame_interrupt);
	EnableInterrupts();

	prevtime=HW_TIMER(REG_MILLISECONDS);
	frame_interrupt();

	while(1)
	{
		int x,y;
		unsigned short *p=framebuffer;
		int t=c++;

		for(y=0;y<240;++y)
		{
			for(x=0;x<320;++x)
			{
				*p++=x+y+c;
			}
		}

		printf("Screen updating at %d frames per second\n",32000/framecounter);
//		while(1) ;
	}
	return(0);
}


#include <stdlib.h>

#include "uart.h"
#include "small_printf.h"

#include "driver.h"
#include "tft.h"
#include "spi.h"

unsigned short *framebuffer;

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

	TFT_FillBitmap(0,319,0,239,framebuffer);

	while(1)
	{
		int x,y;
		unsigned short *p=framebuffer;
		int t=c++;

		TFT_FillBitmap(0,319,0,239,framebuffer);

		for(y=0;y<240;++y)
		{
			for(x=0;x<320;++x)
			{
				*p++=x+y+c;
			}
		}
	}
	return(0);
}


#include "uart.h"
#include "small_printf.h"

#include "driver.h"
#include "tft.h"
#include "spi.h"

int main(int argc, char **argv)
{
	int c=0;
	
	printf("Hello, world!\n");

	HW_SPI(HW_SPI_CS)=(1<<HW_SPI_FAST);
	TFT_Reset_Write(0);
	CyDelayUs(2);
	TFT_Reset_Write(1);
	TFT_LED_Write(1);
	TFT_CS_Write(0);
	TFT_Init(1); // 0 - vert  1 - horizontal	

	TFT_DrawString("Loading...",   50, 90,   1,  WHITE);
	while(1)
		TFT_FillRectangle(5, 119, 310, 110,c++);		// X, Y, length, width, colour

	return(0);
}


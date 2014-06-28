#include "tft.h"
#include "timer.h"

#include "small_printf.h"

static int out;

void TFT_CS_Write(int d)
{
//	printf("Setting CS to %d\n",d);
	out=(out & ~1)|(d&1);
	HW_TFT(REG_TFT_CONTROL)=out;
}

void TFT_LED_Write(int d)
{
//	printf("Setting LED to %d\n",d);
	out=(out & ~8)|(d ? 8 : 0);
	HW_TFT(REG_TFT_CONTROL)=out;
}

void TFT_Reset_Write(int d)
{
//	printf("Setting Reset to %d\n",d);
	out=(out & ~4)|(d ? 4 : 0);
	HW_TFT(REG_TFT_CONTROL)=out;
}

void D_C_Write(int d)
{
//	printf("Setting DC to %d\n",d);
	out=(out&~2)|(d ? 2 : 0);
	HW_TFT(REG_TFT_CONTROL)=out;
}

void SPIM_WriteTxData(int d)
{
//	printf("Writing %d\n",d);
	HW_TFT(REG_TFT_SPI)=d;
}

void CyDelayUs(int c)
{
	return;
}

void CyDelay(int c)
{
	int m=HW_TIMER(REG_MILLISECONDS);
	while(c--)
	{
		int m2;
		while(m==(m2=HW_TIMER(REG_MILLISECONDS)))
			;
		m=m2;
	}
}

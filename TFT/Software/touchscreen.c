#include "small_printf.h"
#include "touchscreen.h"
#include "filter.h"

int Touch_Status,Touch_X,Touch_Y,Touch_Z;

static int xmin,ymin;
static int xmax,ymax;
static int xres,yres;

static struct Filter XFilter,YFilter;
static struct Filter XFilter2,YFilter2;


void Touch_Init(int width,int height)
{
	xres=width;
	yres=height;
	xmin=0x1c0;
	ymin=0x200;
	xmax=0xe40;
	ymax=0xdc0;
	Filter_Init(&XFilter);
	Filter_Init(&YFilter);
	Filter_Init(&XFilter2);
	Filter_Init(&YFilter2);
}

#define TOUCH_DESCRAMBLE(x1,x2) (((x1)<<5)|((x2>>3)))
#define TOUCH_CONFIG (TOUCH_START|TOUCH_PENIRQ|TOUCH_12BIT|TOUCH_DIFFERENTIAL)


int Touch_Update()
{
	int result=0;
	int t1,t2;
	int x,z1,z2;
	HW_TOUCH(REG_TOUCH_CONTROL)=0; // Enable CS
	Touch_Status=HW_TOUCH(REG_TOUCH_CONTROL);

	if(Touch_Pressed())
	{
		HW_TOUCH(REG_TOUCH_SPI)=TOUCH_CONFIG|TOUCH_XPOS;
		for(t1=0;t1<20;++t1)
			HW_TOUCH(REG_TOUCH_SPI)=0;
		HW_TOUCH(REG_TOUCH_SPI)=TOUCH_CONFIG|TOUCH_XPOS;
		HW_TOUCH(REG_TOUCH_SPI)=0;
		t1=HW_TOUCH(REG_TOUCH_SPI);
		HW_TOUCH(REG_TOUCH_SPI)=0;
		t2=HW_TOUCH(REG_TOUCH_SPI);
		x=t1=TOUCH_DESCRAMBLE(t1,t2);
		if(t1)
		{
			t1=(xres*(t1-xmin))/(xmax-xmin);
			Touch_X=t1;

			Filter_Add(&XFilter,t1);
		}

		HW_TOUCH(REG_TOUCH_SPI)=TOUCH_CONFIG|TOUCH_YPOS;
		for(t1=0;t1<20;++t1)
			HW_TOUCH(REG_TOUCH_SPI)=0;
		HW_TOUCH(REG_TOUCH_SPI)=TOUCH_CONFIG|TOUCH_YPOS;
		HW_TOUCH(REG_TOUCH_SPI)=0;
		t1=HW_TOUCH(REG_TOUCH_SPI);
		HW_TOUCH(REG_TOUCH_SPI)=0;
		t2=HW_TOUCH(REG_TOUCH_SPI);
		t1=TOUCH_DESCRAMBLE(t1,t2);
		if(t1)
		{
			t1=(yres*(t1-ymin))/(ymax-ymin);
			Touch_Y=t1;

			Filter_Add(&YFilter,t1);
		}

		HW_TOUCH(REG_TOUCH_SPI)=TOUCH_CONFIG|TOUCH_ZPOS1;
		for(t1=0;t1<20;++t1)
			HW_TOUCH(REG_TOUCH_SPI)=0;
		HW_TOUCH(REG_TOUCH_SPI)=TOUCH_CONFIG|TOUCH_ZPOS1;
		HW_TOUCH(REG_TOUCH_SPI)=0;
		t1=HW_TOUCH(REG_TOUCH_SPI);
		HW_TOUCH(REG_TOUCH_SPI)=0;
		t2=HW_TOUCH(REG_TOUCH_SPI);
		z1=TOUCH_DESCRAMBLE(t1,t2);

		HW_TOUCH(REG_TOUCH_SPI)=TOUCH_CONFIG|TOUCH_ZPOS2;
		for(t1=0;t1<20;++t1)
			HW_TOUCH(REG_TOUCH_SPI)=0;
		HW_TOUCH(REG_TOUCH_SPI)=TOUCH_CONFIG|TOUCH_ZPOS2;
		HW_TOUCH(REG_TOUCH_SPI)=0;
		t1=HW_TOUCH(REG_TOUCH_SPI);
		HW_TOUCH(REG_TOUCH_SPI)=0;
		t2=HW_TOUCH(REG_TOUCH_SPI);
		z2=TOUCH_DESCRAMBLE(t1,t2);

		// Derive Z value;
		if(z1)
		{
			Touch_Z=(x*(((z2<<4)/z1)-16))/4096;
		}

		Touch_X=Filter_GetMedian(&XFilter);
		Touch_Y=Filter_GetMedian(&YFilter);

		if(Touch_X!=FILTER_BADVALUE)
			Filter_Add(&XFilter2,Touch_X);

		if(Touch_Y!=FILTER_BADVALUE)
			Filter_Add(&YFilter2,Touch_Y);

		Touch_X=Filter_GetMedian(&XFilter2);
		Touch_Y=Filter_GetMedian(&YFilter2);

		if(Touch_X!=FILTER_BADVALUE)
			result=1;
	}
	else
	{
		Filter_Init(&XFilter);
		Filter_Init(&YFilter);
		Filter_Init(&XFilter2);
		Filter_Init(&YFilter2);
	}
	HW_TOUCH(REG_TOUCH_CONTROL)=1;	// Disable CS
	return(result);
}


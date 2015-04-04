#include "touchscreen.h"

int Touch_Status,Touch_X,Touch_Y,Touch_Z;

static int xmin,ymin;
static int xmax,ymax;
static int xres,yres;

void Touch_Init(int width,int height)
{
	xres=width;
	yres=height;
	xmin=0x120;
	ymin=0x110;
	xmax=0x720;
	ymax=0x6c0;
}

#define TOUCH_DESCRAMBLE(x1,x2) (((x1)<<4)|((x2>>4)))
#define TOUCH_CONFIG (TOUCH_START|TOUCH_PENIRQ|TOUCH_12BIT|TOUCH_DIFFERENTIAL)

void Touch_Update()
{
	int t1,t2;
	HW_TOUCH(REG_TOUCH_CONTROL)=0; // Enable CS
	Touch_Status=HW_TOUCH(REG_TOUCH_CONTROL);

	HW_TOUCH(REG_TOUCH_SPI)=TOUCH_CONFIG|TOUCH_XPOS;
	HW_TOUCH(REG_TOUCH_SPI)=0;
	t1=HW_TOUCH(REG_TOUCH_SPI);
	HW_TOUCH(REG_TOUCH_SPI)=0;
	t2=HW_TOUCH(REG_TOUCH_SPI);
	t1=TOUCH_DESCRAMBLE(t1,t2);
	Touch_X=(xres*(t1-xmin))/(xmax-xmin);

	HW_TOUCH(REG_TOUCH_SPI)=TOUCH_CONFIG|TOUCH_YPOS;
	HW_TOUCH(REG_TOUCH_SPI)=0;
	t1=HW_TOUCH(REG_TOUCH_SPI);
	HW_TOUCH(REG_TOUCH_SPI)=0;
	t2=HW_TOUCH(REG_TOUCH_SPI);
	t1=TOUCH_DESCRAMBLE(t1,t2);
	Touch_Y=(yres*(t1-ymin))/(ymax-ymin);

	HW_TOUCH(REG_TOUCH_SPI)=TOUCH_CONFIG|TOUCH_ZPOS1;
	HW_TOUCH(REG_TOUCH_SPI)=0;
	t1=HW_TOUCH(REG_TOUCH_SPI);
	HW_TOUCH(REG_TOUCH_SPI)=0;
	t2=HW_TOUCH(REG_TOUCH_SPI);
	Touch_Z=TOUCH_DESCRAMBLE(t1,t2);

	HW_TOUCH(REG_TOUCH_CONTROL)=1;	// Disable CS
}

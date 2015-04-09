#ifndef TOUCHSCREEN_H
#define TOUCHSCREEN_H

/* Hardware registers for the touchscreen element of a TFT module */

#define TOUCHBASE 0xFFFFFFF0
#define HW_TOUCH(x) *(volatile unsigned int *)(TOUCHBASE+x)

#define REG_TOUCH_CONTROL 0x0
#define TOUCH_CONTROL_CS 0
#define TOUCH_CONTROL_PENIRQ 1


#define REG_TOUCH_SPI 0x4

#define TOUCH_PENIRQ 0
#define TOUCH_POWERED 3
#define TOUCH_SINGLEENDED 4
#define TOUCH_DIFFERENTIAL 0
#define TOUCH_8BIT 0
#define TOUCH_12BIT 8
#define TOUCH_START 0x80
#define TOUCH_YPOS 0x50
#define TOUCH_XPOS 0x10
#define TOUCH_ZPOS1 0x30
#define TOUCH_ZPOS2 0x40

extern int Touch_X,Touch_Y,Touch_Z,Touch_Status;
#define Touch_Pressed() ((HW_TOUCH(REG_TOUCH_CONTROL)&(1<<TOUCH_CONTROL_PENIRQ))==0)
void Touch_Init(int width,int height);
int Touch_Update();

#endif


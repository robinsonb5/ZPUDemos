#include <fcntl.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <unistd.h>

#include "uart.h"
#include "fat.h"
#include "small_printf.h"

#include "driver.h"
#include "tft.h"
#include "spi.h"
#include "interrupts.h"
#include "timer.h"
#include "touchscreen.h"

#include "framebuffer.h"
#include "uibox.h"
#include "rgb.h"

#define FB_WIDTH 320
#define FB_HEIGHT 240

FrameBuffer *framebuffer;

static int framecounter=0;
static int frameoffset=0;
static int prevtime;
static int drawing;

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

#if 0
	++frameoffset;
	if(frameoffset>239)
		fbo=480-frameoffset;
	else
		fbo=frameoffset;
	if(frameoffset>479)
		frameoffset=0;
#endif

//	TFT_FillBitmap(0,FB_WIDTH-1,0,FB_HEIGHT-1,framebuffer->GetBuffer()+FB_WIDTH*frameoffset);
	drawing=false;
	EnableInterrupts();
}


static struct stat statbuf;
char *LoadFile(const char *filename)
{
	char *result=0;
	int fd=open(filename,0,O_RDONLY);
	printf("open() returned %d\n",fd);
	if((fd>0)&&!fstat(fd,&statbuf))
	{
		int n;
		printf("File size is %d\n",statbuf.st_size);
		result=(char *)malloc(statbuf.st_size);
		if(result)
		{
			if(read(fd,result,statbuf.st_size)<0)
			{
				printf("Read failed\n");
				free(result);
				result=0;
			}
		}
	}
	return(result);
}


UIEvent event;
bool pressed;

int main(int argc, char **argv)
{
	int c=0;
	int timestamp;
	bool refresh=true;

	framebuffer=new FrameBuffer(320,240);

	HW_SPI(HW_SPI_CS)=(1<<HW_SPI_FAST);
	TFT_Reset_Write(0);
	CyDelayUs(2);
	TFT_Reset_Write(1);
	TFT_LED_Write(1);
	TFT_CS_Write(0);
	TFT_Init(1); // 0 - vert  1 - horizontal	

	SetIntHandler(frame_interrupt);
	EnableInterrupts();

	prevtime=HW_TIMER(REG_MILLISECONDS);
	frame_interrupt();

	Touch_Init(FB_WIDTH,FB_HEIGHT);

	frameoffset=0;

	framebuffer->Fill(0,0,320,240,RGBTriple(127,127,127).To16Bit());

	UIGradientButton box(*framebuffer,20,20,100,40,RGBTriple(255,64,64));
	box.Draw(false);

	UIGradientButton box2(*framebuffer,160,30,130,50,RGBTriple(60,100,200));
	box2.Draw(false);

	UISlider box3(*framebuffer,20,90,200,40,RGBTriple(100,0,0));
	box3.SetMin(0);
	box3.SetMax(15);
	box3.SetStep(1);
	box3.SetValue(7);
	box3.Draw(false);

	UISlider box4(*framebuffer,20,140,200,40,RGBTriple(0,100,0));
	box4.SetMin(0);
	box4.SetMax(15);
	box4.SetStep(1);
	box4.SetValue(7);
	box4.Draw(false);

	UISlider box5(*framebuffer,20,190,200,40,RGBTriple(0,0,100));
	box5.SetMin(0);
	box5.SetMax(15);
	box5.SetStep(1);
	box5.SetValue(7);
	box5.Draw(false);

	pressed=false;
	drawing=false;
	refresh=true;

	while(1)
	{
		int prevy, prevx;

		if(refresh && !drawing)
		{
			TFT_FillBitmap(0,FB_WIDTH-1,0,FB_HEIGHT-1,framebuffer->GetBuffer());
			drawing=true;
			refresh=false;
		}

		event.SetPos(Touch_X,Touch_Y);
		event.SetType(EVENT_NULL);
		if(HW_TIMER(REG_MILLISECONDS)>(timestamp+100))
		{
			printf("Timeout %d\n",HW_TIMER(REG_MILLISECONDS));
			timestamp=0x7ffffff;
			if(pressed)
				event.SetType(EVENT_RELEASE);
			pressed=false;
		}
		if(Touch_Update())
		{
//			if(Touch_Z<75)
//			{
				if(!pressed)
				{
					Touch_Update();
					event.SetPos(Touch_X,Touch_Y);
					event.SetType(EVENT_PRESS);
				}
				else
					event.SetType(EVENT_DRAG);
				pressed=true;
				
//				framebuffer->Plot(Touch_X,Touch_Y,0xffff);
				timestamp=HW_TIMER(REG_MILLISECONDS);
//			}
		}
		refresh|=box.Event(event);
		refresh|=box2.Event(event);
		refresh|=box3.Event(event);
		refresh|=box4.Event(event);
		refresh|=box5.Event(event);
	}
	return(0);
}


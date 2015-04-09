#include <fcntl.h>
#include <sys/stat.h>
#include <stdlib.h>

#include "uart.h"
#include "fat.h"
#include "small_printf.h"

#include "driver.h"
#include "tft.h"
#include "spi.h"
#include "interrupts.h"
#include "timer.h"
#include "touchscreen.h"

unsigned short *framebuffer;
#define FB_WIDTH 320
#define FB_HEIGHT 240

static int framecounter=0;
static int frameoffset=0;
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

#if 0
	++frameoffset;
	if(frameoffset>239)
		fbo=480-frameoffset;
	else
		fbo=frameoffset;
	if(frameoffset>479)
		frameoffset=0;
#endif

	TFT_FillBitmap(0,FB_WIDTH-1,0,FB_HEIGHT-1,framebuffer+FB_WIDTH*frameoffset);
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


__inline void fb_clear()
{
	int x,y;
	int *fb=(int *)framebuffer;
	for(y=0;y<FB_HEIGHT;++y)
	{
		for(x=0;x<FB_WIDTH;x+=2)
		{
			*fb++=0;
		}
	}
}


__inline void fb_pset(int x, int y, int col)
{
	if(x<0) x=0;
	if(x>FB_WIDTH-1) x=FB_WIDTH-1;
	if(y<0) y=0;
	if(y>FB_HEIGHT-1) y=FB_HEIGHT-1;
	framebuffer[FB_WIDTH*y+x]=col;
}


int main(int argc, char **argv)
{
	int c=0;
	
	printf("Hello, world!\n");

	framebuffer=malloc(FB_WIDTH*FB_HEIGHT*sizeof(short));
//	framebuffer=(unsigned short *)LoadFile("A320X480RAW");
//	printf("Framebuffer allocated at %d\n",framebuffer);

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
	fb_clear();

	while(1)
	{
		int prevy, prevx;
		if(Touch_Update())
		{
			printf("%d, %d\n",Touch_X,Touch_Y);
			fb_pset(Touch_X,Touch_Y,0xffff);

//			if(prevy)
//				frameoffset-=(Touch_Y-prevy);
//			if(frameoffset>239)
//				frameoffset=239;
//			if(frameoffset<0)
//				frameoffset=0;
//			prevy=Touch_Y;
//			prevx=Touch_X;
		}
//		else
//			prevx=prevy=0;
	}
	return(0);
}


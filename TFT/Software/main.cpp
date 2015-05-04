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

class TFTFrameBuffer : public FrameBuffer
{
	public:
	TFTFrameBuffer(int w, int h) : FrameBuffer(w,h)
	{
		HW_SPI(HW_SPI_CS)=(1<<HW_SPI_FAST);
		TFT_Reset_Write(0);
		CyDelayUs(2);
		TFT_Reset_Write(1);
		TFT_LED_Write(1);
		TFT_CS_Write(0);
		TFT_Init(1); // 0 - vert  1 - horizontal
		drawing=false;
		SetIntHandler(TFTFrameBuffer::Interrupt);
		EnableInterrupts();
	}
	~TFTFrameBuffer()
	{
	}
	bool Update()
	{
		bool result=false;
		if(!drawing)
		{
			TFT_FillBitmap(0,FB_WIDTH-1,0,FB_HEIGHT-1,GetBuffer());
			drawing=true;
			result=true;
		}
		return(result);
	}
	bool WaitUpdate()
	{
		while(drawing)
			;
	}
	static void Interrupt();
	static volatile int drawing;
};

volatile int TFTFrameBuffer::drawing;
void TFTFrameBuffer::Interrupt()
{
	static int c=0;
	DisableInterrupts();
	int ints=GetInterrupts();

	drawing=false;
	EnableInterrupts();
}


TFTFrameBuffer *framebuffer;


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

UIEvent &GetEvent()
{
	static int timestamp;
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
		if(!pressed)
		{
			Touch_Update();
			event.SetPos(Touch_X,Touch_Y);
			event.SetType(EVENT_PRESS);
		}
		else
			event.SetType(EVENT_DRAG);
		pressed=true;
		
		timestamp=HW_TIMER(REG_MILLISECONDS);
	}
	return(event);
}


class RGBSlider : public UIBox, public RGBTriple
{
	public:
	RGBSlider(FrameBuffer &fb,int x,int y, int w, int h) : UIBox(x,y,w,h), RGBTriple(), redslider(0), greenslider(0),blueslider(0)
	{
		int wh=(h-20)/3;
		redslider = new UISlider(fb,x,y,w,wh,RGBTriple(100,0,0));
		redslider->SetRange(0,255,8);
		redslider->SetValue(7);

		greenslider = new UISlider(fb,x,y+10+wh,w,wh,RGBTriple(0,100,0));
		greenslider->SetRange(0,255,8);
		greenslider->SetValue(7);

		blueslider = new UISlider(fb,x,y+20+2*wh,w,wh,RGBTriple(0,0,100));
		blueslider->SetRange(0,255,8);
		blueslider->SetValue(7);
	}
	virtual ~RGBSlider()
	{
		if(redslider)
			delete redslider;
		if(greenslider)
			delete greenslider;
		if(blueslider)
			delete blueslider;		
	}
	virtual void Draw(bool pressed)
	{
		redslider->Draw(pressed);
		greenslider->Draw(pressed);
		blueslider->Draw(pressed);
	}
	virtual bool Event(UIEvent &ev)
	{
		bool refresh;
		refresh=redslider->Event(ev);
		refresh|=greenslider->Event(ev);
		refresh|=blueslider->Event(ev);
		if(refresh)
			Trigger();
		return(refresh);
	}
	virtual void Trigger()
	{
		r=redslider->GetValue();
		g=greenslider->GetValue();
		b=blueslider->GetValue();
	}
	protected:
	UISlider *redslider;
	UISlider *greenslider;
	UISlider *blueslider;
};


int main(int argc, char **argv)
{
	int c=0;
	int timestamp;
	bool refresh=true;

	framebuffer=new TFTFrameBuffer(320,240);


	Touch_Init(FB_WIDTH,FB_HEIGHT);

	framebuffer->Fill(0,0,320,240,RGBTriple(127,127,127).To16Bit());


	UIGradientButton box(*framebuffer,20,20,120,48,RGBTriple(255,64,64));
	box.Draw(false);

	UIGradientButton box2(*framebuffer,180,20,120,48,RGBTriple(60,100,200));
	box2.Draw(false);

	RGBSlider box3(*framebuffer,20,90,200,140);
	box3.Draw(false);

	pressed=false;
	refresh=true;

	while(1)
	{
		if(refresh)
		{
			framebuffer->Fill(290,210,20,20,box3.To16Bit());
			refresh=!framebuffer->Update();
		}
		UIEvent &ev=GetEvent();
//		framebuffer->WaitUpdate();
		refresh|=box.Event(ev);
		refresh|=box2.Event(ev);
		refresh|=box3.Event(ev);
	}
	return(0);
}


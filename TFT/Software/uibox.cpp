#include "uibox.h"
#include "framebuffer.h"
#include "small_printf.h"


void UIGradientButton::Draw(bool pressed)
{
	for(int t=0;t<height-4;++t)
	{
		int p=32+((64*t)/(height-4));
		if(!pressed)
			p=127-p;
		RGBTriple c=gradient[p];
		fb.HLine(xpos+2,ypos+t+2,width-4,c.To16Bit());
	}
	int h1=pressed ? 119 : 8;
	int h2=pressed ? 95 : 32;
	fb.HLine(xpos,ypos,width,gradient[h1].To16Bit());
	fb.HLine(xpos+1,ypos+1,width-2,gradient[h1].To16Bit());
	fb.HLine(xpos,ypos+height-1,width,gradient[127-h1].To16Bit());
	fb.HLine(xpos+1,ypos+height-2,width-2,gradient[127-h2].To16Bit());

	fb.VLine(xpos,ypos,height,gradient[h1].To16Bit());
	fb.VLine(xpos+1,ypos+1,height-2,gradient[h2].To16Bit());
	fb.VLine(xpos+width-1,ypos,height,gradient[127-h1].To16Bit());
	fb.VLine(xpos+width-2,ypos+1,height-2,gradient[127-h2].To16Bit());
}


bool UIBox::Event(UIEvent &ev)
{
	bool result=false;
	switch(ev.GetType())
	{
		case EVENT_PRESS:
			result=Press(ev);
			break;

		case EVENT_RELEASE:
			result=Release(ev);
			break;

		case EVENT_DRAG:
			result=Drag(ev);
			break;

		default:
			break;
	}
	if(result)
		Draw(pressed);
	return(result);
}


bool UIBox::Press(UIEvent &ev)
{
	if(Hit(ev))
		filter=5;
	else
		filter=0;
	pressed=(filter==5);
	return(pressed);
}


bool UIBox::Release(UIEvent &ev)
{
	bool result=pressed;
	pressed=false;
	filter=-5;
	if(Hit(ev))
		Trigger();
	return(result);
}


bool UIBox::Drag(UIEvent &ev)
{
	bool result=false;
	if(Hit(ev))
	{
		if(filter<5)
			++filter;
		else
		{
			result=!pressed;
			pressed=true;
		}
	}
	else
	{
		if(filter>-5)
			--filter;
		else
		{
			result=pressed;
			pressed=false;
		}
	}
	return(result);
}


void UIBox::Trigger()
{
	printf("Triggered\n");
}


void UISlider::Draw(bool pressed)
{
	fb.Fill(xpos,ypos,width,height,RGBTriple(127,127,0).To16Bit());

	fb.HLine(xpos,ypos,width,RGBTriple(32,32,32).To16Bit());
	fb.HLine(xpos+1,ypos+1,width-2,RGBTriple(64,64,64).To16Bit());
	fb.HLine(xpos,ypos+height-1,width,RGBTriple(224,224,224).To16Bit());
	fb.HLine(xpos+1,ypos+height-2,width-2,RGBTriple(192,192,192).To16Bit());

	fb.VLine(xpos,ypos,height,RGBTriple(32,32,32).To16Bit());
	fb.VLine(xpos+1,ypos+1,height-2,RGBTriple(64,64,64).To16Bit());
	fb.VLine(xpos+width-1,ypos,height,RGBTriple(224,224,224).To16Bit());
	fb.VLine(xpos+width-2,ypos+1,height-2,RGBTriple(192,192,192).To16Bit());

	handle.xpos=xpos+((value-min)*((width-4)-handle.width))/(max-min);
	handle.ypos=ypos+2;
	handle.height=height-4;

	for(int t=0;t<handle.height-4;++t)
	{
		int p=32+((64*t)/(handle.height-4));
//		if(!pressed)
//			p=127-p;
		RGBTriple c=gradient[p];
		fb.HLine(handle.xpos+2,handle.ypos+t+2,handle.width-4,c.To16Bit());
	}
//	fb.HLine(xpos,ypos,width,gradient[h1].To16Bit());
//	fb.HLine(xpos+1,ypos+1,width-2,gradient[h1].To16Bit());
//	fb.HLine(xpos,ypos+height-1,width,gradient[127-h1].To16Bit());
//	fb.HLine(xpos+1,ypos+height-2,width-2,gradient[127-h2].To16Bit());

//	fb.VLine(xpos,ypos,height,gradient[h1].To16Bit());
//	fb.VLine(xpos+1,ypos+1,height-2,gradient[h2].To16Bit());
//	fb.VLine(xpos+width-1,ypos,height,gradient[127-h1].To16Bit());
//	fb.VLine(xpos+width-2,ypos+1,height-2,gradient[127-h2].To16Bit());
}

bool UISlider::Press(UIEvent &ev)
{
	if(Hit(ev))
		pressed=1;
	bool result=pressed;

	Box hitbox1(xpos,ypos,handle.xpos-xpos,height);
	Box hitbox2(handle.xpos+handle.width,ypos,width-((handle.xpos-xpos)+handle.width),height);

	int x=ev.GetXPos();
	int y=ev.GetYPos();

	if(hitbox1.Hit(ev))
	{
		result=true;
		Decrement();
		printf("Decrement\n");
	}
	if(hitbox2.Hit(ev))
	{
		result=true;
		Increment();
		printf("Decrement\n");
	}
	return(result);
}


bool UISlider::Release(UIEvent &ev)
{
	return(false);
}

bool UISlider::Drag(UIEvent &ev)
{
	return(false);
}



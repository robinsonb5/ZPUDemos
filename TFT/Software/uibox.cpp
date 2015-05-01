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
	int x,y;
	x=ev.GetXPos();
	y=ev.GetYPos();
	bool status=active;
	bool triggered=false;
	bool refresh=false;
	switch(ev.GetType())
	{
		case EVENT_PRESS:
			if(Hit(x,y))
			{
				status=true;
				filter=5;
			}
			else
				filter=0;
			break;

		case EVENT_RELEASE:
			status=false;
			filter=-5;
			if(Hit(x,y))
				Trigger();

		case EVENT_DRAG:
			if(Hit(x,y))
			{
				if(filter<5)
					++filter;
				else
					status=true;
			}
			else
			{
				if(filter>-5)
					--filter;
				else
					status=false;
			}
			break;

		default:
			break;
	}
	if(status!=active)
	{
		Draw(status);
		refresh=true;
	}
	active=status;
	return(refresh);
}

void UIBox::Trigger()
{
	printf("Triggered\n");
}


#ifndef UIBOX_H
#define UIBOX_H

#include "framebuffer.h"
#include "rgb.h"
#include "uievent.h"

class Box
{
	public:
	Box(int x,int y,int w, int h) : xpos(x),ypos(y),width(w),height(h)
	{
	}
	Box() : xpos(0),ypos(0),width(0),height(0)
	{
	}
	virtual ~Box()
	{
	}
	bool Hit(int x, int y)
	{
		bool result=true;
		if((x<xpos)||(x>=(xpos+width)))
			result=false;
		if((y<ypos)||(y>=(ypos+height)))
			result=false;
		return(result);
	}
	protected:
	int xpos,ypos,width,height;
};


class UIBox : public Box
{
	public:
	UIBox(FrameBuffer &fb,int x,int y, int w, int h,RGBTriple &colour) : fb(fb), Box(x,y,w,h), colour(colour)
	{
	}
	virtual ~UIBox()
	{
	}
	virtual void Draw(bool pressed);
	virtual bool Event(UIEvent &ev);
	protected:
	FrameBuffer &fb;
	RGBTriple colour;
	bool active;
};

#endif


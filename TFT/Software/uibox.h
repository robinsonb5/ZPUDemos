#ifndef UIBOX_H
#define UIBOX_H

#include "framebuffer.h"
#include "rgb.h"

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
	protected:
	int xpos,ypos,width,height;
};


class UIBox : public Box
{
	public:
	UIBox(int x,int y, int w, int h,RGBTriple &colour) : Box(x,y,w,h), colour(colour)
	{
	}
	virtual ~UIBox()
	{
	}
	virtual void Draw(FrameBuffer &fb,bool pressed);	
	protected:
	RGBTriple colour;
};

#endif


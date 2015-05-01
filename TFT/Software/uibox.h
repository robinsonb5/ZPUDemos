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
	UIBox(int x,int y, int w, int h) : Box(x,y,w,h)
	{
	}
	virtual ~UIBox()
	{
	}
	virtual void Draw(bool pressed)=0;
	virtual bool Event(UIEvent &ev);
	virtual void Trigger();
	protected:
	bool active;
	int filter;
};


class UIGradientButton : public UIBox
{
	public:
	UIGradientButton(FrameBuffer &fb,int x,int y, int w, int h,RGBTriple colour) : UIBox(x,y,w,h), fb(fb), gradient(colour)
	{
	}
	~UIGradientButton()
	{
	}
	virtual void Draw(bool pressed);
	protected:
	FrameBuffer &fb;
	RGBGradient gradient;
};


#endif


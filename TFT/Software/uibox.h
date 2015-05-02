#ifndef UIBOX_H
#define UIBOX_H

#include "framebuffer.h"
#include "rgb.h"
#include "uievent.h"
#include "intrange.h"

class Box
{
	public:
	Box(int x,int y,int w, int h) : xpos(x),ypos(y),width(w),height(h)
	{
	}
	Box() : xpos(0),ypos(0),width(0),height(0)
	{
	}
	void SetXPos(int x)
	{
		xpos=x;
	}
	void SetYPos(int y)
	{
		xpos=y;
	}
	virtual ~Box()
	{
	}
	inline bool Hit(int x, int y)
	{
		bool result=true;
		if((x<xpos)||(x>=(xpos+width)))
			result=false;
		if((y<ypos)||(y>=(ypos+height)))
			result=false;
		return(result);
	}
	inline bool Hit(UIEvent &ev)
	{
		return(Hit(ev.GetXPos(),ev.GetYPos()));
	}
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
	virtual bool Press(UIEvent &ev);
	virtual bool Release(UIEvent &ev);
	virtual bool Drag(UIEvent &ev);
	bool pressed;
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


class UISlider : public UIBox, public IntRange
{
	public:
	UISlider(FrameBuffer &fb,int x,int y, int w, int h,RGBTriple colour) : UIBox(x,y,w,h), IntRange(), fb(fb), gradient(colour)
	{
		handle.width=32;
	}
	~UISlider()
	{
	}
	virtual void Draw(bool pressed);
	protected:
	virtual bool Press(UIEvent &ev);
	virtual bool Release(UIEvent &ev);
	virtual bool Drag(UIEvent &ev);
	Box handle;
	FrameBuffer &fb;
	RGBGradient gradient;
};


#endif


#ifndef UIEVENT_H
#define UIEVENT_H

enum UIEventType {EVENT_NULL,EVENT_PRESS,EVENT_RELEASE,EVENT_DRAG};

class UIEvent
{
	public:
	UIEvent() : type(EVENT_NULL)
	{
	}
	~UIEvent()
	{
	}
	void SetType(enum UIEventType type)
	{
		this->type=type;
	}
	enum UIEventType GetType()
	{
		return(type);
	}
	void SetPos(int x,int y)
	{
		this->x=x;
		this->y=y;
	}
	int GetXPos()
	{
		return(x);
	}
	int GetYPos()
	{
		return(y);
	}
	protected:
	UIEventType type;
	int x,y;
};

#endif

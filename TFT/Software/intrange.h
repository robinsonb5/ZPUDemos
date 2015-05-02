#ifndef INTRANGE_H
#define INTRANGE_H

class IntRange
{
	public:
	IntRange(int min,int max,int step) : min(min),max(max),step(step),value(0)
	{
	}
	IntRange() : min(0),max(0),step(0),value(0)
	{
	}
	~IntRange()
	{
	}
	void SetMin(int m)
	{
		min=m;
	}
	void SetMax(int m)
	{
		max=m;
	}
	void SetStep(int m)
	{
		step=m;
	}
	void SetValue(int m)
	{
		value=m;
	}
	void SetValueScaled(int m,int srcmin,int srcmax)
	{
		value=min+((max-min)*(m-srcmin))/(srcmax-srcmin);
	}
	int GetValue()
	{
		return(value);
	}
	void Increment()
	{
		value+=step;
		if(value>max)
			value=max;
	}
	void Decrement()
	{
		value-=step;
		if(value<min)
			value=min;
	}
	protected:
	int value;
	int min,max,step;
};

#endif


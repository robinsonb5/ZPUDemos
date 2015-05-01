#ifndef RGB_H

#define RGB_H

class RGBTriple
{
	public:
	RGBTriple(int r,int g,int b) : r(r), g(g), b(b)
	{
	}
	RGBTriple() : r(0), g(0), b(0)
	{
	}
	~RGBTriple()
	{
	}
	FrameBufferPixel To16Bit()
	{
		int r1=(r&0xf8)<<8;
		int g1=(g&0xfc)<<3;
		int b1=(b&0xf8)>>3;
		return(r1|g1|b1);
	}
	RGBTriple &operator*=(const RGBTriple &other)
	{
		r*=other.r;	g*=other.g;	b*=other.b;	return(*this);
	}
	RGBTriple &operator*=(int c)
	{
		r*=c; g*=c; b*=c; return(*this);
	}
	RGBTriple &operator/=(const RGBTriple &other)
	{
		r/=other.r; g/=other.g; b/=other.b; return(*this);
	}
	RGBTriple &operator/=(int c)
	{
		r/=c; g/=c; b/=c; return(*this);
	}
	RGBTriple &operator+=(const RGBTriple &other)
	{
		r+=other.r;	g+=other.g;	b+=other.b;	return(*this);
	}
	RGBTriple &operator+=(const int c)
	{ r+=c; g+=c; b+=c; return(*this);	}
	protected:
	int r,g,b;
};

inline RGBTriple operator*(RGBTriple lhs,int c)
{
	lhs*=c; return(lhs);
}
inline RGBTriple operator*(int c,RGBTriple lhs)
{
	lhs*=c; return(lhs);
}
inline RGBTriple operator/(RGBTriple lhs,int c)
{
	lhs/=c; return(lhs);
}
inline RGBTriple &operator/(RGBTriple lhs,RGBTriple rhs)
{
	lhs/=rhs; return(lhs);
}
inline RGBTriple operator+(RGBTriple lhs,RGBTriple &rhs)
{
	lhs+=rhs; return(lhs);
}
inline RGBTriple operator+(RGBTriple lhs,int c)
{
	lhs+=c; return(lhs);
}
inline RGBTriple operator+(int c,RGBTriple lhs)
{
	lhs+=c; return(lhs);
}


class RGBGradient
{
	public:
	RGBGradient(RGBTriple &centre) : centre(centre)
	{
		highlight=(3*RGBTriple(255,255,255)+centre)/4;
		shadow=centre/4;
	}
	RGBTriple operator[](int idx)
	{
		RGBTriple result=centre;
		if(idx<64)
		{
			result*=idx;
			result+=((64-idx))*highlight;
			result/=64;
		}
		else if(idx<128)
		{
			result*=128-idx;
			result+=(idx-64)*shadow;
			result/=64;
		}
		return(result);
	}
	protected:
	RGBTriple centre;
	RGBTriple highlight;
	RGBTriple shadow;
};



#endif


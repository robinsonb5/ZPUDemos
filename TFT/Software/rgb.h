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
	RGBTriple &operator/(const RGBTriple &other)
	{
		*this/=other; return(*this);
	}
	RGBTriple &operator/=(int c)
	{
		r/=c; g/=c; b/=c; return(*this);
	}
	RGBTriple &operator/(int c)
	{
		*this/=c; return(*this);
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


#endif


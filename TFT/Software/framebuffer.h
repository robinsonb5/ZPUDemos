#ifndef FRAMEBUFFER_H
#define FRAMEBUFFER_H

typedef unsigned short FrameBufferPixel;

class FrameBuffer
{
	public:
	FrameBuffer(int width, int height);
	virtual ~FrameBuffer();
	FrameBufferPixel *GetBuffer();
	void Clear();
	void Fill(int x,int y,int w, int h, FrameBufferPixel pix);
	inline void Plot(int x,int y,FrameBufferPixel pix)
	{
		buffer[width*y+x]=pix;
	}
	inline void HLine(int x,int y,int length,FrameBufferPixel pix)
	{
		for(int i=x;i<(x+length);++i)
			buffer[width*y+i]=pix;
	}
	inline void VLine(int x,int y,int length,FrameBufferPixel pix)
	{
		for(int i=y;i<(y+length);++i)
			buffer[width*i+x]=pix;
	}
	protected:
	int width, height;
	FrameBufferPixel *buffer;
};



#endif

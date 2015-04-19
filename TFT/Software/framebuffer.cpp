#include "small_printf.h"
#include "framebuffer.h"

FrameBuffer::FrameBuffer(int width, int height) : width(width), height(height), buffer(0)
{
	printf("In framebuffer constructor\n");
	buffer=new FrameBufferPixel[width*height];
	printf("Got buffer %x\n",buffer);
}

FrameBuffer::~FrameBuffer()
{
	delete[] buffer;
}

FrameBufferPixel *FrameBuffer::GetBuffer()
{
	return(buffer);
}

void FrameBuffer::Fill(int x,int y,int w,int h,FrameBufferPixel pix)
{
	for(int row=y;row<(y+h);++row)
	{
		HLine(x,row,w,pix);
	}
}

void FrameBuffer::Clear()
{
	Fill(0,0,width,height,0);
}


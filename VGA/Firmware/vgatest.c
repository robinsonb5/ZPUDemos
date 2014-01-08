#include "vga.h"
#include "uart.h"
#include "small_printf.h"

// Doesn't actually matter what we use here while the demo runs from block RAM.
// If we were bootstrapping and then running from SDRAM, we'd need to allocate
// this buffer properly.

#define framebuffer_addr 0x10000

int main(int argc, char **argv)
{
	int c=0;

	HW_VGA(FRAMEBUFFERPTR)=framebuffer_addr;

	// Write a repeating pattern to the framebuffer
	while(1)
	{
		int x,y;
		int s,t;
		int d=++c;
		int *fbptr=(int *)framebuffer_addr;
		for(y=0;y<480;++y)
		{
			for(x=0;x<640;x+=2)
			{
				// Write in 32-bit words for speed.
				t=d<<16;
				d=(d+1)&0xffff;
				t|=d;
				*fbptr++=d;
			}
		}
		for(s=0;s<50;++s)
		{
			// Spin for a while
			for(y=0;y<480;++y)
			{
				for(x=0;x<640;x+=2)
				{
					t=HW_VGA(FRAMEBUFFERPTR); // Dummy read
				}
			}
		}
		for(s=0;s<20;++s)
		{
			// Now write to offscreen memory.
			int *fbptr2=fbptr;
			for(y=0;y<480;++y)
			{
				for(x=0;x<640;x+=2)
				{
					// Write in 32-bit words for speed.
					t=d<<16;
					d=(d+1)&0xffff;
					t|=d;
					*fbptr2++=d;
				}
			}
		}
		++c;
		memcheck(0);
	}

	return(0);
}


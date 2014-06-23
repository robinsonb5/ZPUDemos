#include "vga.h"
#include "uart.h"
#include "small_printf.h"

#define framebuffer_addr 0x10000
#define framebuffer_addr2 (0x10000 + 648*480*2)

void spin()
{
	int s;
	int x;
	int y;
	for(s=0;s<5;++s)
	{
		// Spin for a while
		for(y=0;y<480;++y)
		{
			for(x=0;x<640;x+=2)
			{
				int t=HW_VGA(FRAMEBUFFERPTR); // Dummy read
			}
		}
	}
}

int main(int argc, char **argv)
{
	printf("VGA Framebuffer test\n");

	// Write a repeating pattern to the framebuffer
	int r,g,b;
	int x,y;
	short *fbptr=(short *)framebuffer_addr;
	short *fbptr2=(short *)framebuffer_addr2;

	HW_VGA(FRAMEBUFFERPTR)=framebuffer_addr;

	for(y=0;y<480;++y)
	{
		for(x=0;x<640;++x)
		{
			int t;
			r=(x>>4)&31;
			g=(y>>4)&63;
			b=((x+y)>>4)&31;
			t=(r<<11)|(g<<5)|b;				
			*fbptr++=t;
			*fbptr2++=~t;
		}
	}
	printf("Filled screen - toggling framebuffer\n");
	while(1)
	{
		spin();
		printf("Buffer 2\n");
		HW_VGA(FRAMEBUFFERPTR)=framebuffer_addr2;
		spin();
		printf("Buffer 1\n");
		HW_VGA(FRAMEBUFFERPTR)=framebuffer_addr;
	}

	return(0);
}


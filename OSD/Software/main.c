#include "osd.h"
#include "uart.h"
#include "small_printf.h"


int pixelclock;

void SetOSDPos()
{
	int hf, vf;
	int hh,hl,vh,vl;
	int enable=1;
	hf=HW_OSD(REG_OSD_HFRAME);
	vf=HW_OSD(REG_OSD_VFRAME);

	printf("%x, %x\n",hf, vf);

	// Extract width of frame (hh) and sync pulse (hl)
	hh=hf>>8;
	hl=hf&0xff;
	if(hh<hl)	// Might need to swap, depending on sync polarity
	{
		hl=hh;
		hh=hf&0xff;
		enable|=2; // Flip HSync polarity
	}

		
	// Extract height of frame (vh) and sync pulse (vl)
	vh=vf>>8;
	vl=vf&0xff;
	if(vh<vl)	// Might need to swap, depending on sync polarity
	{
		vl=vh;
		vh=vf&0xff;
		enable|=4; // Flip VSync polarity
	}

	hh<<=2+pixelclock;
	vh<<=3;

	printf("Frame width is %d, frame height is %d\n",hh,vh);

	hl=(hh-80)/2;
	vl=(vh-48)/2;

	printf("OSD Offsets: %d, %d\n",hl,vl);

	HW_OSD(REG_OSD_XPOS)=-hl;
	HW_OSD(REG_OSD_YPOS)=-vl;
}


int main(int argc, char **argv)
{
	int i;

	printf("OSD Test\n");

	HW_OSD(REG_OSD_ENABLE)=1;
	for(i=0;i<4;++i)
	{
		int j;
		pixelclock=i;
		printf("Pixel clock: %d\n",1<<pixelclock);
		HW_OSD(REG_OSD_PIXELCLOCK)=(1<<i)-1;
		for(j=0;j<10000;++j)
		{
			int t=HW_OSD(REG_OSD_HFRAME);
		}			
		SetOSDPos();
	}

	HW_OSD(REG_OSD_ENABLE)=7;
	for(i=0;i<4;++i)
	{
		int j;
		pixelclock=i;
		printf("Pixel clock: %d\n",1<<pixelclock);
		HW_OSD(REG_OSD_PIXELCLOCK)=(1<<i)-1;
		for(j=0;j<10000;++j)
		{
			int t=HW_OSD(REG_OSD_HFRAME);
		}			
		SetOSDPos();
	}

	for(i=0;i<512;++i)
	{
		OSD_CHARBUFFER[i]=i;
	}	

	return(0);
}


#include "osd.h"
#include "uart.h"
#include "small_printf.h"

int pixelclock;

void ShowOSD()
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

	pixelclock=2;
	HW_OSD(REG_OSD_PIXELCLOCK)=(1<<pixelclock)-1;

	printf("Frame width is %d, frame height is %d\n",hh,vh);

	hl=((hh-100)-80)/2;
	vl=((vh-60)-48)/2;

	printf("OSD Offsets: %d, %d\n",hl,vl);

	HW_OSD(REG_OSD_ENABLE)=enable;
	HW_OSD(REG_OSD_XPOS)=-hl;
	HW_OSD(REG_OSD_YPOS)=-vl;
}


int main(int argc, char **argv)
{
	int i;

	printf("OSD Test\n");

	ShowOSD();

	for(i=0;i<512;++i)
	{
		OSD_CHARBUFFER[i]=i;
	}	

	ShowOSD();

	return(0);
}


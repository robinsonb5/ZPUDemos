#include "uart.h"
#include "fat.h"
#include "small_printf.h"

#include "soundhw.h"
#include "interrupts.h"
#include "timer.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>


fileTYPE *file;

char string[]="Hello world!\n";

static struct stat statbuf;


char *LoadFile(const char *filename)
{
	char *result=0;
	int fd=open(filename,0,O_RDONLY);
	printf("open() returned %d\n",fd);
	if((fd>0)&&!fstat(fd,&statbuf))
	{
		int n;
		printf("File size is %d\n",statbuf.st_size);
		result=(char *)malloc(statbuf.st_size);
		if(result)
		{
			if(read(fd,result,statbuf.st_size)<0)
			{
				printf("Read failed\n");
				free(result);
				result=0;
			}
		}
	}
	return(result);
}


void timer_interrupt()
{
	DisableInterrupts();
	int ints=GetInterrupts();
	mt_music();
	EnableInterrupts();
}


int main(int argc, char **argv)
{
	char *modptr;

	modptr=LoadFile("STARDSTMMOD");
	printf("Module loaded to %d\n",modptr);
	printf("Triggering sound\n");
	mt_init(modptr);

	HW_TIMER(REG_TIMER_INDEX)=0; // Set first timer
	HW_TIMER(REG_TIMER_COUNTER)=2000; // Timer is prescaled to 100KHz
	SetIntHandler(timer_interrupt);
	EnableInterrupts();
	puts("Enabling timer...\n");
	HW_TIMER(REG_TIMER_ENABLE)=1; // Enable timer 0

	while(1)
		;

//	REG_SOUNDCHANNEL[0].DAT=modptr;
//	REG_SOUNDCHANNEL[0].LEN=statbuf.st_size/2;
//	REG_SOUNDCHANNEL[0].VOL=63;
//	REG_SOUNDCHANNEL[0].PERIOD=200;
//	REG_SOUNDCHANNEL[0].TRIGGER=0;
//	REG_SOUNDCHANNEL[1].DAT=modptr;
//	REG_SOUNDCHANNEL[1].LEN=statbuf.st_size/2;
//	REG_SOUNDCHANNEL[1].VOL=63;
//	REG_SOUNDCHANNEL[1].PERIOD=150;
//	REG_SOUNDCHANNEL[1].TRIGGER=0;
//	REG_SOUNDCHANNEL[2].DAT=modptr;
//	REG_SOUNDCHANNEL[2].LEN=statbuf.st_size/2;
//	REG_SOUNDCHANNEL[2].VOL=63;
//	REG_SOUNDCHANNEL[2].PERIOD=125;
//	REG_SOUNDCHANNEL[2].TRIGGER=0;
//	REG_SOUNDCHANNEL[3].DAT=modptr;
//	REG_SOUNDCHANNEL[3].LEN=statbuf.st_size/2;
//	REG_SOUNDCHANNEL[3].VOL=63;
//	REG_SOUNDCHANNEL[3].PERIOD=175;
//	REG_SOUNDCHANNEL[3].TRIGGER=0;
	return(0);
}

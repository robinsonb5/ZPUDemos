#include "uart.h"
#include "fat.h"
#include "vga.h"

#define NULL 0
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>

#include "small_printf.h"


fileTYPE *file;

char string[]="Hello world!\n";

char *LoadFile(const char *filename)
{
	char *result=0;
	struct stat statbuf;
	int fd=open(filename,0,O_RDONLY);
	printf("open() returned %d\n",fd);
	if((fd>0)&&!fstat(fd,&statbuf))
	{
		int n;
		int size=statbuf.st_size; /* Caution - 64-bit value */
		result=(char *)malloc(size);
		if(result)
		{
			if(read(fd,result,size)<0)
			{
				printf("Read failed\n");
				free(result);
				result=0;
			}
		}
	}
	return(result);
}


int main(int argc, char **argv)
{
	char *ptr;
	int size;
	DIRENTRY *dir=0;

	printf("Scanning directory\n");
	while((dir=NextDirEntry(dir==0)))
	{
		if (dir->Name[0] != SLOT_EMPTY && dir->Name[0] != SLOT_DELETED) // valid entry??
		{
			printf("%s (%s)\n",dir->Name,longfilename);
		}
	}

	if((ptr=LoadFile("A320X480RAW")))
	{
		printf("File successfully loaded to %d\n",ptr);
		HW_VGA(FRAMEBUFFERPTR)=(int)ptr;
	}
	else
		printf("Loading failed\n");

	return(0);
}


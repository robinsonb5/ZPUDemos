#include "uart.h"
#include "fat.h"
#include "small_printf.h"

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


int main(int argc, char **argv)
{
	char *ptr;

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
		printf("File successfully loaded to %d\n",ptr);
	else
		printf("Loading failed\n");
	return(0);
}


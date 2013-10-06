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


int main(int argc, char **argv)
{
	mt_init(0x10000);
	mt_music();
	return(0);
}

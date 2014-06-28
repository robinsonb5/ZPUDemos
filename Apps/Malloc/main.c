#include <stdlib.h>

#include "uart.h"
#include "small_printf.h"

int main(int argc, char **argv)
{
	char *p;
	puts("Allocating memory...\n");
	do
	{
		p=(char *)malloc(262144);
		printf("Allocated 256k at %d\n",p);
	} while(p);
	printf("Out of memory!\n");
	return(0);
}


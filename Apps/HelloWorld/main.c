#include "uart.h"

#include "small_printf.h"

volatile int t;

#define bufsize 16
char charbuffer[bufsize];

short shortbuffer[bufsize];

int main(int argc, char **argv)
{
	int i;
//	for(i=bufsize-1;i>=0;--i)
	for(i=0;i<bufsize;i++)
	{
		charbuffer[i]=(i*6)&255;
	}
	for(i=bufsize-1;i>=0;--i)
	{
		int t=charbuffer[i];
		if(t!=((i*6)&255))
			printf("Failed at %d, got %d, expected %d\n",i,t,(i*6)&255);
	}

	for(i=0;i<bufsize;i++)
	{
		shortbuffer[i]=(i*69)&65535;
	}
	for(i=bufsize-1;i>=0;--i)
	{
		int t=shortbuffer[i];
		if(t!=((i*69)&65535))
			printf("Failed at %d, got %d, expected %d\n",i,t,(i*6)&255);
	}

	printf("Hello, world!\n");
	// Test that division is working correctly
	for(i=1;i<10;++i)
	{
		printf("%d\n",(i*123400)/37);
	}
	return(0);
}


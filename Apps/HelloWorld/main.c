#include "uart.h"

#include "small_printf.h"

volatile int t;

char charbuffer[40];

int main(int argc, char **argv)
{
	int i;
	printf("Hello, world!\n");
	// Test that division is working correctly
	for(i=0;i<10;++i)
	{
		printf("%d\n",(i*100)/37);
	}
	return(0);
}


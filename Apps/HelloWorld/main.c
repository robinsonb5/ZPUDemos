#include "uart.h"

#include "small_printf.h"

volatile int t;

char charbuffer[40];

int main(int argc, char **argv)
{
	int i,j;
	printf("Hello, world!\n");
	// Test that multiplication and division are working correctly
	for(i=10;i>0;--i)
	{
		for(j=99;j>=0;j-=11)
		{
			printf("%d\n",(i*j)/37);
		}
	}
	return(0);
}


#include "uart.h"
#include "small_printf.h"

int main(int argc, char **argv)
{
	volatile int *t=0;
	
	printf("Hello, world! %d\n",(*t+1234)/1234); // Test that division is working.
	return(0);
}


#include "uart.h"

#include "small_printf.h"

volatile int t;

int main(int argc, char **argv)
{
	t=12345678;
	printf("Hello, world! %d\n",t/1234); // Test that division is working.
	return(0);
}


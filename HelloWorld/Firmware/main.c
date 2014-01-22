#include "uart.h"

int main(int argc, char **argv)
{
	puts("Hello, world!\n");

	// Now echo any characters received back down the line.
	while(1)
		putchar(getserial());

	return(0);
}


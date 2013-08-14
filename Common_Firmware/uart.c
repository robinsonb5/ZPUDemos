#include "uart.h"

#ifndef DISABLE_UART_TX
__inline int putchar(int c)
{
	while(!(HW_UART(REG_UART)&(1<<REG_UART_TXREADY)))
		;
	HW_UART(REG_UART)=c;
	return(c);
}

int puts(char *msg)
{
	int r=0;
	while(*msg)
	{
		putchar(*msg++);
		++r;
	}
	return(r);
}
#endif

#ifndef DISABLE_UART_RX
char getserial()
{
	int r=0;
	while(!(r&(1<<REG_UART_RXINT)))
		r=HW_UART(REG_UART);
	return(r);
}
#endif


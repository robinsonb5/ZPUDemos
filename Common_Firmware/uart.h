#ifndef UART_H
#define UART_H

/* Hardware registers for the ZPU MiniSOC project.
   Based on the similar TG68MiniSOC project, but with
   changes to suit the ZPU's archicture */

#define UARTBASE 0xFFFFFF84
#define HW_UART(x) *(volatile unsigned int *)(UARTBASE+x)

#define REG_UART 0x0
#define REG_UART_RXINT 9
#define REG_UART_TXREADY 8

#define REG_UART_CLKDIV 0x04
#define UART_115200 (1250000/1152);

#ifndef DISABLE_UART_TX
int putchar(int c);
int puts(char *msg);
#else
#define putchar(x) (x)
#define puts(x)
#endif

#ifndef DISABLE_UART_RX
char getserial();
#else
#define getserial 0
#endif

#endif


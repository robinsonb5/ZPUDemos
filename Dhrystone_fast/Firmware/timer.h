#ifndef UART_H
#define UART_H

/* Hardware registers for a supporting UART to the ZPUFlex project. */

#define TIMERBASE 0xFFFFFFC8
#define HW_TIMER(x) *(volatile unsigned int *)(TIMERBASE+x)

#define REG_MILLISECONDS 0x0

#endif


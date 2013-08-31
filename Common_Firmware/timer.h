#ifndef TIMER_H
#define TIMER_H

/* Hardware registers for a timer, needed for the Dhrystone ZPU demo. */

#define TIMERBASE 0xFFFFFFC8
#define HW_TIMER(x) *(volatile unsigned int *)(TIMERBASE+x)

#define REG_MILLISECONDS 0x0

#endif


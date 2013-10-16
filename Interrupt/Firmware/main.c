#include "uart.h"
#include "interrupts.h"
#include "timer.h"

static int tick;
void timer_interrupt()
{
	DisableInterrupts();
	int ints=GetInterrupts();
	tick^=1;
	if(tick)
		puts("Tick...\n");
	else
		puts("Tock...\n");
	EnableInterrupts();
}


int main(int argc, char **argv)
{
	tick=0;
	puts("Setting up timer...\n");
	HW_TIMER(REG_TIMER_INDEX)=0; // Set first timer
	HW_TIMER(REG_TIMER_COUNTER)=100000; // Timer is prescaled to 100KHz
	puts("Enabling interrupts...\n");
	SetIntHandler(timer_interrupt);
	EnableInterrupts();
	puts("Enabling timer...\n");
	HW_TIMER(REG_TIMER_ENABLE)=1; // Enable timer 0
	while(1)
		;
}


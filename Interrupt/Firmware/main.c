#include "uart.h"
#include "interrupts.h"

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
	puts("Enabling interrupts...\n");
	SetIntHandler(timer_interrupt);
	EnableInterrupts();
	while(1)
		;
}


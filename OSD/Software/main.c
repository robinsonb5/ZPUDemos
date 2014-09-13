#include "osd.h"
#include "uart.h"
#include "interrupts.h"
#include "keyboard.h"
#include "ps2.h"
#include "small_printf.h"


int main(int argc, char **argv)
{
	int i;

	PS2Init();
	EnableInterrupts();

	OSD_Show(0);
	Menu_Set(0);
	while(1)
	{
		HandlePS2RawCodes();
		Menu_Run();
	}

	return(0);
}


#include "uart.h"
#include "interrupts.h"
#include "ps2.h"
#include "keyboard.h"


int main(int argc, char **argv)
{
	puts("Initialising PS/2 interface...\n");

	PS2Init();
	EnableInterrupts();
	while(1)
	{
		int k;
		k=HandlePS2RawCodes();
		if(k)
			putchar(k);
		if(TestKey(KEY_F1))
			puts("F1\n");
		if(TestKey(KEY_UPARROW)&2)
			puts("Up Arrow\n");
		if(TestKey(KEY_DOWNARROW)&2)
			puts("Down Arrow\n");
		if(TestKey(KEY_LEFTARROW)&2)
			puts("Left Arrow\n");
		if(TestKey(KEY_RIGHTARROW)&2)
			puts("Right Arrow\n");
		if(TestKey(KEY_ENTER)&2)
			puts("Enter\n");
		if(TestKey(KEY_SPACE)&2)
			puts("Space\n");
	}
}


#include "osd.h"
#include "uart.h"
#include "interrupts.h"
#include "keyboard.h"
#include "ps2.h"
#include "small_printf.h"
#include "menu.h"



static void reset()
{

}


static struct menu_entry topmenu[];

static char *video_labels[]=
{
	"VGA - 31KHz, 60Hz",
	"VGA - 31KHz, 50Hz",
	"SCART - 15KHz, 50Hz RGB",
	"TV/Sound - 15Hz"
};

static char *slot1_labels[]=
{
	"Sl1: None",
	"Sl1: ESE-SCC 1MB/SCC-I",
	"Sl1: MegaRAM"
};

static char *slot2_labels[]=
{
	"Sl2: None",
	"Sl2: ESE-SCC 1MB/SCC-I",
	"Sl2: ESE-RAM 1MB/ASCII8",
	"Sl2: ESE-RAM 1MB/ASCII16"
};

static char *ram_labels[]=
{
	"2048LB RAM",
	"4096KB RAM"
};

static struct menu_entry dipswitches[]=
{
	{MENU_ENTRY_CYCLE,(char *)video_labels,4},
	{MENU_ENTRY_TOGGLE,"SD Card",2},
	{MENU_ENTRY_CYCLE,(char *)slot1_labels,3},
	{MENU_ENTRY_CYCLE,(char *)slot2_labels,4},
	{MENU_ENTRY_TOGGLE,"Japanese keyboard layout",6},
	{MENU_ENTRY_TOGGLE,"Turbo (10.74MHz)",7},
	{MENU_ENTRY_CYCLE,(char *)ram_labels,2},
	{MENU_ENTRY_SUBMENU,"Back",MENU_ACTION(topmenu)},
	
	{MENU_ENTRY_NULL,0,0},
};


static struct menu_entry topmenu[]=
{
	{MENU_ENTRY_SUBMENU,"DIP Switches \x10",MENU_ACTION(dipswitches)},
	{MENU_ENTRY_CALLBACK,"Reset",MENU_ACTION(&reset)},
	{MENU_ENTRY_CALLBACK,"Exit",MENU_ACTION(&Menu_Hide)},
	{MENU_ENTRY_NULL,0,0},
};




int main(int argc, char **argv)
{
	int i;

	PS2Init();
	EnableInterrupts();

	OSD_Show(0);
	Menu_Set(topmenu);
	while(1)
	{
		HandlePS2RawCodes();
		Menu_Run();
	}

	return(0);
}


#include "osd.h"
#include "menu.h"
#include "keyboard.h"


static struct menu_entry *menu;
static int menu_visible=0;
static int menu_toggles;
static int menurows;
static int currentrow;


static void reset()
{

}

static void exitosd()
{
	OSD_Show(menu_visible=0);
}


static struct menu_entry topmenu[];

static struct menu_entry dipswitches[]=
{
	{MENU_ENTRY_TOGGLE,"SD Card ",0},
	{MENU_ENTRY_TOGGLE,"Scandoubler ",1},
	{MENU_ENTRY_TOGGLE,"Sound ",2},
	{MENU_ENTRY_TOGGLE,"Memory ",3},
	{MENU_ENTRY_SUBMENU,"Back",MENU_ACTION(topmenu)},
	
	{MENU_ENTRY_NULL,0,0},
};


static struct menu_entry topmenu[]=
{
	{MENU_ENTRY_SUBMENU,"DIP Switches \x10",MENU_ACTION(dipswitches)},
	{MENU_ENTRY_CALLBACK,"Reset",MENU_ACTION(&reset)},
	{MENU_ENTRY_CALLBACK,"Exit",MENU_ACTION(&exitosd)},
	{MENU_ENTRY_NULL,0,0},
};


void Menu_Draw()
{
	struct menu_entry *m=menu;
	OSD_Clear();
	menurows=0;
	while(m->type!=MENU_ENTRY_NULL)
	{
		OSD_SetX(2);
		OSD_SetY(menurows);
		if(m->type==MENU_ENTRY_TOGGLE)
		{
			if((menu_toggles>>MENU_ACTION_TOGGLE(m->action))&1)
				OSD_Puts("\x14 ");
			else
				OSD_Puts("\x15 ");
		}
		OSD_Puts(m->label);
		++menurows;
		m++;
	}
}


void Menu_Set(struct menu_entry *head)
{
	if(!head)
		head=topmenu;
	menu=head;
	Menu_Draw();
	currentrow=menurows-1;
}


void Menu_Run()
{
	int i;
	if(TestKey(KEY_F12)&2)
		OSD_Show(menu_visible^=1);
	if((TestKey(KEY_UPARROW)&2)&&currentrow)
		--currentrow;
	if((TestKey(KEY_DOWNARROW)&2)&&(currentrow<(menurows-1)))
		++currentrow;

	if(TestKey(KEY_ENTER)&2)
	{
		struct menu_entry *m=menu;
		i=currentrow;
		while(i)
		{
			++m;
			--i;
		}
		switch(m->type)
		{
			case MENU_ENTRY_SUBMENU:
				Menu_Set(MENU_ACTION_SUBMENU(m->action));
				break;
			case MENU_ENTRY_CALLBACK:
				MENU_ACTION_CALLBACK(m->action)();
				break;
			case MENU_ENTRY_TOGGLE:
				i=1<<MENU_ACTION_TOGGLE(m->action);
				menu_toggles^=i;
				Menu_Draw();
				break;
			default:
				break;

		}
	}

	for(i=0;i<OSD_ROWS;++i)
	{
		OSD_SetX(0);
		OSD_SetY(i);
		OSD_Putchar(i==currentrow ? (i==menurows-1 ? 17 : 16) : 32);
	}
}


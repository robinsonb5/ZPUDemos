#ifndef MENU_H
#define MENU_H

enum menu_entry_type {MENU_ENTRY_NULL,MENU_ENTRY_TOGGLE,MENU_ENTRY_CALLBACK,MENU_ENTRY_SUBMENU};

typedef int menu_action;
#define MENU_ACTION(x) ((int)(x))
#define MENU_ACTION_TOGGLE(x) x
#define MENU_ACTION_CALLBACK(x) ((void (*)())x)
#define MENU_ACTION_SUBMENU(x) ((struct menu_entry *)(x))

struct menu_entry
{
	enum menu_entry_type type;
	char *label;
	menu_action action;	
};

void Menu_Draw();
void Menu_Set(struct menu_entry *head);
void Menu_Run();

#endif

/*
 * TFT.h
 *
 * IDEA:  http://extmemory.blogspot.ru/2013/11/tft-ili9341.html    Author: Ovner
 * 
 *  
 */ 


#ifndef TFT_H_
#define TFT_H_

#include <stdlib.h>

#define TFT_DATA_PORT PORTB
#define TFT_DATA_DIR DDRB
#define TFT_CTRL_PORT PORTA
#define TFT_CTRL_DIR DDRA

#define FONT_SPACE 10
#define FONT_X 16
#define FONT_Y 8
//Basic Colors
#define RED	 	0xf800
#define GREEN	0x07e0
#define BLUE	0x001f
#define BLACK	0x0000
#define YELLOW	0xffe0
#define WHITE	0xffff
//Other Colors   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define CYAN		0x07ff	
#define BRIGHT_RED	0xf810	
#define GRAY1		0x8410  
#define GRAY2		0x4208  

#define MIN_X	0
#define MIN_Y	0

#define TFT_RDX	0
#define TFT_WRX	1
#define TFT_DCX	2
#define TFT_CSX	3

#define TFT_RDX_LO	{TFT_CTRL_PORT &=~(1 << TFT_RDX);}
#define TFT_RDX_HIGH	{TFT_CTRL_PORT |=(1 << TFT_RDX);}
	
#define TFT_WRX_LO	{TFT_CTRL_PORT &=~(1 << TFT_WRX);}
#define TFT_WRX_HIGH	{TFT_CTRL_PORT |=(1 << TFT_WRX);}
	
#define TFT_DCX_LO	{TFT_CTRL_PORT &=~(1 << TFT_DCX);}
#define TFT_DCX_HIGH	{TFT_CTRL_PORT |=(1 << TFT_DCX);}

#define TFT_CSX_LO	{TFT_CTRL_PORT &=~(1 << TFT_CSX);}
#define TFT_CSX_HIGH	{TFT_CTRL_PORT |=(1 << TFT_CSX);}
//****************************************************************************************
void TFT_SendCMD(int cmd);
void TFT_WriteData(int data);
void TFT_SendData(int data);
void TFT_Init(int orient);
void TFT_ClearScreen(void);
void TFT_FillScreen(int XL, int XR, int YU, int YD, int color);
void TFT_FillRectangle(int poX, int poY, int length, int width, int color);
void  TFT_DrawHorizontalLine( int poX, int poY, int length,int color);
void TFT_DrawLine( int x0,int y0,int x1, int y1,int color);
void TFT_DrawVerticalLine( int poX, int poY, int length,int color);
void TFT_DrawRectangle(int poX, int poY, int length, int width,int color);
void TFT_DrawCircle(int poX, int poY, int r,int color);
void TFT_FillCircle(int poX, int poY, int r,int color);
void TFT_SetOrientation(int orient);
void TFT_DrawChar( int ascii, int poX, int poY,int size, int fgcolor);
void TFT_DrawString(char *string,int poX, int poY, int size,int fgcolor);
void TFT_SetPixel(int poX, int poY,int color);
//***************************************************************************************

void TFT_FillBitmap(int poX, int poY, int length, int width, unsigned short *Bitmap);
void TFT_Graf(int XL, int YU, int YD, char  Ydata , char last);
void Read_SD_Pictute(int XL, int XR, int YU, int YD, unsigned short *FileName);

#endif /* TFT_H_ */

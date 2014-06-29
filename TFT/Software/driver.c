/*
 * TFT.c
 *
 *  Created: 14.10.2013 12:47:54
 *   Author: Ovner
 *
 * My additions: 9.02.2014
 *
 * Adapted for ZPUDemos project by AMR June 2014
 *
 * (TFT driver is ILI9341, 320x240 pixels, SPI-driven.)
 *
 */ 
#include "driver.h"
#include "tft.h"
#include "fonts.h"

int MAX_X=0, MAX_Y = 0;
//************************************************************************************
int constrain(int a, int b, int c)
{
	if (a < b)  { return b; }
	if (c < a)	{ return c;	}
	else return a;
}
//*************************************************************************************
__inline void TFT_SendCMD(int cmd)
{ D_C_Write(0);   SPIM_WriteTxData(cmd); CyDelayUs(1);}
//*************************************************************************************
__inline void TFT_WriteData(int Data)
{ D_C_Write(1); SPIM_WriteTxData(Data);} // CyDelayUs(1);}
//*************************************************************************************
__inline void TFT_SendData(int Data)
{
	int data1 = Data>>8;
	int data2 = Data&0xff;
	TFT_WriteData(data1);
	TFT_WriteData(data2);
}
//*************************************************************************************
void TFT_Init(int orient)
{
TFT_SendCMD  (0x01);
CyDelay(100);
//************* Start Initial Sequence **********//
//Power control A
TFT_SendCMD  (0xCB);
TFT_WriteData(0x39);
TFT_WriteData(0x2C);
TFT_WriteData(0x00);
TFT_WriteData(0x34);
TFT_WriteData(0x02);

//Power control B
TFT_SendCMD  (0xCF);
TFT_WriteData(0x00);
TFT_WriteData(0XC1);
TFT_WriteData(0X30);

//Driver timing control A
TFT_SendCMD  (0xE8);
TFT_WriteData(0x85);
TFT_WriteData(0x00);
TFT_WriteData(0x78);

//Driver timing control B
TFT_SendCMD  (0xEA);
TFT_WriteData(0x00);
TFT_WriteData(0x00);

//Power on sequence control
TFT_SendCMD(0xED);
TFT_WriteData(0x64);
TFT_WriteData(0x03);
TFT_WriteData(0X12);
TFT_WriteData(0X81);

//Pump ratio control
TFT_SendCMD (0xF7);
TFT_WriteData(0x20);

//Power Control 1
TFT_SendCMD  (0xC0);
TFT_WriteData(0x23);

//Power Control 2
TFT_SendCMD  (0xC1);
TFT_WriteData(0x10);

//VCOM Control 1
TFT_SendCMD(0xC5);
TFT_WriteData(0x2B);
TFT_WriteData(0x2B);

//Memory Access Control
TFT_SetOrientation(orient);

//Frame Rate Control (In Normal Mode/Full Colors)
TFT_SendCMD(0xB1);
TFT_WriteData(0x00);
TFT_WriteData(0x1B);	// 10

//Display Function Control
TFT_SendCMD(0xB6);
TFT_WriteData(0x0A);
TFT_WriteData(0x82);	// A2  (02 inverts display)

//Enable 3G
TFT_SendCMD(0xF2);
TFT_WriteData(0x02);  //off


//COLMOD: Pixel Format Set
TFT_SendCMD(0x3a);
TFT_WriteData(0x05);  // 0x03 for 19-bit

//Gamma Set
TFT_SendCMD(0x26);   //Gamma
TFT_WriteData(0x01);

//Positive Gamma Correction
TFT_SendCMD(0xE0);
TFT_WriteData(0x0F);
TFT_WriteData(0x31);
TFT_WriteData(0x2B);
TFT_WriteData(0x0C);
TFT_WriteData(0x0E);
TFT_WriteData(0x08);
TFT_WriteData(0x4E);
TFT_WriteData(0xF1);
TFT_WriteData(0x37);
TFT_WriteData(0x07);
TFT_WriteData(0x10);
TFT_WriteData(0x03);
TFT_WriteData(0x0E);
TFT_WriteData(0x09);
TFT_WriteData(0x00);

//Negative Gamma Correction
TFT_SendCMD(0XE1);
TFT_WriteData(0x00);
TFT_WriteData(0x0E);
TFT_WriteData(0x14);
TFT_WriteData(0x03);
TFT_WriteData(0x11);
TFT_WriteData(0x07);
TFT_WriteData(0x31);
TFT_WriteData(0xC1);
TFT_WriteData(0x48);
TFT_WriteData(0x08);
TFT_WriteData(0x0F);
TFT_WriteData(0x0C);
TFT_WriteData(0x31);
TFT_WriteData(0x36);
TFT_WriteData(0x0F);

// Sleep Out
TFT_SendCMD(0x11);
CyDelay(120);
//Display On
TFT_SendCMD(0x29);
}
//*************************************************************************************
void TFT_SetCol(int StartCol,int EndCol)
{
	TFT_SendCMD(0x2A);                                                      /* Column Command address       */
	TFT_SendData(StartCol);
	TFT_SendData(EndCol);
}
//*************************************************************************************
void TFT_SetPage(int StartPage,int EndPage)
{
	TFT_SendCMD(0x2B);                                                      /* Column Command address       */
	TFT_SendData(StartPage);
	TFT_SendData(EndPage);
}
//*************************************************************************************
void TFT_ClearScreen(void)
{
	int i=0;
	TFT_SetCol(0, MAX_X);
	TFT_SetPage(0, MAX_Y);
	TFT_SendCMD(0x2c);                                                  /* start to write to display ra */
	/* m                            */
	for(i=0; i<38400; i++)
	{
		TFT_WriteData(~0);
		TFT_WriteData(~0);
		TFT_WriteData(~0);
		TFT_WriteData(~0);
	}
}
//*************************************************************************************
void TFT_FillScreen(int XL, int XR, int YU, int YD, int color)
{
	unsigned long  XY=0;
	unsigned long i=0;
	color = ~color;
	if(XL > XR)
	{
		XL = XL^XR;
		XR = XL^XR;
		XL = XL^XR;
	}
	if(YU > YD)
	{
		YU = YU^YD;
		YD = YU^YD;
		YU = YU^YD;
	}
	XL = constrain(XL, MIN_X,MAX_X);
	XR = constrain(XR, MIN_X,MAX_X);
	YU = constrain(YU, MIN_Y,MAX_Y);
	YD = constrain(YD, MIN_Y,MAX_Y);

	XY = (XR-XL+1);
	XY = XY*(YD-YU+1);

	TFT_SetCol(XL,XR);
	TFT_SetPage(YU, YD);
	TFT_SendCMD(0x2c);                                                  /* start to write to display ra */
	/* m                            */

	int Hcolor = color>>8;
	int Lcolor = color&0xff;
	for(i=0; i < XY; i++)
	{
		TFT_WriteData(Hcolor);
		TFT_WriteData(Lcolor);
	}

}
//*************************************************************************************
void TFT_SetXY(int poX, int poY)
{
	TFT_SetCol(poX, poX);
	TFT_SetPage(poY, poY);
	TFT_SendCMD(0x2c);
}
//*************************************************************************************
void TFT_SetPixel(int poX, int poY,int color)
{
	TFT_SetXY(poX, poY);
	TFT_SendData(~color);
}
//*************************************************************************************
void TFT_FillRectangle(int poX, int poY, int length, int width, int color)
{
	TFT_FillScreen(poX, poX+length, poY, poY+width, color);
}
//*************************************************************************************
void  TFT_DrawHorizontalLine( int poX, int poY, int length,int color)
{
	int i=0;
	TFT_SetCol(poX,poX + length);
	TFT_SetPage(poY,poY);
	TFT_SendCMD(0x2c);
	for(i=0; i<length; i++)
	TFT_SendData(~color);
}
//*************************************************************************************
void TFT_DrawLine( int x0,int y0,int x1, int y1,int color)
{
	int x = x1-x0;
	int y = y1-y0;
	int dx = abs(x), sx = x0<x1 ? 1 : -1;
	int dy = -abs(y), sy = y0<y1 ? 1 : -1;
	int err = dx+dy, e2;                                                /* error value e_xy             */
	for (;;){                                                           /* loop                         */
		TFT_SetPixel(x0,y0,color);
		e2 = 2*err;
		if (e2 >= dy) {                                                 /* e_xy+e_x > 0                 */
			if (x0 == x1) break;
			err += dy; x0 += sx;
		}
		if (e2 <= dx) {                                                 /* e_xy+e_y < 0                 */
			if (y0 == y1) break;
			err += dx; y0 += sy;
		}
	}
}
//*************************************************************************************
void TFT_DrawVerticalLine( int poX, int poY, int length,int color)
{
	int i=0;
	TFT_SetCol(poX,poX);
	TFT_SetPage(poY,poY+length);
	TFT_SendCMD(0x2c);
	for(i=0; i<length; i++)
	TFT_SendData(~color);
}
//*************************************************************************************
void TFT_DrawRectangle(int poX, int poY, int length, int width,int color)
{
	TFT_DrawHorizontalLine(poX, poY, length, color);
	TFT_DrawHorizontalLine(poX, poY+width, length, color);
	TFT_DrawVerticalLine(poX, poY, width,color);
	TFT_DrawVerticalLine(poX + length, poY, width,color);
}
//*************************************************************************************
void TFT_DrawCircle(int poX, int poY, int r,int color)
{
	int x = -r, y = 0, err = 2-2*r, e2;
	do {
		TFT_SetPixel(poX-x, poY+y,color);
		TFT_SetPixel(poX+x, poY+y,color);
		TFT_SetPixel(poX+x, poY-y,color);
		TFT_SetPixel(poX-x, poY-y,color);
		e2 = err;
		if (e2 <= y) {
			err += ++y*2+1;
			if (-x == y && e2 <= x) e2 = 0;
		}
		if (e2 > x) err += ++x*2+1;
	} while (x <= 0);
}
//*************************************************************************************
void TFT_FillCircle(int poX, int poY, int r,int color)
{
	int x = -r, y = 0, err = 2-2*r, e2;
	do {
		TFT_DrawVerticalLine(poX-x, poY-y, 2*y, color);
		TFT_DrawVerticalLine(poX+x, poY-y, 2*y, color);

		e2 = err;
		if (e2 <= y) {
			err += ++y*2+1;
			if (-x == y && e2 <= x) e2 = 0;
		}
		if (e2 > x) err += ++x*2+1;
	} while (x <= 0);
}
//*************************************************************************************
void TFT_SetOrientation(int orient)
{
	TFT_SendCMD(0x36);
	switch (orient)
	{
		case 0: TFT_WriteData(0x48);
				break;
		case 1: TFT_WriteData(0x28);
				break;
		case 2: TFT_WriteData(0x88);
				break;
		case 3: TFT_WriteData(0xE8);
				break;
	}
	if (orient == 0 || orient == 2)
	{ MAX_X = 239; MAX_Y = 319;	}
	else
	{ MAX_X = 319;	MAX_Y = 239;}
}
//*************************************************************************************
void TFT_DrawChar( int ascii, int poX, int poY,int size, int fgcolor)
{
	int i = 0;   int f =0 ;
	int temp=0, k;
	if((ascii>=32)&&(ascii<=255))	{;}
	else	{ascii = '?'-32;}
	
	for (i = 0; i < FONT_X; i++ ) 
	{
		if ((ascii >= 0x20) && (ascii <= 0x7F))
		{
			temp = (Font16x16[ascii-0x20][i]);// temp = (&Font16x16[ascii-0x20][i]);
		}
		else if ( ascii >= 0xC0 )
		{
			temp = (Font16x16[ascii-0x65][i]);//  temp = (&Font16x16[ascii-0x65][i]);+++++++++++++++++++
		}
		k=i / 8;
		for(f =0 ; f < FONT_Y; f++)
		{
			if((temp>>f)&0x01)
			{
				if (size == 0)TFT_SetPixel(poX+i-(k*8), poY+f+(k*8),fgcolor);
				else TFT_FillRectangle(poX+i*size-(k*8)*size, poY+f*size+(k*8)*size, size, size, fgcolor);
			}
		}
	}
}

//*************************************************************************************
void TFT_DrawString(char *string,int poX, int poY, int size,int fgcolor)
{
	while(*string)
	{
		if((poX + FONT_SPACE) > MAX_X)		{poX = 1; poY = poY + FONT_X*size;}
		
		TFT_DrawChar(*string, poX, poY, size, fgcolor);
		if (size > 0) poX += FONT_SPACE*size;
		else poX += FONT_SPACE;
		string++;
	}
}

//************************************************************************************++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void TFT_FillBitmap(int XL, int XR, int YU, int YD, unsigned short *Bitmap)
{
	unsigned long  XY=0;
	unsigned long i=0;
	XY = (XR-XL+1);
	XY = XY*(YD-YU+1);

	TFT_SetCol(XL,XR);
	TFT_SetPage(YU, YD);
	TFT_SendCMD(0x2c);                     /* start to write to display ra */

	D_C_Write(1);	// Specify data coming by DMA

	HW_TFT(REG_TFT_FRAMEBUFFER)=Bitmap;
	HW_TFT(REG_TFT_FRAMESIZE)=XY;

#if 0
	for(i=0; i < XY; i++)
	{										 //color[i] =( ~color[i+1]);	
	int Hcolor = (~Bitmap[i])>>8;
	int Lcolor = (~Bitmap[i])&0xff;	
		SPIM_WriteTxData(Hcolor);
		SPIM_WriteTxData(Lcolor);
	}
#endif

}



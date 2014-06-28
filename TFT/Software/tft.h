#ifndef TFT_H
#define TFT_H

/* Hardware registers for a TFT module */

#define TFTBASE 0xFFFFFFE0
#define HW_TFT(x) *(volatile unsigned int *)(TFTBASE+x)

#define REG_TFT_CONTROL 0x0
// Bit 0: CS
// Bit 1: D/C
// Bit 2: Reset
// Bit 3: LED
// Bit 8: DMA

#define REG_TFT_SPI 0x4

#define REG_TFT_FRAMEBUFFER 0x8
#define REG_TFT_FRAMESIZE 0xc

void D_C_Write(int d);
void SPIM_WriteTxData(int d);
void TFT_CS_Write(int d);
void TFT_Reset_Write(int d);
void TFT_LED_Write(int d);

#endif


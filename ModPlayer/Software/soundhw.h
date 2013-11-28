#ifndef SOUNDHW_H
#define SOUNDHW_H


struct SoundChannel
{
	char *DAT;	// 0-3
	unsigned int LEN;	// 4-7
	int TRIGGER; // 8-11
	int PERIOD;	// 12-15
	int	VOL;	// 16-19
	int pad1,pad2,pad3; // 20-31
};	// 32 bytes long

#define REG_SOUNDCHANNEL ((struct SoundChannel *)0xfffffd00)

#endif


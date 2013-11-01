#ifndef SOUNDHW_H
#define SOUNDHW_H


struct SoundChannel
{
	char *DAT;	// 0-3
	unsigned int LEN;	// 4-7
	char *REPDAT; 	// 8-11
	unsigned int REPLEN;	// 12-15
	int PERIOD;	// 16-19
	int	VOL;	// 20-23
	int pad1,pad2; // 24-31
};	// 32 bytes long

#define REG_SOUNDCHANNEL ((struct SoundChannel *)0xfffffd00)

#endif


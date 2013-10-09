#ifndef SOUNDHW_H
#define SOUNDHW_H


typedef struct
{
    char *DAT;
    unsigned int LEN;
    char *REPDAT;
    unsigned int REPLEN;
    int	VOL;
} SoundChannel;

volatile struct *SoundChannels=0xffffffd0;

#endif


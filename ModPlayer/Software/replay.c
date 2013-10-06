/*
**  -- PTBUDDY --
** Portable ProTracker 2.3a replayer
**    -------------
**
** Ported from 68k asm (PT2.3a_replay_cia.S) to C by 8bitbubsy
** HINT: Use my mod2h.exe tool for easy injection of modules
** in your production, followed by an EXE packer.
**
** Wave output code removed by Alastair M. Robinson for the ZPU Demo project.
**
*/

#define FRAC_BITS 15

#include <stdio.h>
#include <stdlib.h>

// Structs
typedef struct
{
    // These must be in this order
    short n_note;
    short n_cmd;
    char n_index;
    // -----------

    char *n_start;
    char *n_wavestart;
    char *n_loopstart;
    char n_volume;
    char n_toneportdirec;
    char n_vibratopos;
    char n_tremolopos;
    char n_pattpos;
    char n_loopcount;   
    unsigned char n_cmdlo;
    unsigned char n_finetune;
    unsigned char n_wavecontrol;
    unsigned char n_glissfunk;
    unsigned char n_sampleoffset;
    unsigned char n_toneportspeed;
    unsigned char n_vibratocmd;
    unsigned char n_tremolocmd;
    unsigned char n_funkoffset;
    short n_period;
    short n_wantedperiod;
    unsigned int n_length;
    unsigned int n_replen;
    unsigned int n_repend; 
} PT_CHN;

typedef struct
{
    char *DAT;
    char *REPDAT;
    char VOL;
    char TRIGGER;
    unsigned short INC;
    unsigned int LEN;
    unsigned int REPLEN;
    unsigned int POS;
} P_CHN;

// Arrays
static PT_CHN mt_chan1temp = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
static PT_CHN mt_chan2temp = { 0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
static PT_CHN mt_chan3temp = { 0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
static PT_CHN mt_chan4temp = { 0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
static P_CHN AUD[4] = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
static char *mt_SampleStarts[31] = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };

// Constant Tables
static const unsigned char mt_FunkTable[16] =
{
    0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
};

static const unsigned char mt_VibratoTable[32] = 
{
    0, 24, 49, 74, 97,120,141,161,
    180,197,212,224,235,244,250,253,
    255,253,250,244,235,224,212,197,
    180,161,141,120, 97, 74, 49, 24
};

static const short mt_PeriodTable[606] =
{
    856,808,762,720,678,640,604,570,538,508,480,453,
    428,404,381,360,339,320,302,285,269,254,240,226,
    214,202,190,180,170,160,151,143,135,127,120,113,0,
    850,802,757,715,674,637,601,567,535,505,477,450,
    425,401,379,357,337,318,300,284,268,253,239,225,
    213,201,189,179,169,159,150,142,134,126,119,113,0,
    844,796,752,709,670,632,597,563,532,502,474,447,
    422,398,376,355,335,316,298,282,266,251,237,224,
    211,199,188,177,167,158,149,141,133,125,118,112,0,
    838,791,746,704,665,628,592,559,528,498,470,444,
    419,395,373,352,332,314,296,280,264,249,235,222,
    209,198,187,176,166,157,148,140,132,125,118,111,0,
    832,785,741,699,660,623,588,555,524,495,467,441,
    416,392,370,350,330,312,294,278,262,247,233,220,
    208,196,185,175,165,156,147,139,131,124,117,110,0,
    826,779,736,694,655,619,584,551,520,491,463,437,
    413,390,368,347,328,309,292,276,260,245,232,219,
    206,195,184,174,164,155,146,138,130,123,116,109,0,
    820,774,730,689,651,614,580,547,516,487,460,434,
    410,387,365,345,325,307,290,274,258,244,230,217,
    205,193,183,172,163,154,145,137,129,122,115,109,0,
    814,768,725,684,646,610,575,543,513,484,457,431,
    407,384,363,342,323,305,288,272,256,242,228,216,
    204,192,181,171,161,152,144,136,128,121,114,108,0,
    907,856,808,762,720,678,640,604,570,538,508,480,
    453,428,404,381,360,339,320,302,285,269,254,240,
    226,214,202,190,180,170,160,151,143,135,127,120,0,
    900,850,802,757,715,675,636,601,567,535,505,477,
    450,425,401,379,357,337,318,300,284,268,253,238,
    225,212,200,189,179,169,159,150,142,134,126,119,0,
    894,844,796,752,709,670,632,597,563,532,502,474,
    447,422,398,376,355,335,316,298,282,266,251,237,
    223,211,199,188,177,167,158,149,141,133,125,118,0,
    887,838,791,746,704,665,628,592,559,528,498,470,
    444,419,395,373,352,332,314,296,280,264,249,235,
    222,209,198,187,176,166,157,148,140,132,125,118,0,
    881,832,785,741,699,660,623,588,555,524,494,467,
    441,416,392,370,350,330,312,294,278,262,247,233,
    220,208,196,185,175,165,156,147,139,131,123,117,0,
    875,826,779,736,694,655,619,584,551,520,491,463,
    437,413,390,368,347,328,309,292,276,260,245,232,
    219,206,195,184,174,164,155,146,138,130,123,116,0,
    868,820,774,730,689,651,614,580,547,516,487,460,
    434,410,387,365,345,325,307,290,274,258,244,230,
    217,205,193,183,172,163,154,145,137,129,122,115,0,
    862,814,768,725,684,646,610,575,543,513,484,457,
    431,407,384,363,342,323,305,288,272,256,242,228,
    216,203,192,181,171,161,152,144,136,128,121,114,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0

    // PT BUGFIX: Padded with 14 extra zeros to prevent
    // out-of-boundary reading when doing arpeggio with
    // high notes on finetune +7
};

// Variables
static char *mixerBuffer;
static char tempoMode;
static char mt_SongPos;
static char mt_PosJumpFlag;
static char mt_PBreakFlag;
static char mt_Enable;
static char mt_PBreakPos;
static char mt_PattDelTime;
static char mt_PattDelTime2;
static unsigned char *mt_SongDataPtr;
static unsigned char mt_LowMask;
static unsigned char mt_counter;
static unsigned char mt_speed;
static short SampleCounter;
static short SamplesPerFrame;
static unsigned short mt_PatternPos;
static int *AUDBUFL;
static int *AUDBUFR;
static int TimerVal;
static int extSamplingFreq;

// Macros
#define mt_paulaSetLoop(i, x, y) if (x != NULL) AUD[i].REPDAT = x; AUD[i].REPLEN = y;
#define mt_paulaSetPer(i, x) if (x > 0) AUD[i].INC = (((3546895 / (x)) << FRAC_BITS) / extSamplingFreq);
#define mt_paulaStart(i) AUD[i].POS = 0; AUD[i].TRIGGER = 1;
#define mt_paulaSetVol(i, x) AUD[i].VOL = x;
#define mt_paulaSetLen(i, x) AUD[i].LEN = x;
#define mt_paulaSetDat(i, x) AUD[i].DAT = x;
#define word2AmigaWord(x) (unsigned short)(((x) << 8) | ((x) >> 8))
#define amigaWord2Word(x) (unsigned short)(((x) >> 8) | ((x) << 8))

/* CODE START */


static void mt_UpdateFunk(PT_CHN *ch)
{
    char invertLoopData;
    unsigned char invertLoopSpeed;
    
    invertLoopSpeed = ch->n_glissfunk >> 4;
    if (invertLoopSpeed > 0)
    {
        ch->n_funkoffset += mt_FunkTable[invertLoopSpeed];
        if (ch->n_funkoffset & (1 << 7))
        {
            ch->n_funkoffset = 0;

            if (ch->n_wavestart != NULL)
            {
                ch->n_wavestart++;
                if (ch->n_wavestart >= (ch->n_loopstart + ch->n_replen))
                    ch->n_wavestart = ch->n_loopstart;

                invertLoopData = -1 - *ch->n_wavestart;
                *ch->n_wavestart = invertLoopData;
            }
        }
    }
}

static void mt_SetGlissControl(PT_CHN *ch)
{
    ch->n_glissfunk = (ch->n_glissfunk & 0xF0) | (ch->n_cmdlo & 0x0F);
}

static void mt_SetVibratoControl(PT_CHN *ch)
{
    ch->n_wavecontrol = (ch->n_wavecontrol & 0xF0) | (ch->n_cmdlo & 0x0F);
}

static void mt_SetFineTune(PT_CHN *ch)
{
    ch->n_finetune = ch->n_cmdlo & 0x0F;
}

static void mt_JumpLoop(PT_CHN *ch)
{
    unsigned char dat;

    if (mt_counter == 0)
    {
        dat = ch->n_cmdlo & 0x0F;
        if (dat == 0)
        {
            ch->n_pattpos = mt_PatternPos >> 4;
            return;
        }

        if (ch->n_loopcount <= 0)
        {
            ch->n_loopcount = dat;
        }
        else
        {
            ch->n_loopcount--;
            if (ch->n_loopcount == 0) return;
        }

        mt_PBreakPos = ch->n_pattpos;
        mt_PBreakFlag = 1;
    }
}

static void mt_SetTremoloControl(PT_CHN *ch)
{
    ch->n_wavecontrol = (ch->n_cmdlo << 4) | (ch->n_wavecontrol & 0x0F);
}

static void mt_RetrigNote(PT_CHN *ch)
{
    if (ch->n_cmdlo != 0x90) // empty param
    {
        if (mt_counter == 0)
        {
            if (ch->n_note != 0) return;
        }

        if ((mt_counter % (ch->n_cmdlo & 0x0F)) == 0)
        {
            mt_paulaSetDat(ch->n_index, ch->n_start);
            mt_paulaSetLen(ch->n_index, ch->n_length);
            mt_paulaSetLoop(ch->n_index, ch->n_loopstart, ch->n_replen);

            mt_paulaStart(ch->n_index);
        }
    }
}

static void mt_VolumeSlide(PT_CHN *ch)
{
    if ((ch->n_cmdlo & 0xF0) != 0x00)
    {
        ch->n_volume += (ch->n_cmdlo >> 4);
        if (ch->n_volume > 64) ch->n_volume = 64;

        mt_paulaSetVol(ch->n_index, ch->n_volume);
    }
    else
    {
        ch->n_volume -= (ch->n_cmdlo & 0x0F);
        if (ch->n_volume < 0) ch->n_volume = 0;

        mt_paulaSetVol(ch->n_index, ch->n_volume);
    }
}

static void mt_VolumeFineUp(PT_CHN *ch)
{
    if (mt_counter == 0)
    {
        ch->n_volume += (ch->n_cmdlo & 0x0F);
        if (ch->n_volume > 64) ch->n_volume = 64;

        mt_paulaSetVol(ch->n_index, ch->n_volume);
    }
}

static void mt_VolumeFineDown(PT_CHN *ch)
{
    if (mt_counter == 0)
    {
        ch->n_volume -= (ch->n_cmdlo & 0x0F);
        if (ch->n_volume < 0) ch->n_volume = 0;

        mt_paulaSetVol(ch->n_index, ch->n_volume);
    }
}

static void mt_NoteCut(PT_CHN *ch)
{
    if (mt_counter == (ch->n_cmdlo & 0x0F))
    {
        ch->n_volume = 0;
        mt_paulaSetVol(ch->n_index, 0);
    }
}

static void mt_NoteDelay(PT_CHN *ch)
{
    if (mt_counter == (ch->n_cmdlo & 0x0F))
    {
        if (ch->n_note != 0)
        {
            mt_paulaSetDat(ch->n_index, ch->n_start);
            mt_paulaSetLen(ch->n_index, ch->n_length);
            mt_paulaSetLoop(ch->n_index, ch->n_loopstart, ch->n_replen);

            mt_paulaStart(ch->n_index);
        }
    }
}

static void mt_PatternDelay(PT_CHN *ch)
{
    if (mt_counter == 0)
    {
        if (mt_PattDelTime2 == 0)
            mt_PattDelTime = (ch->n_cmdlo & 0x0F) + 1;
    }
}

static void mt_FunkIt(PT_CHN *ch)
{
    if (mt_counter == 0)
    {
        ch->n_glissfunk = (ch->n_cmdlo << 4) | (ch->n_glissfunk & 0x0F);
        mt_UpdateFunk(ch);
    }
}

static void mt_PositionJump(PT_CHN *ch)
{
    mt_SongPos = ch->n_cmdlo - 1;
    mt_PBreakPos = 0;
    mt_PosJumpFlag = 1;
}

static void mt_VolumeChange(PT_CHN *ch)
{
    ch->n_volume = ch->n_cmdlo;
    if (ch->n_volume > 64) ch->n_volume = 64;

    mt_paulaSetVol(ch->n_index, ch->n_volume);
}

static void mt_PatternBreak(PT_CHN *ch)
{
    mt_PBreakPos = ((ch->n_cmdlo >> 4) * 10) + (ch->n_cmdlo & 0x0F);
    if (mt_PBreakPos > 63)
        mt_PBreakPos = 0;

    mt_PosJumpFlag = 1;
}

static void mt_SetSpeed(PT_CHN *ch)
{
    if (ch->n_cmdlo > 0)
    {
        mt_counter = 0;

        if (tempoMode != 0) // vblank mode
        {
            mt_speed = ch->n_cmdlo;
        }
        else
        {
            if (ch->n_cmdlo >= 32)
                SamplesPerFrame = TimerVal / ch->n_cmdlo;
            else
                mt_speed = ch->n_cmdlo;
        }
    }
}

static void mt_Arpeggio(PT_CHN *ch)
{
    char i;
    unsigned char dat;
    const short *arpPointer;
    
    dat = mt_counter % 3;
    if (dat == 0)
    {
        mt_paulaSetPer(ch->n_index, ch->n_period);
        return;
    }

    if (dat == 1)
        dat = ch->n_cmdlo >> 4;
    else if (dat == 2)
        dat = ch->n_cmdlo & 0x0F;

    arpPointer = &mt_PeriodTable[ch->n_finetune * 37];
    for (i = 0; i < 37; ++i)
    {
        if (arpPointer[i] <= ch->n_period)
        {
            mt_paulaSetPer(ch->n_index, arpPointer[i + dat]);
            return;
        }
    }
}

static void mt_PortaUp(PT_CHN *ch)
{
    ch->n_period -= (ch->n_cmdlo & mt_LowMask);
    if (ch->n_period < 113) ch->n_period = 113;

    mt_paulaSetPer(ch->n_index, ch->n_period);
    mt_LowMask = 0xFF;
}

static void mt_PortaDown(PT_CHN *ch)
{
    ch->n_period += (ch->n_cmdlo & mt_LowMask);
    if (ch->n_period > 856) ch->n_period = 856;

    mt_paulaSetPer(ch->n_index, ch->n_period);
    mt_LowMask = 0xFF;
}

static void mt_FinePortaUp(PT_CHN *ch)
{
    if (mt_counter == 0)
    {
        mt_LowMask = 0x0F;
        mt_PortaUp(ch);
    }
}

static void mt_FinePortaDown(PT_CHN *ch)
{
    if (mt_counter == 0)
    {
        mt_LowMask = 0x0F;
        mt_PortaDown(ch);
    }
}

static void mt_SetTonePorta(PT_CHN *ch)
{
    char i;
    const short *portaPointer;
    
    portaPointer = &mt_PeriodTable[ch->n_finetune * 37];
    for (i = 0; i < 37; ++i)
    {
        if (portaPointer[i] <= ch->n_note)
            break;
    }

    if ((ch->n_finetune & (1 << 3)) && (i > 0))
        i--;

    ch->n_wantedperiod = portaPointer[i];
    ch->n_toneportdirec = 0;

    if (ch->n_period == ch->n_wantedperiod)
        ch->n_wantedperiod = 0;
    else if (ch->n_period > ch->n_wantedperiod)
        ch->n_toneportdirec = 1;
}

static void mt_UpdateTonePortamento(PT_CHN *ch)
{
    char i;
    const short *portaPointer;
    
    if (ch->n_wantedperiod > 0)
    {
        if (ch->n_toneportdirec)
        {
            ch->n_period -= ch->n_toneportspeed;
            if (ch->n_period <= ch->n_wantedperiod)
            {
                ch->n_period = ch->n_wantedperiod;
                ch->n_wantedperiod = 0;
            }
        }
        else
        {
            ch->n_period += ch->n_toneportspeed;
            if (ch->n_period >= ch->n_wantedperiod)
            {
                ch->n_period = ch->n_wantedperiod;
                ch->n_wantedperiod = 0;
            }
        }

        if ((ch->n_glissfunk & 0x0F) != 0)
        {
            portaPointer = &mt_PeriodTable[ch->n_finetune * 37];
            for (i = 0; i < 37; ++i)
            {
                if (portaPointer[i] <= ch->n_period)
                    mt_paulaSetPer(ch->n_index, portaPointer[i]);
            }
        }
        else
        {
            mt_paulaSetPer(ch->n_index, ch->n_period);
        }
    }
}

static void mt_TonePortamento(PT_CHN *ch)
{
    if (ch->n_cmdlo != 0)
    {
        ch->n_toneportspeed = ch->n_cmdlo;
        ch->n_cmdlo = 0;
    }

    mt_UpdateTonePortamento(ch);
}

static void mt_UpdateVibrato(PT_CHN *ch)
{
    unsigned char vibratoTemp;
    short vibratoData; 

    vibratoTemp = (ch->n_vibratopos >> 2) & 0x1F;
    vibratoData = ch->n_wavecontrol & 3;

    if (vibratoData == 0)
    {
        vibratoData = mt_VibratoTable[vibratoTemp];
    }
    else
    {
        vibratoTemp <<= 3;

        if (vibratoData == 1)
        {
            if (ch->n_vibratopos < 0)
                vibratoData = 255 - vibratoTemp;
            else
                vibratoData = vibratoTemp;
        }
        else
        {
            vibratoData = 255;
        }
    }

    vibratoData = (vibratoData * (ch->n_vibratocmd & 0x0F)) >> 7;

    if (ch->n_vibratopos >= 0)
        vibratoData = ch->n_period + vibratoData;
    else
        vibratoData = ch->n_period - vibratoData;

    mt_paulaSetPer(ch->n_index, vibratoData);

    ch->n_vibratopos += ((ch->n_vibratocmd >> 2) & 0x3C);
}

static void mt_Vibrato(PT_CHN *ch)
{
    if (ch->n_cmdlo != 0)
    {
        if (ch->n_cmdlo & 0x0F)
            ch->n_vibratocmd = (ch->n_vibratocmd & 0xF0) | (ch->n_cmdlo & 0x0F);
        
        if (ch->n_cmdlo & 0xF0)
            ch->n_vibratocmd = (ch->n_cmdlo & 0xF0) | (ch->n_vibratocmd & 0x0F);
    }

    mt_UpdateVibrato(ch);
}

static void mt_TonePlusVolSlide(PT_CHN *ch)
{
    mt_UpdateTonePortamento(ch);
    mt_VolumeSlide(ch);
}

static void mt_VibratoPlusVolSlide(PT_CHN *ch)
{
    mt_UpdateVibrato(ch);
    mt_VolumeSlide(ch);
}

static void mt_UpdateTremolo(PT_CHN *ch)
{
    char tremoloData; 
    unsigned char tremoloTemp;

    tremoloTemp = (ch->n_tremolopos >> 2) & 0x1F;
    tremoloData = (ch->n_wavecontrol >> 4) & 3;

    if (tremoloData == 0)
    {
        tremoloData = mt_VibratoTable[tremoloTemp];
    }
    else
    {
        tremoloTemp <<= 3;

        if (tremoloData == 1)
        {
            if (ch->n_vibratopos < 0) // PT typo/bug
                tremoloData = 255 - tremoloTemp;
            else
                tremoloData = tremoloTemp;
        }
        else
        {
            tremoloData = 255;
        }
    }

    tremoloData = (tremoloData * (ch->n_tremolocmd & 0x0F)) >> 6;

    if (ch->n_tremolopos >= 0)
    {
        tremoloData = ch->n_volume + tremoloData;
        if (tremoloData > 64) tremoloData = 64;
    }
    else
    {
        tremoloData = ch->n_volume - tremoloData;
        if (tremoloData < 0) tremoloData = 0;
    }

    mt_paulaSetVol(ch->n_index, tremoloData);

    ch->n_tremolopos += ((ch->n_tremolocmd >> 2) & 0x3C);
}

static void mt_Tremolo(PT_CHN *ch)
{
    if (ch->n_cmdlo != 0)
    {
        if (ch->n_cmdlo & 0x0F)
            ch->n_tremolocmd = (ch->n_tremolocmd & 0xF0) | (ch->n_cmdlo & 0x0F);
        
        if (ch->n_cmdlo & 0xF0)
            ch->n_tremolocmd = (ch->n_cmdlo & 0xF0) | (ch->n_tremolocmd & 0x0F);
    }

    mt_UpdateTremolo(ch);
}

static void mt_SampleOffset(PT_CHN *ch)
{
    unsigned short newOffset;

    if (ch->n_cmdlo != 0)
        ch->n_sampleoffset = ch->n_cmdlo;

    newOffset = ch->n_sampleoffset << 8;

    if (newOffset < ch->n_length)
    {
        ch->n_length -= newOffset;
        ch->n_start += newOffset;
    }
    else
    {
        ch->n_length = 0;
    }  
}

static void mt_E_Commands(PT_CHN *ch)
{
    switch (ch->n_cmdlo >> 4)
    {
        case 0x00:                           break; // <-- No filter (yet?)
        case 0x01: mt_FinePortaUp(ch);       break;
        case 0x02: mt_FinePortaDown(ch);     break;
        case 0x03: mt_SetGlissControl(ch);   break;
        case 0x04: mt_SetVibratoControl(ch); break;
        case 0x05: mt_SetFineTune(ch);       break;
        case 0x06: mt_JumpLoop(ch);          break;
        case 0x07: mt_SetTremoloControl(ch); break;
        case 0x08:                           break; // <- No Karplus-Strong (yet?)
        case 0x09: mt_RetrigNote(ch);        break;
        case 0x0A: mt_VolumeFineUp(ch);      break;
        case 0x0B: mt_VolumeFineDown(ch);    break;
        case 0x0C: mt_NoteCut(ch);           break;
        case 0x0D: mt_NoteDelay(ch);         break;
        case 0x0E: mt_PatternDelay(ch);      break;
        case 0x0F: mt_FunkIt(ch);            break;     
    }
}

static void mt_CheckMoreEfx(PT_CHN *ch)
{
    mt_UpdateFunk(ch);

    switch (ch->n_cmd >> 8)
    {
        case 0x09: mt_SampleOffset(ch); break;
        case 0x0B: mt_PositionJump(ch); break;
        case 0x0C: mt_VolumeChange(ch); break;
        case 0x0D: mt_PatternBreak(ch); break;
        case 0x0E: mt_E_Commands(ch);   break;
        case 0x0F: mt_SetSpeed(ch);     break;
        default: mt_paulaSetPer(ch->n_index, ch->n_period); break;
    }
}

static void mt_CheckEfx(PT_CHN *ch)
{
    mt_UpdateFunk(ch);

    if (ch->n_cmd == 0)
    {
        mt_paulaSetPer(ch->n_index, ch->n_period);
        return;
    }

    switch (ch->n_cmd >> 8)
    {
        case 0x00: mt_Arpeggio(ch);            break;
        case 0x01: mt_PortaUp(ch);             break;
        case 0x02: mt_PortaDown(ch);           break;
        case 0x03: mt_TonePortamento(ch);      break;
        case 0x04: mt_Vibrato(ch);             break;
        case 0x05: mt_TonePlusVolSlide(ch);    break;
        case 0x06: mt_VibratoPlusVolSlide(ch); break;
        case 0x0E: mt_E_Commands(ch);          break;
        case 0x07:
            mt_paulaSetPer(ch->n_index, ch->n_period);
            mt_Tremolo(ch);
        break;
        case 0x0A:
            mt_paulaSetPer(ch->n_index, ch->n_period);
            mt_VolumeSlide(ch);
        break;
        default: mt_paulaSetPer(ch->n_index, ch->n_period); break;
    }
}

static void mt_SetPeriod(PT_CHN *ch)
{
    char i;
 
    for (i = 0; i < 37; ++i)
    {
        if (ch->n_note >= mt_PeriodTable[i])
            break;
    }

    ch->n_period = mt_PeriodTable[(ch->n_finetune * 37) + i];

    if ((ch->n_cmd & 0x0FF0) == 0x0ED0)
    {
        mt_CheckMoreEfx(ch);
        return;
    }

    if ((ch->n_wavecontrol & (1 << 2)) == 0) ch->n_vibratopos = 0;
    if ((ch->n_wavecontrol & (1 << 6)) == 0) ch->n_tremolopos = 0;
 
    mt_paulaSetDat(ch->n_index, ch->n_start);
    mt_paulaSetLen(ch->n_index, ch->n_length);
    mt_paulaSetPer(ch->n_index, ch->n_period);

    mt_paulaStart(ch->n_index);

    mt_CheckMoreEfx(ch);
}

static void mt_PlayVoice(PT_CHN *ch, int pattPos)
{
    char cmd;
    unsigned char sample;
    unsigned char pattData[4];
    short sampleOffset;
    unsigned int repeat;
    
    if (*((unsigned int *)ch) == 0) // no note, cmd nor param
        mt_paulaSetPer(ch->n_index, ch->n_period);
   
    *((unsigned int *)pattData) = *((unsigned int *)&mt_SongDataPtr[1084 + pattPos]);

    ch->n_note = ((pattData[0] & 0x0F) << 8) | pattData[1];
    ch->n_cmd = ((pattData[2] & 0x0F) << 8) | pattData[3];
    ch->n_cmdlo = pattData[3];
    
    sample = (pattData[0] & 0xF0) | (pattData[2] >> 4);
    if ((sample >= 1) && (sample <= 32))
    {
        sample--;
        sampleOffset = (42 + (sample * 30));

        ch->n_start = mt_SampleStarts[sample];
        ch->n_finetune = mt_SongDataPtr[sampleOffset + 2]; // should mask nybble, but whatever
        ch->n_volume = mt_SongDataPtr[sampleOffset + 3]; // should clamp >64, but whatever

        ch->n_length = amigaWord2Word(*((unsigned short *)&mt_SongDataPtr[sampleOffset])) << 1;
        ch->n_replen = amigaWord2Word(*((unsigned short *)&mt_SongDataPtr[sampleOffset + 6])) << 1;
        repeat = amigaWord2Word(*((unsigned short *)&mt_SongDataPtr[sampleOffset + 4])) << 1;

        if (ch->n_replen > 2)
        {
            ch->n_loopstart = ch->n_start + repeat;
            ch->n_wavestart = ch->n_start + repeat;
            ch->n_length = repeat + ch->n_replen;
        }
        else
        {
            ch->n_loopstart = ch->n_start;
            ch->n_wavestart = ch->n_start;
        }

        mt_paulaSetVol(ch->n_index, ch->n_volume);
    }

    if (ch->n_note == 0)
    {
        mt_CheckMoreEfx(ch);
        return;
    }

    if ((ch->n_cmd & 0x0FF0) == 0x0E50)
    {
        mt_SetFineTune(ch);
        mt_SetPeriod(ch);
        return;
    }

    cmd = ch->n_cmd >> 8;
    if ((cmd == 0x03) || (cmd == 0x05))
    {
        mt_SetTonePorta(ch);
        mt_CheckMoreEfx(ch);
        return;
    }
    else if (cmd == 0x09)
    {
        mt_CheckMoreEfx(ch);
        mt_SetPeriod(ch);
        return;
    }

    mt_SetPeriod(ch);
}

static void mt_nextPosition(void)
{
    mt_PatternPos = mt_PBreakPos << 4;
    mt_PBreakPos = 0;
    mt_PosJumpFlag = 0;

    mt_SongPos = (mt_SongPos + 1) & 0x7F;
    if (mt_SongPos >= mt_SongDataPtr[950]) mt_SongPos = 0;
}

static void mt_dskip(void)
{
    mt_PatternPos += 16;

    if (mt_PattDelTime > 0)
    {
        mt_PattDelTime2 = mt_PattDelTime;
        mt_PattDelTime = 0;
    }

    if (mt_PattDelTime2 > 0)
    {
        mt_PattDelTime2--;
        if (mt_PattDelTime2 > 0) mt_PatternPos -= 16;
    }

    if (mt_PBreakFlag == 1)
    {
        mt_PBreakFlag = 0;
        mt_PatternPos = mt_PBreakPos << 4;
        mt_PBreakPos = 0;
    }

    if ((mt_PatternPos >= 1024) || (mt_PosJumpFlag == 1))
        mt_nextPosition();
}

void mt_music(void)
{
    int pattPos;

    if (mt_Enable == 1)
    {
        mt_counter++;
        if (mt_counter >= mt_speed)
        {
            mt_counter = 0;

            if (mt_PattDelTime2 == 0)
            {
                pattPos = (mt_SongDataPtr[952 + mt_SongPos] << 10) + mt_PatternPos;

                mt_PlayVoice(&mt_chan1temp, pattPos); pattPos += 4;
                mt_PlayVoice(&mt_chan2temp, pattPos); pattPos += 4;
                mt_PlayVoice(&mt_chan3temp, pattPos); pattPos += 4;
                mt_PlayVoice(&mt_chan4temp, pattPos); pattPos += 4;

                mt_paulaSetLoop(0, mt_chan1temp.n_loopstart, mt_chan1temp.n_replen);
                mt_paulaSetLoop(1, mt_chan2temp.n_loopstart, mt_chan2temp.n_replen);
                mt_paulaSetLoop(2, mt_chan3temp.n_loopstart, mt_chan3temp.n_replen);
                mt_paulaSetLoop(3, mt_chan4temp.n_loopstart, mt_chan4temp.n_replen);
            }
            else
            {
                mt_CheckEfx(&mt_chan1temp);
                mt_CheckEfx(&mt_chan2temp);
                mt_CheckEfx(&mt_chan3temp);
                mt_CheckEfx(&mt_chan4temp);
            }

            mt_dskip();
        }
        else
        {
            mt_CheckEfx(&mt_chan1temp);
            mt_CheckEfx(&mt_chan2temp);
            mt_CheckEfx(&mt_chan3temp);
            mt_CheckEfx(&mt_chan4temp);

            if (mt_PosJumpFlag == 1) mt_nextPosition();
        }
    }
}

void mt_init(unsigned char *mt_data)
{
    char *sampleStarts;
    char pattNum;
    unsigned char i;

    mt_SongDataPtr = mt_data;

    pattNum = 0;
    for (i = 0; i < 128; ++i)
    {
        if (mt_SongDataPtr[952 + i] > pattNum)
            pattNum = mt_SongDataPtr[952 + i];
    }
    pattNum++;

    sampleStarts = (char *)&mt_SongDataPtr[1084 + (pattNum << 10)];
    for (i = 0; i < 31; ++i)
    {
        mt_SampleStarts[i] = sampleStarts;
        sampleStarts += (amigaWord2Word(*((unsigned short *)&mt_SongDataPtr[42 + (i * 30)])) << 1);
    }

    mt_speed = 6;
    mt_counter = 0;
    mt_SongPos = 0;
    mt_PatternPos = 0;
    mt_Enable = 0;
    mt_PattDelTime = 0;
    mt_PattDelTime2 = 0;
    mt_PBreakPos = 0;
    mt_PosJumpFlag = 0;
    mt_PBreakFlag = 0;
    mt_LowMask = 0xFF;
}


int ptBuddyPlay(unsigned char *modData, char timerType, int soundFrequency)
{
    char i;

    mt_Enable = 0;

    mt_init(modData);

    extSamplingFreq = soundFrequency;

    tempoMode = (timerType > 0) ? 1 : 0; // 0 = cia, 1 = vblank
    TimerVal = (soundFrequency * 125) / 50;
    SamplesPerFrame = TimerVal / 125;
    SampleCounter = 0;

    mt_Enable = 1;

    return (1);
}


void ptBuddyClose(void)
{
    char i;

    mt_Enable = 0;
}

/* END OF FILE */


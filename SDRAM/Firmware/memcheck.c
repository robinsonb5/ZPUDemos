
#ifdef DEBUG
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#else
#include "small_printf.h"
#include "uart.h"
#endif

// FIXME - use a smaller LFSR - this one will fail for RAMs smaller than 8 meg.
#define CYCLE_LFSR {lfsr<<=1; if(lfsr&0x400000) lfsr|=1; if(lfsr&0x200000) lfsr^=1;}

// Force a read-read of cache contents.  Takes the size of the cache (in bytes) as a parameter.
// Works using a brute-force read of four times as much data as will fit in the cache, ensuring
// that everything has to be flushed out.
void refreshcache(volatile int *base,int size)
{
	int t;
	int i;

	for(i=0;i<size;++i)
		t=*base++;
}


// Sanity check.  First stage check, writes and reads a bit pattern, and ensures that the same
// bit pattern is read back, before and after a cache refresh.

static const int sanitycheck_bitpatterns[]={0x00000000,0x55555555,0xaaaaaaaa,0xffffffff};

int sanitycheck(volatile int *base,int cachesize)
{
	int result=1;
	int i;
	for(i=0;i<(sizeof(sanitycheck_bitpatterns)/sizeof(int));++i)
	{
		*base=sanitycheck_bitpatterns[i];
		if (*base!=sanitycheck_bitpatterns[i])
		{
			printf("Sanity check failed (before cache refresh) on 0x%d (got 0x%d)\n",sanitycheck_bitpatterns[i],*base);
			result=0;
		}
		refreshcache(base,cachesize);
		if (*base!=sanitycheck_bitpatterns[i])
		{
			printf("Sanity check failed (after cache refresh) on 0x%d (got 0x%d)\n",sanitycheck_bitpatterns[i],*base);
			result=0;
		}
	}
	return(result);
}


int bytecheck(volatile int *base,int cachesize)
{
	int result=1;
	volatile char *b2=(volatile char *)base;

	base[0]=0x55555555;
	base[3]=0xaaaaaaaa;

	b2[0]=0xcc;	// Write high byte
	b2[15]=0x33; // Write low byte

	if(base[0]!=0xcc555555)
	{
		printf("Byte check failed (before cache refresh) at 0 (got 0x%d)\n",base[0]);
		result=0;
	}

	if(base[3]!=0xaaaaaa33)
	{
		printf("Byte check failed (before cache refresh) at 3 (got 0x%d)\n",base[3]);
		result=0;
	}

	refreshcache(base,cachesize);

	if(base[0]!=0xcc555555)
	{
		printf("Byte check failed (after cache refresh) at 0 (got 0x%d)\n",base[0]);
		result=0;
	}

	if(base[3]!=0xaaaaaa33)
	{
		printf("Byte check failed (after cache refresh) at 3 (got 0x%d)\n",base[3]);
		result=0;
	}

	return(result);
}


#define LFSRSEED 12467

int lfsrcheck(volatile int *base,unsigned int size)
{
	int result;
	int cycles=127;
	int goodreads=0;
	// Shift left 20 bits to convert to megabytes, then 2 bits right since we're dealing with longwords
	unsigned int mask=(size<<18)-1;

	printf("Checking memory");

	unsigned int lfsr=LFSRSEED;
	while(--cycles)
	{
		int i;
		unsigned int lfsrtemp;
		unsigned int addrmask;
		putchar('.');
		CYCLE_LFSR;
		addrmask|=lfsr;
		addrmask&=mask;
		lfsrtemp=lfsr;
		for(i=0;i<262144;++i)
		{
			unsigned int w=lfsr&0xfffff;
			unsigned int j=lfsr&0xfffff;
			base[j^addrmask]=w;
			CYCLE_LFSR;
		}
		lfsr=lfsrtemp;
		for(i=0;i<262144;++i)
		{
			unsigned int w=lfsr&0xfffff;
			unsigned int j=lfsr&0xfffff;
			unsigned int jr;
			jr=base[j^addrmask];
			if(jr!=w)
			{
				result=0;
				printf("0x%d good reads, ",goodreads);
				printf("Error at 0x%d, expected 0x%d, got 0x%d\n",j, w,jr);
				goodreads=0;
			}
			else
				++goodreads;
			CYCLE_LFSR;
		}
	}
	putchar('\n');
	return(result);
}


// Check for bad address bits and aliases.

#define ADDRCHECKWORD 0x55aa44bb
#define ADDRCHECKWORD2 0xf0e1d2c3

unsigned int addresscheck(volatile int *base,int cachesize)
{
	int result=1;
	int i,j,k;
	int a1,a2;
	int aliases=0;
	unsigned int size=64;
	// Seed the RAM;
	a1=1;
	*base=ADDRCHECKWORD;
	for(j=1;j<25;++j)
	{
		a2=1;
		for(i=1;i<25;++i)
		{
			base[a1|a2]=ADDRCHECKWORD;
			a2<<=1;
		}
		a1<<=1;
	}	
	refreshcache(base,cachesize);

	// Now check for aliases
	a1=1;
	*base=ADDRCHECKWORD2;
	for(j=1;j<25;++j)
	{
		if(base[a1]==ADDRCHECKWORD2)
		{
			// An alias isn't necessarily a failure.
			aliases|=a1;
		}
		else if(base[a1]!=ADDRCHECKWORD)
		{
			result=0;
			printf("Bad data found at 0x%d (0x%d)\n",a1<<2, base[a1]);
		}
		a1<<=1;
	}
	aliases<<=2;
	if(aliases)
	{
		printf("Aliases found at 0x%d\n",aliases);

		while(aliases)
		{
			if((aliases&0x2000000)==0)	// If the alias bits aren't contiguously the high bits, then it indicates a bad address.
				result=0;
			aliases=(aliases<<1)&0x3ffffff;	// Test currently supports up to 16m longwords = 64 megabytes.
			size>>=1;
		}
		if(result && (size<64))
			printf("(Aliases probably simply indicate that RAM\nis smaller than 64 megabytes)\n");
		else
			size=1;
	}
	printf("SDRAM size (assuming no address faults) is 0x%d megabytes\n",size);
	
	return(size);
}


#define CACHESIZE 4096

int main(int argc, char **argv)
{
	volatile int *base=0;
#ifdef DEBUG
	base=(volatile int *)malloc(64*1024*1024);	// Standalone, buildable on Linux for testing
#else
	HW_UART(REG_UART_CLKDIV)=UART_115200; // Running on the ZPU
#endif

	while(1)
	{
		int size;
		if(sanitycheck(base,CACHESIZE))
			printf("First stage sanity check passed.\n");
		if(bytecheck(base,CACHESIZE))
			printf("Byte (dqm) check passed\n");
		if(size=addresscheck(base,CACHESIZE))
			printf("Address check passed.\n");
		if(lfsrcheck(base,size))
			printf("LFSR check passed.\n\n");
	}
	return(0);
}


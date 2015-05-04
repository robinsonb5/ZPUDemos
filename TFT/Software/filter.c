// #include "small_printf.h"
#include <stdio.h>
#include "filter.h"


void Filter_Init(struct Filter *f)
{
	f->state=FILTER_EMPTY;
	f->pointer=0;
}


void Filter_Add(struct Filter *f,int sample)
{
	f->samples[f->pointer]=sample;

	++f->pointer;
	if(f->pointer>=FILTER_SAMPLES)
		f->pointer=0;

	if(f->state==FILTER_EMPTY)
	{
		if(f->pointer==0)
			f->state=FILTER_UNSORTED;
	}
	else
		f->state=FILTER_UNSORTED;
}


static void Filter_Sort(struct Filter *f)
{
	int i,j,k;
	f->sorted[0]=f->samples[0];
	for(i=1;i<FILTER_SAMPLES;++i)
	{
		int p=i;
		int s=f->samples[i];
		for(j=0;j<=i;++j)
		{
			if(f->sorted[j]>s)
			{
				p=j;
				for(j=i;j>p;--j)
					f->sorted[j]=f->sorted[j-1];
				j=i;
			}
		}
		f->sorted[p]=s;
	}
	f->state=FILTER_SORTED;
}


int Filter_GetMedian(struct Filter *f)
{
	if(f->state==FILTER_EMPTY)
		return(FILTER_BADVALUE);

	if(f->state==FILTER_UNSORTED)
		Filter_Sort(f);

	return(f->sorted[FILTER_SAMPLES/2]);
}


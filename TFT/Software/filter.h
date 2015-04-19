#ifndef FILTER_H
#define FILTER_H

#define FILTER_SAMPLES 5
#define FILTER_BADVALUE -0x80000000
enum FilterState {FILTER_EMPTY,FILTER_UNSORTED,FILTER_SORTED};

struct Filter
{
	int samples[FILTER_SAMPLES];
	int sorted[FILTER_SAMPLES];
	int pointer;
	enum FilterState state;
};

#ifdef __cplusplus
extern "C" {
#endif
void Filter_Init(struct Filter *filter);
void Filter_Add(struct Filter *filter,int sample);
int Filter_GetMedian(struct Filter *filter);
#ifdef __cplusplus
}
#endif

#endif

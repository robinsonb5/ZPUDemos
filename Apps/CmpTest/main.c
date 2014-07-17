#include "uart.h"

#include "small_printf.h"

volatile int t;

char charbuffer[40];

int scmptest(int s1,int s2)
{
	if(s1<s2)
		return(1);
	return(0);
}

int ucmptest(unsigned int s1,unsigned s2)
{
	if(s1<s2)
		return(1);
	return(0);	
}

int main(int argc, char **argv)
{
	unsigned int i1, i2;
	int j1, j2;
	printf("   \n");
	for(i1=0;i1<=0xf;i1+=0x1)
	{
		for(i2=0;i2<=0xf;i2+=0x1)
		{
			printf("%d, ",ucmptest(i1<<30,i2<<30));
		}
		printf("   \n");
	}

	printf("   \n");
	for(j1=0;j1<=0xf;j1+=0x1)
	{
		for(j2=0;j2<=0xf;j2+=0x1)
		{
			printf("%d, ",scmptest(j1<<30,j2<<30));
		}
		printf("   \n");
	}

	return(0);
}


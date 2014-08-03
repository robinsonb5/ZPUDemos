#include "uart.h"
#include <stdio.h>

int main(int argc, char **argv)
{
	float t=39.57;
	int i;
	printf("Testing printf\n");
	printf("Integer: %d\n",123456);
	printf("Float: %lf\n",t);
	for(i=0;i<20;++i)
	{
		int r;
		t+=93.15;
		r=t;
		printf("%f, %d\n",t,r);
	}
	return(0);
}


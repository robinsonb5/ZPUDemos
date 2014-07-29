
#define HW_REG(x) (*(volatile int *)(0xffffff00+x))
#define REG_DELAY 0xf8
#define REG_LED 0xfc

int main(int argc, char **argv)
{
	int p=0;
	int i=0;

	while(1)
	{
		for(i=0;i<=(HW_REG(REG_DELAY)+512);++i)
		{
			int j;
			int t;
			for(j=0;j<512;++j)
				t=HW_REG(REG_DELAY);
		}
		HW_REG(REG_LED)=p;
		p^=1;
	}

	return(0);
}


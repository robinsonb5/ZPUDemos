#ifndef GLOBALTEST_H
#define GLOBALTEST_H

class globaltest
{
	public:
	globaltest(int v) : v(v)
	{
		printf("In GlobalTest constructor: %d\n",v);
	}
	~globaltest()
	{
		printf("In GlobalTest destructor\n");
	}
	protected:
	int v;
};

class globaltest2
{
	public:
	globaltest2(int v) : v(v)
	{
		printf("In GlobalTest2 constructor: %d\n",v);
	}
	~globaltest2()
	{
		printf("In GlobalTest2 destructor\n");
	}
	protected:
	int v;
};

class globalstatictest
{
	public:
	globalstatictest()
	{
		printf("In GlobalStaticTest constructor\n");
	}
	~globalstatictest()
	{
	}
	protected:
	static globaltest2 gt2;
};


#endif


#include "uart.h"

#include "small_printf.h"


class globaltest
{
	public:
	globaltest()
	{
		printf("In GlobalTest constructor\n");
	}
	~globaltest()
	{
		printf("In GlobalTest destructor\n");
	}
};

globaltest gt;


class test
{
	public:
	test()
	{
		printf("In test constructor\n");
	}
	~test()
	{
		printf("In test destructor\n");
	}
	virtual void Go()
	{
		printf("Hello World!\n");
	}
};

class subtest : public test
{
	public:
	subtest() : test()
	{
		printf("In subtest constructor\n");
	}
	~subtest()
	{
		printf("In subtest destructor\n");
	}
	virtual void Go()
	{
		printf("Wait for it...\n");
		test::Go();
		throw "Exception test\n";
	}
};


int main(int argc, char **argv)
{
	subtest test;
	try
	{
		test.Go();
	}
	catch(const char *err)
	{
		printf(err);
	}
	return(0);
}



extern "C" {

#include "uart.h"

#include "small_printf.h"
};

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


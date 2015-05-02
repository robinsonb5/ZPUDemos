#include "uart.h"

#include <map>
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


template <class T> class templatetest
{
	public:
	templatetest(T *p) : ptr(p)
	{
		printf("Received pointer to object at %x\n",ptr);
	}
	~templatetest()
	{
	}
	protected:
	T *ptr;
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
	templatetest<subtest> templ(&test);
	std::map<int,char *> mymap;
	try
	{
		mymap[0]="Hello world!\n";
		mymap[1]="Another line of text\n";
		mymap[2]="And another one!\n";
		for(int i=0;i<3;++i)
			printf(mymap[i]);
		test.Go();
	}
	catch(const char *err)
	{
		printf(err);
	}
	return(0);
}


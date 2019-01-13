#include "testlib.h"
using namespace std;

int main(int argc, char * argv[])
{
	registerChecker("problemname", argc, argv);

	compareRemainingLines();
}

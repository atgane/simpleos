#include "interrupt.h"
#include "function.h"

int main() {
	kprintf("We are now in C!", 10, 10);
	
	init_intdesc();
}
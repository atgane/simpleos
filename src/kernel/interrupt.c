#include "interrupt.h"
#include "function.h"

// 총 3개 선언
// ignore
// timer
// keyboard 의미
struct IDT inttable[3]; 
// idt 크기가 하나에 8이고 256개를 등록할 것을 명시
// 적재될 주소는 무조건 0
struct IDTR idtr = { 256 * 8 - 1,0 };

unsigned char keyt[2] = { 'A', 0 };
unsigned char key[2] = { 'A', 0 };

void init_intdesc() {
    int i, j;
    unsigned int ptr;
    unsigned short *isr;

    { // 0x00 : isr_ignore
        ptr = (unsigned int)idt_ignore; // 해당 위치에 아래의 값을 삽입
        inttable[0].offsetl =   (unsigned short)(ptr & 0xFFFF); // 하위는 and로 남김
        inttable[0].selector =  (unsigned short)0x0008; // code segment
        inttable[0].type =      (unsigned short)0x8E00; // P: 1, DPL: 0, D: 1
        inttable[0].offseth =   (unsigned short)(ptr >> 16); // 상위라 16을 밀어서 남김
    }
    
    { // 0x01 : isr_timer
        ptr = (unsigned int)idt_timer; // 해당 위치에 아래의 값을 삽입
        inttable[1].offsetl =   (unsigned short)(ptr & 0xFFFF); // 하위는 and로 남김
        inttable[1].selector =  (unsigned short)0x0008; // code segment
        inttable[1].type =      (unsigned short)0x8E00; // P: 1, DPL: 0, D: 1
        inttable[1].offseth =   (unsigned short)(ptr >> 16); // 상위라 16을 밀어서 남김
    }
    
    { // 0x02 : isr_keyboard
        ptr = (unsigned int)idt_keyboard; // 해당 위치에 아래의 값을 삽입
        inttable[2].offsetl =   (unsigned short)(ptr & 0xFFFF); // 하위는 and로 남김
        inttable[2].selector =  (unsigned short)0x0008; // code segment
        inttable[2].type =      (unsigned short)0x8E00; // P: 1, DPL: 0, D: 1
        inttable[2].offseth =   (unsigned short)(ptr >> 16); // 상위라 16을 밀어서 남김
    }

    for (i = 0; i < 256; i++) {
        isr = (unsigned short*)(0x0 + i * 8); // 지정될 위치
        // 일단 기본으로 싹다 ignore에 배치
        *isr = inttable[0].offsetl; 
        *(isr + 1) = inttable[0].selector;
        *(isr + 2) = inttable[0].type;
        *(isr + 3) = inttable[0].offseth;
    }

    {
        isr = (unsigned short*)(0x0 + 0x20 * 8); // 지정될 위치
        // 0x20에 timer 등록
        *isr = inttable[1].offsetl; 
        *(isr + 1) = inttable[1].selector;
        *(isr + 2) = inttable[1].type;
        *(isr + 3) = inttable[1].offseth;
    }

    {
        isr = (unsigned short*)(0x0 + 0x21 * 8); // 지정될 위치
        // 0x21에 timer 등록
        *isr = inttable[2].offsetl; 
        *(isr + 1) = inttable[2].selector;
        *(isr + 2) = inttable[2].type;
        *(isr + 3) = inttable[2].offseth;
    }

    // 인터럽트 동작 시작 코드: 이것도 그냥 받아들이자. 
    __asm__ __volatile__("mov eax, %0"::"r"(&idtr));    // idtr이 가리키는 메모리 주소를 eax에 로드
	__asm__ __volatile__("lidt [eax]");                 // 인터럽트 디스크립터 테이블 로드: lgdt와 비슷하다고 생각하면 될 거 같다. 
	__asm__ __volatile__("mov al,0xFC");                // ~0xFC = 0b0000 0011 빼고 나머지 인터럽트를
	__asm__ __volatile__("out 0x21,al");                // 봉인(일거야 아마)
	__asm__ __volatile__("sti");                        // 인터럽트 플래그 IF 활성화

	return;
}

void idt_ignore() {
    __asm__ __volatile__
	(
		"push gs;"
		"push fs;"
		"push es;"
		"push ds;"
		"pushad;"
		"pushfd;"
		"mov al, 0x20;"
		"out 0x20, al;"
	);

	kprintf("idt_ignore", 5, 40);
	
	__asm__ __volatile__
	(
		"popfd;"
		"popad;"
		"pop ds;"
		"pop es;"
		"pop fs;"
		"pop gs;"
		"leave;"
		"nop;"
		"iretd;"
	);
}

void idt_timer() {
	__asm__ __volatile__
	(
		"push gs;"
		"push fs;"
		"push es;"
		"push ds;"
		"pushad;"
		"pushfd;"
		"mov al, 0x20;"
		"out 0x20, al;"
	);

	kprintf(keyt, 7, 40);
	keyt[0]++;

	__asm__ __volatile__
	(
		"popfd;"
		"popad;"
		"pop ds;"
		"pop es;"
		"pop fs;"
		"pop gs;"
		"leave;"
		"nop;"
		"iretd;"
	);
}

void idt_keyboard() {
    __asm__ __volatile__
	(
		"push gs;"
		"push fs;"
		"push es;"
		"push ds;"
		"pushad;"
		"pushfd;"
		"in al, 0x60;"
		"mov al, 0x20;"
		"out 0x20, al;"
	);

	kprintf(key, 8, 40);
	key[0]++;

	__asm__ __volatile__
	(
		"popfd;"
		"popad;"
		"pop ds;"
		"pop es;"
		"pop fs;"
		"pop gs;"
		"leave;"
		"nop;"
		"iretd;"
	);
}
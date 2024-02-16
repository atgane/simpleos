#pragma once

void init_intdesc();
void idt_ignore();
void idt_timer();
void idt_keyboard();

struct IDT
{
    // 8바이트 영역에 gdt와 비슷한 데이터를 명시
	unsigned short offsetl; // 하위 오프셋
	unsigned short selector; // 핸들러가 저장된 코드 세그먼트의 셀렉터 값을 16비트 단위로 저장
	unsigned short type; // 속성 영역: P, DPL(2), 0, D, 1, 1, 0, 0(8)로 구성
	// P: 세그먼트 메모리 존재 여부. 항상 1
	// DPL: 핸들러가 실행될 특권
	// D: 지정한 코드 세그먼트가 16비트인지 32비트인지 여부
	unsigned short offseth; // 상위 오프셋

}__attribute__((packed)); // 컴파일러의 패딩을 없애기 위한 라인

struct IDTR
{
    // 6바이트 영역에 gdtr과 비슷한 데이터를 명시
	unsigned short size; // 총 사이즈
	unsigned int addr; // 시작 위치

}__attribute__((packed));
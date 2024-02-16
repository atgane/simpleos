org 0
bits 16

jmp 0x7C0:start

start:
    ; segment register initializing
    mov ax, cs
    mov ds, ax
    mov es, ax

    mov ax, 0xB800
    mov es, ax

    mov byte[es:0], 'h'
    mov byte[es:1], 0x09
    mov byte[es:2], 'i'
    mov byte[es:3], 0x09

read:

    ; disk sector reading
    mov ax, 0x1000
    mov es, ax
    mov bx, 0   ; 0x1000:0000 -> 0x10000 주소 위치에 
                ; 섹터 1에 대한 데이터를 복사

    mov ah, 2   ; 인터럽트 13에 대한 ah 2번 인자는 disk reading
	mov al, 20   ; 읽을 섹터 수: 20
	mov ch, 0   ; 실린더 번호: 0
	mov cl, 2   ; 섹터 번호: 2
	mov dh, 0   ; 헤더 번호: 0
	mov dl, 0   ; 드라이브 넘버라는데 뭔지 모르겠음
	int 13h
    ; return 
    ; cf = 0 if successful
    ; cf = 1 if error

    jc read

    mov dx, 0x3F2 ;플로피디스크 드라이브의
	xor al, al	; 모터를 끈다
	out dx, al 

	cli

pic:
    ; master pic command: 0x20
    ; master pic data: 0x21
    ; slave pic command: 0xA0
    ; slave pic data: 0xA1
    
    ; icw1
    ; pic 초기화에 이용
    mov al, 0x11	; 이건 그냥 받아들이자. 0x11이 필요
	out 0x20, al
	dw 0x00eb, 0x00eb
	out 0xA0, al
	dw 0x00eb, 0x00eb
	
    ; icw2
    ; pic 인터럽트를 받았을 때 irq에 얼마를 더하여 cpu에 알려줄지 지정
	mov al, 0x20    ; 이것도 받아들이자. 이해를 하지말자
	out 0x21, al
	dw 0x00eb, 0x00eb
	mov al, 0x28    ; 슬레이브 pic는 8 irq가 8 이후부터 시작하므로 8을 더해줌
	out 0xA1, al
	dw 0x00eb, 0x00eb
	
    ; icw 3
    ; irq2번에 슬레이브 pic가 연결되어 있다는 것을 마스터 pic에게 알림
	mov al, 0x04	;0x04 = 1 << 2: ir 2번에 슬레이브 pic가 연결됨
	out 0x21, al
	dw 0x00eb, 0x00eb
	mov al, 0x02	;0x02 = 1 << 1: ir 1번에 irq2가 연결됨(아마도?) 
	out 0xA1, al
	dw 0x00eb, 0x00eb
	
    ; icw 4
    ; 추가 명령
	mov al, 0x01	; 8086모드를 사용
	out 0x21, al
	dw 0x00eb, 0x00eb
	out 0xA1, al
	dw 0x00eb, 0x00eb
	
    ; 인터럽트 봉인
	mov al, 0xFF	; 슬레이브 PIC의 모든 인터럽트를
	out 0xA1, al 	; 봉인
	dw 0x00eb, 0x00eb
	mov al, 0xFB	; ~0xFB = 0b0000 0100 빼고 나머지 인터럽트를
	out 0x21, al	; 봉인

; converting to protected mode
lgdt[gdtr]

mov eax, cr0
or eax, 0x1 ; cr0 레지스터의 PE & PG 비트 활성화
mov cr0, eax

jmp $+2
nop
nop

mov bx, DataSegment
mov ds, bx
mov es, bx
mov fs, bx
mov gs, bx
mov ss, bx

jmp dword CodeSegment:0x10000

gdtr:
    dw gdt_end-gdt-1
    dd gdt+0x7C00

gdt:
	dd 0,0 ; NULL 세그
	CodeSegment equ 0x08
	dd 0x0000FFFF, 0x00CF9A00 ; 코드 세그
    ; 뒤부터
    ; 0xFFFF seg lim
    ; 0x0000 base seg 0 ~ 15
    ; 00 base seg 16 ~ 23
    ; 9A 속성 필드
    ; CF 속성 필드
    ; 00 base seg 24 ~ 31
    ; 0000 0000 0000 0000 1111 1111 1111 1111
    ; 0000 0000 1100 1111 1001 1010 0000 0000
	DataSegment equ 0x10
	dd 0x0000FFFF, 0x00CF9200 ; 데이터 세그
	VideoSegment equ 0x18
	dd 0x8000FFFF, 0x0040920B ; 비디오 세그

gdt_end:

times 510-($-$$) db 0
dw 0xAA55
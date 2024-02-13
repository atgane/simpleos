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
	mov al, 1   ; 읽을 섹터 수: 1
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
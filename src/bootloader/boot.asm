org 0x7c0
bits 16

jmp 0x7c0:start

start:
    ; segment register initializing
    mov ax, 0
    mov ds, ax
    mov es, ax

    ; disk sector reading
    mov ax, 0x1000
    mov es, ax
    mov bx, 0   ; 0x1000:0000 -> 0x10000 주소 위치에 
                ; 섹터 1에 대한 데이터를 복사

    mov ah, 2 ; 인터럽트 13에 대한 ah 2번 인자는 disk reading
	mov al, 1 ; 읽을 섹터 수: 1
	mov ch, 0 ; 실린더 번호: 0
	mov cl, 2 ; 섹터 번호: 2
	mov dh, 0 ; 헤더 번호: 0
	mov dl, 0 ; 드라이브 넘버라는데 뭔지 모르겠음
	int 13h

jmp $

times 510-($-$$) db 0
dw 0xAA55
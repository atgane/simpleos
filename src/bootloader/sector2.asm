; Sector2.asm
org 0x10000
bits 32

CodeSegment equ 0x08
DataSegment equ 0x10
VideoSegment equ 0x18

mov ax, VideoSegment
mov es, ax

mov byte[es:0x08], 'P'
mov byte[es:0x09], 0x09
jmp dword CodeSegment:0x10200

times 512-($-$$) db 0
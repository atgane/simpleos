org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

;
; FAT12 header
;

jmp short start ; 3 bytes
nop

bdb_oem:                    db 'MSWIN4.1' ; 8 bytes
bdb_bytes_per_sector:       dw 512 ; 2bytes
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1 ; boot record sectors
bdb_fat_count:              db 2 ; default is 2
bdb_dir_entries_count:      dw 0E0h ; directory entries
bdb_total_sectors:          dw 2880 ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:  db 0F0h ; F0 = 3.5" floppy disk
bdb_sectors_per_fat:        dw 9
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

; extended boot record

ebr_drive_number:           db 0
                            db 0
ebr_signature:              db 29h
ebr_volume_id:              db 12h, 34h, 56h, 78h
ebr_volume_label:           db 'NANOBYTE OS'
ebr_system_id:              db 'FAT12   '

jmp short start
nop

start:
    jmp main

; Prints a string to the screen
; Params:
;   - ds:si points to string
puts:
    ; save registers we will modify
    push si
    push ax
    push bx

.loop:
    lodsb               ; loads next character in al
    or al, al           ; verify if next character is null?
    jz .done

    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0           ; set page number to 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si
    ret

main:
    ; setup data segments
    mov ax, 0           ; can't set ds/es directly
    mov ds, ax
    mov es, ax
    
    ; setup stack
    mov ss, ax
    mov sp, 0x7C00      ; stack grows downwards from where we are loaded in memory

    mov [ebr_drive_number], dl

    mov ax, 1           ; lba = 1, second sector from disk
    mov cl, 1           ; 1 sector to read
    mov bx, 0x7E00      ; data should be after the bootloader
    call disk_read

    ; print hello world message
    mov si, msg_hello
    call puts

    hlt

floppy_error:
    mov si, msg_read_failed
    call puts
    jmp wait_key_and_reboot

wait_key_and_reboot:
    mov ah, 0
    int 16h         ; wait for keypress
    jmp 0FFFFh:0    ; jump beginning to bios, should reboot

.halt:
    cli             ; disable interrupt, this way cpu can't get out of "halt" state
    hlt

lba_to_chs:

    push ax
    push dx

    xor dx, dx                          ; dx = 0
    div word [bdb_sectors_per_track]    ; ax = lba / sectors per track
                                        ; dx = lba % sectors per track
    inc dx                              ; dx = (lba % sectors per track + 1) = sector
    mov cx, dx                          ; cx = sector
    div word [bdb_heads]                ; ax = (lba / sectors per track) / heads = cylinder
                                        ; dx = (lba / sectors per track) % heads = head
    mov dh, dl                          ; dl = head
    mov ch, al                          ; ch = cylinder (lower 8 bits)
    shl ah, 6
    or cl, ah                           ; put upper 2 bits of cylinder in cl

    pop ax
    mov dl, al
    pop ax
    ret

disk_read:
    push ax
    push bx
    push cx
    push dx
    push di

    push cx                 ; temporarily read cl (number of sectors to read)
    call lba_to_chs         ; compute chs
    pop ax                  ; al = number of sectors to read

    mov ah, 02h
    mov di, 3               ; retry count

.retry:
    pusha                   ; save all registers, we don't know what bios modifies
    stc                     ; set carry flag, some BIOS'es don't set it
    int 13h                 ; carry flag cleared= success
    
    ; read failed
    popa
    call disk_reset
    dec di
    test di, di
    jnz .retry

.fail:
    jmp floppy_error

.done:
    popa

    push di
    push dx
    push cx
    push bx
    push ax
    ret

disk_reset:
    pusha
    mov ah, 0
    stc
    int 13h
    jc floppy_error
    popa
    ret

msg_hello:              db 'Hello world!', ENDL, 0
msg_read_failed:        db 'Read from disk failed!', ENDL, 0

times 510-($-$$) db 0
dw 0AA55h
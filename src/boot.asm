; boot.asm - Compact bootloader
[BITS 16]
[ORG 0x7C00]

start:
    ; Set up segments
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Save boot drive
    mov [boot_drive], dl

    ; Print boot message
    mov si, boot_msg
    call print_string

    ; Reset disk
    mov ah, 0x00
    mov dl, [boot_drive]
    int 0x13
    jc hang

    ; Load kernel from sector 2
    mov si, loading_msg
    call print_string
    
    mov ah, 0x02        ; Read sectors
    mov al, 1           ; 1 sector
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Sector 2
    mov dh, 0           ; Head 0
    mov dl, [boot_drive]
    mov bx, 0x1000      ; Load at 0x1000:0x0000
    mov es, bx
    mov bx, 0x0000
    int 0x13

    jc disk_error

    ; Check if kernel loaded
    mov ax, 0x1000
    mov es, ax
    cmp byte [es:0], 0
    je hang

    ; Success - jump to kernel
    mov si, success_msg
    call print_string
    jmp 0x1000:0x0000

disk_error:
    mov si, error_msg
    call print_string
    jmp hang

print_string:
    lodsb
    or al, al
    jz print_done
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    jmp print_string
print_done:
    ret

hang:
    hlt
    jmp hang

boot_drive db 0

boot_msg db 'Simple OS v1.0', 0x0D, 0x0A, 0
loading_msg db 'Loading...', 0
success_msg db 'OK', 0x0D, 0x0A, 0
error_msg db 'ERROR!', 0x0D, 0x0A, 0

times 510-($-$$) db 0
dw 0xAA55
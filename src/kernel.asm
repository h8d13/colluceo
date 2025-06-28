; kernel.asm - Compact interactive kernel
[BITS 16]
[ORG 0x0000]

kernel_start:
    ; Set up segments
    mov ax, 0x1000
    mov ds, ax
    mov es, ax

    ; Clear screen
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Print welcome
    mov si, welcome_msg
    call print_string

command_loop:
    mov si, prompt
    call print_string
    call get_input
    call process_command
    jmp command_loop

print_string:
    lodsb
    or al, al
    jz print_done
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x0F
    int 0x10
    jmp print_string
print_done:
    ret

get_input:
    mov di, input_buffer
    xor cx, cx

input_loop:
    mov ah, 0x00
    int 0x16
    
    cmp al, 0x0D        ; Enter?
    je input_done
    
    cmp al, 0x08        ; Backspace?
    je handle_backspace
    
    cmp cx, 15          ; Shorter buffer
    jae input_loop
    
    ; Echo and store
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x0F
    int 0x10
    stosb
    inc cx
    jmp input_loop

handle_backspace:
    cmp cx, 0
    je input_loop
    
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    
    dec di
    dec cx
    jmp input_loop

input_done:
    mov al, 0
    stosb
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    ret

process_command:
    ; Check help
    mov si, input_buffer
    mov di, cmd_help
    call strcmp
    jz show_help
    
    ; Check hello
    mov si, input_buffer
    mov di, cmd_hello
    call strcmp
    jz say_hello
    
    ; Check clear
    mov si, input_buffer
    mov di, cmd_clear
    call strcmp
    jz clear_cmd
    
    ; Check empty
    cmp byte [input_buffer], 0
    je cmd_done
    
    ; Unknown
    mov si, unknown_msg
    call print_string

cmd_done:
    ret

clear_cmd:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret

strcmp:
    push ax
compare_loop:
    lodsb
    mov ah, [di]
    inc di
    cmp al, ah
    jne not_equal
    or al, al
    jz strings_equal
    jmp compare_loop
not_equal:
    pop ax
    mov ax, 1
    ret
strings_equal:
    pop ax
    xor ax, ax
    ret

show_help:
    mov si, help_msg
    call print_string
    ret

say_hello:
    mov si, hello_msg
    call print_string
    ret

; Compact data
welcome_msg db 'Simple OS v1.0', 0x0D, 0x0A, 'Type help for commands', 0x0D, 0x0A, 0x0A, 0
prompt db 'OS> ', 0
help_msg db 'help, hello, clear', 0x0D, 0x0A, 0
hello_msg db 'Hello World!', 0x0D, 0x0A, 0
unknown_msg db 'Unknown command', 0x0D, 0x0A, 0

cmd_help db 'help', 0
cmd_hello db 'hello', 0
cmd_clear db 'clear', 0

input_buffer times 16 db 0

times 512-($-$$) db 0
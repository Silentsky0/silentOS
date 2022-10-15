ORG 0x0
BITS 16

_start:
    jmp short start ; initialize BPB according to the specification
    nop

times 33  db 0 ; zero out the rest of the BPB

start:
    jmp 0x7c0:step2 ; set code segment to 0x7c0

step2:
    cli     ; clear (diable) interrupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax ; set data segments to be universal for all bioses
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti     ; enable interrupts

    mov ah, 2 ; read sector command
    mov al, 1 ; read one sector
    mov ch, 0 ; low eight bits
    mov cl, 2
    mov dh, 0
    mov bx, buffer
    int 0x13
    jc error

    mov si, buffer
    call print

    jmp $           ; do not go to lower instructions

error:
    mov si, error_message
    call print
    jmp $

print:
.loop:
    lodsb ; load char pointed by si to al
    cmp al, 0
    je .done ; done printing if encountered '0' char
    call print_char
    jmp .loop

.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret

error_message: db 'Failed to load sector', 0

times 510- ($ - $$) db 0 ; zero out 510 bytes of data
dw 0xAA55                ; add boot signature

buffer:

[BITS 32]

global _start
global problem
extern kernel_main

CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start:
    ; set data segments to the correct GDT
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; move the stack furthet
    mov ebp, 0x00200000
    mov esp, ebp

    ; enable the A20 line
    in al, 0x92
    test al, 2
    jnz .after
    or al, 2
    and al, 0xFE
    out 0x92, al
    .after:

    ; remap master PIC
    mov al, 00010001b ; initialization mode
    out 0x20, al

    mov al, 0x20        ; start master ISR at interrupt 0x20
    out 0x21, al

    mov al, 00000001b
    out 0x21, al
    ; remapped master PIC

    call kernel_main
    jmp $

problem:
    int 0

times 512-($ - $$) db 0 ; align kernel.asm to 512 bytes

[bits 16]

global nasm_func

section .text

nasm_func:
    mov   dx, nasm_str
    mov   ah, 0x09
    int   0x21

    ret 

    
section .data
    nasm_str db "Hello from NASM code!", 10, "$"


.code16

.include "../libdos/dos-headers.S"

.globl gas_func

.section .text
gas_func:
    movw   $gas_str, %dx
    movb   $DOS_PRINT_STRING, %ah
    int    $DOS_SYSCALL

    ret
    

.section .data
    gas_str: .ascii "Hello from GAS code!\n$"

.code16

.include "../libdos/dos-headers.S"

.extern nasm_func
.extern gas_func

.section .text
    call   gas_func
    call   nasm_func

    SYS_EXIT

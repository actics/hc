.code16

.section .text

.include "../libdos/dos-headers.S"
.include "../libdos/iofunc.S"

# INPUT:  NONE
# OUTPUT: %al - status
#         %dx - mode | page
get_and_check:
    call  get_mode_page
    cmpb  $SUCCESS, %ah
    jne   1f

    call  check_mode_page
    cmpb  $SUCCESS, %ah
    jne   2f

    movb  $SUCCESS, %al

    ret
1:
    movw  $invalid_argv_message, %dx
    movb  $DOS_PRINT_STRING,     %ah
    int   $DOS_SYSCALL

    jmp   3f
2:
    cmp   $CHECK_MODE_FAIL, %ah
    jne   1f
    
    movw  $invalid_mode_message, %dx
    movb  $DOS_PRINT_STRING,     %ah
    int   $DOS_SYSCALL

    jmp   3f
1:    
    movw  $invalid_page_message, %dx
    movb  $DOS_PRINT_STRING,     %ah
    int   $DOS_SYSCALL

3:  movb $FAIL, %al
    ret


# INPUT:  NONE
# OUTPUT: %ah - status
#         %dx - mode | page
get_mode_page:
    push  %bx

    movb  $SUCCESS,   %bh
    movb  %es:(0x80), %al
    movw  $0x81,      %si

    call  get_number_from_argv
    cmpb  $SUCCESS, %ah
    jne   1f

    movb  %dl, %dh

    call  get_number_from_argv
    cmpb  $SUCCESS, %ah
    jne   1f

    jmp   2f
1:
    movb  $FAIL, %bh
2:
    movb  %bh, %ah
    pop   %bx

    ret


# INPUT:  %dx - mode | page
# OUTPUT: %ah - status
check_mode_page:
    .set CHECK_MODE_FAIL, 0x02
    .set CHECK_PAGE_FAIL, 0x03

    movb  $SUCCESS, %ah

    cmp   $0x07, %dh
    je    3f

    cmp   $0x01, %dh
    jbe   1f

    cmp   $0x03, %dh
    jbe   2f

    movb  $CHECK_MODE_FAIL, %ah
    jmp   5f
1:
    cmp   $0x07, %dl
    ja    4f
    jmp   5f
2:
    cmp   $0x03, %dl
    ja    4f
    jmp   5f
3:
    cmp   $0x00, %dl
    jne   4f
    jmp   5f
4:
    movb  $CHECK_PAGE_FAIL, %ah
5:
    ret


.section .data
    invalid_argv_message:
        .ascii "invalid arguments$"

    invalid_mode_message:
        .ascii "invalid mode$"
    
    invalid_page_message: 
        .ascii "invalid page$"


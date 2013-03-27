.code16

.section .text
    movb  %es:(0x80), %al
    movw  $0x81, %si

    call  get_number_from_argv
    cmpb  $TRUE, %ah
    jne   1f

    movb  %bl, (mode)

    call  get_number_from_argv
    cmpb  $TRUE, %ah
    jne   1f

    movb  %bl, (page)
    
    movb  (mode), %bh
    movb  (page), %bh
    call  check_video_mode_page
    cmpb  $TRUE, %ah
    jne   2f
    
    movb  (mode), %al
    movb  $BIOS_SET_MODE, %ah
    int   $BIOS_VIDEO_CALL

    movb  (page), %al
    movb  $BIOS_SET_PAGE, %ah
    int   $BIOS_VIDEO_CALL

    movb  $BIOS_GET_MODE, %ah
    int   $BIOS_VIDEO_CALL

    movb  $SCREEN_ROWS, (cursor_row)
    subb  $0x03,        %ah
    movb  %ah,          (cursor_column)

    movb  (page),             %bh

    movb  (cursor_row),       %dh
    movb  (cursor_column),    %dl
    movb  $BIOS_SET_POSITION, %ah
    int   $BIOS_VIDEO_CALL

    movb  (mode), %al
    addb  $'0',   %al 
    movw  $0x01,  %cx
    movb  $BIOS_WRITE_CHAR, %ah
    int   $BIOS_VIDEO_CALL

    incb  %dl

    movb  $BIOS_SET_POSITION, %ah
    int   $BIOS_VIDEO_CALL

    movb  $' ', %al
    movb  $BIOS_WRITE_CHAR, %ah
    int   $BIOS_VIDEO_CALL

    incb  %dl

    movb  $BIOS_SET_POSITION, %ah
    int   $BIOS_VIDEO_CALL

    movb  (page), %al
    addb  $'0',   %al 
    movb  $BIOS_WRITE_CHAR, %ah
    int   $BIOS_VIDEO_CALL

    jmp   exit

1:
    movw  $bad_input_message, %dx
    movb  $DOS_PRINT_STRING, %ah
    int   $DOS_SYSCALL
    jmp   exit

2:
    movw  $uncorrect_mode_page_message, %dx
    movb  $DOS_PRINT_STRING, %ah
    int   $DOS_SYSCALL

exit:
 ret
    movb  $DOS_EXIT, %ah
    movb  $SUCCESS,  %al
    int   $DOS_SYSCALL


# Проверка корректности номера режима и страницы
# Выдача размеров экрана
# INPUT:  %bh - video mode
#         %bl - page number
# OUTPUT: %ah - result
check_video_mode_page:
    movb  $FALSE, %ah

    cmpb  $0x02,  %al
    jb    1f
    cmpb  $0x04,  %al
    jb    2f
    cmpb  $0x07,  %al
    je    3f

    jmp   5f
1:
    cmpb  $0x08,  %bl
    jb    4f
    jmp   5f
2:
    cmpb  $0x04,  %bl
    jb    4f
    jmp   5f
3:
    cmpb  $0x08,  %bl
    jb    4f 
    jmp   5f
4:
    movb  $TRUE,  %ah
5:
    ret


.section .data
    uncorrect_mode_page_message:
        .ascii "Uncorrect mode/page$"

    bad_input_message:
        .ascii "Bad input number$"

    mode:
        .byte 0x00
    
    page: 
        .byte 0x00

    cursor_row:
        .byte 0x00

    cursor_column:
        .byte 0x00


.include "../libdos/dos-headers.S"
.include "../libdos/iofunc.S"

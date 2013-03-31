.code16

.include "../libdos/dos-headers.S"
.include "./censqr-defines.S"

.set VIDEO_MODE, 0x03

.section .text
    # устанавливаем видеорежим
    movb  $VIDEO_MODE, %al
    movb  $BIOS_SET_MODE, %ah
    int   $BIOS_VIDEO_CALL
    
    # сохраняем сегмент данных
    push  %ds
    pop   %gs

    # устанавливаем сегмент видеопамяти
.ifne VIDEO_MODE - MONO_VIDEO_MODE
    push  $COLOR_VIDEO_MEMORY_ADDRESS
.else
    push  $MONO_VIDEO_MEMORY_ADDRESS
.endif
    pop   %ds
    
    # устанавливаем рабочий цвет
    movb  $COLOR_GREEN, %dh
    
    # цикл основной отрисовки таблицы
    movb  $0x00,   %al
    movw  $0x00,   %bx
    movw  $0x0100, %cx
    movw  $TABLE_BORDER_RIGTH_TOP, %si
1:
    testb $0x0f, %al
    jnz   2f
    
    movb  $DOUBLE_VERTICAL_LINE, %dl
    call  write_symbol
    addw  $(RIGTH_SPACE+LEFT_SPACE)*2, %si
    call  write_symbol
    call  write_space
    movb  %gs:hex_symbol(%bx), %dl
    incw  %bx
    call  write_symbol
    call  write_space
    movb  $VERTICAL_LINE, %dl
    call  write_symbol
    call  write_space
 2:
    movb  %al, %dl
    incb  %al
    call  write_symbol
    call  write_space
    loop  1b

    # цикл отрисовки верхней шапки
    movw  $0x10, %cx
    movw  $0x00, %bx
    movw  $TOP_HEADER_START, %si
1:
    call  write_space
    movb  %gs:hex_symbol(%bx), %dl
    call  write_symbol
    incw  %bx
    loop  1b

    # отрисовка горизонтальных линий
    movb  $DOUBLE_HORISONTAL_LINE, %dl
    movw  $BORDER_LEFT_TOP, %bx
    call  write_horisontal_line

    movw  $BORDER_LEFT_BOTTOM, %bx
    call  write_horisontal_line

    movb  $HORISONTAL_LINE, %dl
    movw  $TABLE_BORDER_LEFT_TOP-(1+VERTICAL_HEADER_WIDTH)*2, %bx
    call  write_horisontal_line

    # отрисовка остальных символов
    movw  $special_symbols, %si
    movw  $special_symbols_count, %cx
    call  write_special_symbol

    movb  $KEYBOARD_WAIT_CHAR, %ah
    int   $KEYBOARD_CALL

    movb  $SUCCESS, %al
    movb  $DOS_EXIT, %ah
    int   $DOS_SYSCALL


# INPUT: %dx - color | symbol
#        %si - address
# OUTPUT: NONE
write_symbol:
    movw  %dx,  (%si)
    addw  $0x02, %si

    ret


# INPUT: %dh - color
#        %si - address
# OUTPUT: NONE
write_space:
    movb  $' ',  %dl
    movw  %dx,  (%si)
    addw  $0x02, %si

    ret
 

# INPUT:  %gs:%si - start special symbols data
#         %cx - count of symbols
# OUTPUT: NONE
write_special_symbol:
1:
    movb  %gs:(%si),   %dl
    movw  %gs:1(%si),  %bx
    movw  %dx,        (%bx)
    addw  $0x03,       %si
    loop  1b

    ret


# INPUT:  %bx - start_position
#         %dx - color | line_type
# OUTPUT: NONE
write_horisontal_line:
    movw  $BORDER_WIDTH, %cx
1:
    movw  %dx,   (%bx)
    addw  $0x02,  %bx
    loop  1b

    ret


.section .data
    special_symbols:
        .byte LEFT_TOP_DOUBLE_CORNER
        .word BORDER_LEFT_TOP
        .byte RIGTH_TOP_DOUBLE_CORNER
        .word BORDER_RIGTH_TOP
        .byte LEFT_BOTTOM_DOUBLE_CORNER
        .word BORDER_LEFT_BOTTOM
        .byte RIGTH_BOTTOM_DOUBLE_CORNER
        .word BORDER_RIGTH_BOTTOM
        .byte CROSSHAIR
        .word TABLE_BORDER_LEFT_TOP
        .byte DOUBLE_VERTICAL_LINE_LEFT_ONE
        .word TABLE_BORDER_RIGTH_TOP
        .byte DOUBLE_HORISONTAL_LINE_TOP_ONE
        .word TABLE_BORDER_LEFT_BOTTOM
        .byte DOUBLE_VERTICAL_LINE_RIGTH_ONE
        .word TABLE_BORDER_LEFT_TOP - (VERTICAL_HEADER_WIDTH + 1) * 2
        .byte DOUBLE_HORISONTAL_LINE_BOTTOM_ONE
        .word BORDER_LEFT_TOP + (1 + VERTICAL_HEADER_WIDTH) * 2
        .byte DOUBLE_VERTICAL_LINE
        .word TOP_HEADER_START - (1 + VERTICAL_HEADER_WIDTH + 1) * 2
        .byte VERTICAL_LINE
        .word TOP_HEADER_START - 2
        .byte DOUBLE_VERTICAL_LINE
        .word TOP_HEADER_START + TABLE_WIDTH * 2
        .byte DOUBLE_VERTICAL_LINE
        .word BORDER_RIGTH_BOTTOM - SCREEN_WIDTH * 2
        .ascii "\\"
        .word TOP_HEADER_START - 6

    .set special_symbols_count, (. - special_symbols) / 3

    hex_symbol:
        .ascii "0123456789abcdef"


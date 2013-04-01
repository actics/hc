.code16

.set VIDEO_MODE, 0x01

.include "../libdos/dos-headers.S"
.include "./censqr-defines.S"

.section .text
    movb  %0, %al
    movb  $BIOS_SET_PAGE, %ah
    int   $BIOS_VIDEO_CALL

    movb  $BIOS_GET_MODE, %ah
    int   $BIOS_VIDEO_CALL

    movb  %al, (video_mode)

    push  $0xb800
    pop   %es

    # устанавливаем рабочий цвет
    movb  $COLOR_GREEN, %ah

    # устанавливаем стартовую позицию, и размер переноса.
    movw  $0xdc, %di
    movw  $0x28, (space)
    cmpb  $0x01, %al
    jbe   1f
    addw  $0xda, %di
    addw  $0x2a, (space)

    # цикл основной отрисовки таблицы
1:  xorb  %dl, %dl
    xorw  %bp, %bp

1:  addw  (space), %di

    movw  $line_2, %si

    addb  $237, %dl
    cmpb  $240, %dl
    jae   2f
    leaw  line_1(%bp), %si
    addw  $0x04,    %bp
    
2:  subb  $237,   %dl
    movb  1(%si),  %dh

    movw  $0x03, %cx
2:  movb  (%si), %al
    call  write_symbol
    incw  %si
    loop  2b

    movw  $0x10, %cx
2:  movb  %dh, %al
    cmpb  $1, %dl 
    jne   3f
    movb  hex_symbol(%bx), %al
    incw  %bx
    jmp   4f

3:  cmpb   $3, %dl
    jb    4f
    cmpb   $19, %dl
    je    4f
    movb  %bh, %al
    incb  %bh

4:  call  write_symbol
    loop  2b

    movb  (%si), %al
    stosw

    incb  %dl
    cmpb  $20,    %dl
    jne   1b

    ret


# INPUT: %dx - color | symbol
#        %di - address
# OUTPUT: NONE
write_symbol:
    stosw
    cmpb  $1, (video_mode)
    jbe   1f
    movb  %dh,   %al
    stosw

1:  ret


.section .bss
    .lcomm space,        2
    .lcomm video_mode,   1

.section .data
    line_1:
        .byte LEFT_TOP_DOUBLE_CORNER
        .byte DOUBLE_HORISONTAL_LINE
        .byte DOUBLE_HORISONTAL_LINE_BOTTOM_ONE
        .byte RIGTH_TOP_DOUBLE_CORNER

    line_2:
        .byte DOUBLE_VERTICAL_LINE
        .byte SPACE
        .byte VERTICAL_LINE
        .byte DOUBLE_VERTICAL_LINE
        
    line_3:
        .byte DOUBLE_VERTICAL_LINE_RIGTH_ONE
        .byte HORISONTAL_LINE
        .byte CROSSHAIR
        .byte DOUBLE_VERTICAL_LINE_LEFT_ONE

    line_20:
        .byte LEFT_BOTTOM_DOUBLE_CORNER
        .byte DOUBLE_HORISONTAL_LINE
        .byte DOUBLE_HORISONTAL_LINE_TOP_ONE
        .byte RIGTH_BOTTOM_DOUBLE_CORNER

    hex_symbol:
        .ascii "0123456789abcdef"


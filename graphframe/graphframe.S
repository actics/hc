.code16

.include "../libdos/dos-headers.S"

.extern init_mode_12h
.extern restore_mode

.extern draw_horizontal_line
.extern draw_horizontal_stripe
.extern draw_vertical_line
.extern draw_vertical_stripe
.extern draw_frame

.section .text
main:
    call   init_mode_12h

    push   $0x03
    push   $10
    push   $300
    push   $300
    push   $10
    push   $60
    call   draw_frame
    addw   $0x0c, %sp

    movb   $KEYBOARD_WAIT_CHAR, %ah
    int    $KEYBOARD_CALL

    call   restore_mode

    ret


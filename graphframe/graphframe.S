.code16

.include "../libdos/dos-headers.S"

.extern init_mode_12h
.extern restore_mode

.extern draw_horizontal_line
.extern draw_horizontal_stripe
.extern draw_vertical_line
.extern draw_vertical_stripe
.extern draw_frame
.extern draw_circle
.extern install_cursor
.extern uninstall_cursor
.extern show_cursor
.extern hide_cursor
.extern wait_char
.extern on_frame

.section .text
main:
    call   init_mode_12h
    call   install_cursor
    call   show_cursor
    call   draw_current_frame

    movw   $MOUSE_SET_HANDLER, %ax
    movw   $0b00101011, %cx
    movw   $mouse_handler, %dx
    int    $MOUSE_CALL

    push   $3
    push   $15
    push   $200
    push   $200
    call   draw_circle

    call   wait_char
    call   hide_cursor
    call   uninstall_cursor
    call   restore_mode
    
    SYS_EXIT


mouse_handler:
    
    push   (frame_width)
    push   (frame_end_y)
    push   (frame_end_x)
    push   (frame_y)
    push   (frame_x)
    push   %dx
    push   %cx
    call   on_frame
    addw   $14, %sp

    cmpw   $TRUE, %ax
    jne    2f

1:
    cmpw   $2, %bx
    jne    2f

    call   toggle_frame_color
    call   draw_current_frame
2:

    retf

#void draw_current_frame()
draw_current_frame:

START_PROC

    call   hide_cursor

    push   (frame_color)
    push   (frame_width)
    push   (frame_end_y)
    push   (frame_end_x)
    push   (frame_y)
    push   (frame_x)
    call   draw_frame

    call   show_cursor

END_PROC


#void toggle_frame_color()
toggle_frame_color:

START_PROC
    push   %ax

    movw   (frame_color), %ax

1:  incw   %ax
    cmpw   $0x0f, %ax
    jbe    2f

    movw   $0x01, %ax

2:  cmpw   (circle_color), %ax
    je     1b

    movw   %ax, (frame_color)

    pop    %ax
END_PROC


#void toggle_frame_color()
toggle_circle_color:

START_PROC
    push   %ax

    movw   (circle_color), %ax

1:  incw   %ax
    cmpw   $0x0f, %ax
    jbe    2f

    movw   $0x01, %ax

2:  cmpw   (frame_color), %ax
    je     1b
    
    movw   %ax, (circle_color)

    pop    %ax
END_PROC


.section .data
    frame_color:  .word 0x0a
    circle_color: .word 0x05
    frame_width:  .word 10

    frame_x:     .word 10
    frame_y:     .word 10
    frame_end_x: .word 100
    frame_end_y: .word 100

.include "../libdos/iofunc.S"


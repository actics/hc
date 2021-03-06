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
    movw   $0b10111, %cx
    movw   $mouse_handler, %dx
    int    $MOUSE_CALL

    call   draw_current_circle

    call   wait_char
    call   hide_cursor
    call   uninstall_cursor
    call   restore_mode
    
    SYS_EXIT


mouse_handler:
    
    cmpw   $0b10000, %ax
    jne    1f
    
    push   %dx
    push   %cx
    call   rigth_button_pressed
    addw   $4, %sp

1:  cmpw   $0b00010, %ax
    jne    1f

    push   %dx
    push   %cx
    call   left_button_pressed
    addw   $4, %sp

1:  cmpw   $0b00100, %ax
    jne    1f

    push   %dx
    push   %cx
    call   left_button_released
    addw   $4, %sp

1:  cmpw   $0b00001, %ax
    jne    1f

    cmpw   $TRUE, (frame_gripped)
    jne    2f
    
    push   %dx
    push   %cx
    call   drag_event
    addw   $4, %sp

2:  push   %dx
    push   %cx
    call   move_event
    addw   $4, %sp

1:  retf


#void drag_event(x, y)
drag_event:

START_PROC
    push   %ax
    push   %bx
    push   %cx

    movw   (on_frame_mouse_x), %bx
    movw   (on_frame_mouse_y), %cx

    subw   4(%bp), %bx
    subw   6(%bp), %cx

    movw   (frame_color), %ax
    movw   $0x00, (frame_color)
    call   draw_current_frame
    movw   %ax, (frame_color)

    subw   %bx, (frame_x)
    subw   %cx, (frame_y)
    subw   %bx, (frame_end_x)
    subw   %cx, (frame_end_y)

    call   in_screen
    cmpw   $TRUE, %ax
    je     1f

    addw   %bx, (frame_x)
    addw   %cx, (frame_y)
    addw   %bx, (frame_end_x)
    addw   %cx, (frame_end_y)

1:  call   draw_current_frame
    movw   4(%bp), %ax
    movw   %ax, (on_frame_mouse_x)
    movw   6(%bp), %ax
    movw   %ax, (on_frame_mouse_y)

    pop    %cx
    pop    %bx
    pop    %ax
END_PROC


#void move_event(x, y)
move_event:

START_PROC

    push   (frame_end_y)
    push   (frame_y)
    push   6(%bp)
    call   find_interval_place
    addw   $6, %sp

    movw   %ax, %bx

    push   (frame_end_x)
    push   (frame_x)
    push   4(%bp)
    call   find_interval_place
    addw   $6, %sp

    push   (circle_color)
    movw   $0x00, (circle_color)
    call   draw_current_circle
    pop    (circle_color)

    call   draw_current_frame

    movw   %ax, (circle_x)
    movw   %bx, (circle_y)
    call   draw_current_circle


END_PROC


#void find_interval_place(val, from, to)
find_interval_place:

START_PROC

    movw   4(%bp), %ax
    
    cmpw   6(%bp), %ax
    jg     1f

    movw   6(%bp), %ax
    addw   $CIRCLE_GAP, %ax
    jmp    2f

1:  cmpw   8(%bp), %ax
    jb     2f

    movw   8(%bp), %ax
    subw   $CIRCLE_GAP, %ax

2:  
END_PROC


#void left_button_pressed(x, y)
left_button_pressed:

START_PROC
    push   %ax
    
    push   6(%bp)
    push   4(%bp)
    call   on_current_frame
    addw   $4, %sp

    cmpw   $TRUE, %ax
    jne    1f

    movw   $TRUE, (frame_gripped)
    movw   4(%bp), %ax
    movw   %ax,    (on_frame_mouse_x)
    movw   6(%bp), %ax
    movw   %ax,    (on_frame_mouse_y)

1:
    pop    %ax
END_PROC


#void left_button_released(x, y)
left_button_released:

START_PROC
    
    movw   $FALSE, (frame_gripped)

END_PROC


#void rigth_button_pressed(x, y)
rigth_button_pressed:

START_PROC
    push   %ax
    
    push   6(%bp)
    push   4(%bp)
    call   on_current_circle
    addw   $4, %sp
    
    cmpw   $TRUE, %ax
    jne    1f

    call   toggle_circle_color
    call   draw_current_circle

    jmp    2f

1:  push   6(%bp)
    push   4(%bp)
    call   on_current_frame
    addw   $4, %sp
    
    cmpw   $TRUE, %ax
    jne    2f

    call   toggle_frame_color
    call   draw_current_frame
    call   draw_current_circle
2:
    pop    %ax
END_PROC


#bool on_current_frame(x, y)
on_current_frame:
    
START_PROC

    push   $FRAME_WIDTH
    push   (frame_end_y)
    push   (frame_end_x)
    push   (frame_y)
    push   (frame_x)
    push   6(%bp)
    push   4(%bp)
    call   on_frame
    addw   $14, %sp

END_PROC


#bool on_circle(x, y)
on_circle:

START_PROC
    push   %bx

    call   hide_cursor

    movb   $0x00, %bh
    movb   $BIOS_READ_GRAPH_DOT, %ah
    int    $BIOS_VIDEO_CALL

    call   show_cursor

    cmpb   (circle_color), %al
    jne    1f

    movw   $TRUE, %ax
    jmp    2f

1:  movw   $FALSE, %ax
2:
    pop    %bx
END_PROC


#bool on_current_circle(x, y)
on_current_circle:

START_PROC

    push   6(%bp)
    push   4(%bp)
    call   on_circle
    addw   $4, %sp

END_PROC


#void draw_current_frame()
draw_current_frame:

START_PROC

    call   hide_cursor

    push   (frame_color)
    push   $FRAME_WIDTH
    push   (frame_end_y)
    push   (frame_end_x)
    push   (frame_y)
    push   (frame_x)
    call   draw_frame
    addw   $12, %sp

    call   show_cursor

END_PROC


#void draw_current_circle()
draw_current_circle:

START_PROC

    call   hide_cursor

    push   (circle_color)
    push   (circle_radius)
    push   (circle_y)
    push   (circle_x)
    call   draw_circle
    addw   $8, %sp

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


#bool in_screen()
in_screen:

START_PROC

    movw   $FALSE, %ax

    cmpw   $0, (frame_x)
    jl     1f

    cmpw   $0, (frame_y)
    jl     1f

    cmpw   $SCREEN_WIDTH, (frame_end_x)
    jae    1f

    cmpw   $SCREEN_HEIGTH, (frame_end_y)
    jae    1f

    movw   $TRUE, %ax
1:

END_PROC


.set SCREEN_WIDTH,  640
.set SCREEN_HEIGTH, 480
.set FRAME_WIDTH,   5
.set CIRCLE_GAP,    (FRAME_WIDTH - 1) / 2

.section .data

    frame_color:   .word 0x0a
    frame_x:       .word 10
    frame_y:       .word 10
    frame_end_x:   .word 100
    frame_end_y:   .word 200

    circle_color:  .word 0x0c
    circle_radius: .word 5
    circle_x:      .word 12 
    circle_y:      .word 12

    frame_gripped: .word FALSE

    on_frame_mouse_x: .word 0
    on_frame_mouse_y: .word 0

.include "../libdos/iofunc.S"


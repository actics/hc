.code16

.include "../libdos/dos-headers.S"

.globl init_mode_12h
.globl restore_mode
.globl draw_horizontal_line
.globl draw_horizontal_stripe
.globl draw_vertical_line
.globl draw_vertical_stripe
.globl draw_frame

.section .text

#void init_mode_12h()
init_mode_12h:

START_PROC
    push   %ax
    
    movb   $BIOS_GET_MODE,   %ah
    int    $BIOS_VIDEO_CALL
    movb   %al, (old_mode)

    movb   $VM_GR_18,        %al
    movb   $BIOS_SET_MODE,   %ah
    int    $BIOS_VIDEO_CALL

    pop    %ax
END_PROC


#void restore_mode()
restore_mode:

START_PROC
    push   %ax

    movb   (old_mode),      %al
    movb   $BIOS_SET_MODE,  %ah
    int    $BIOS_VIDEO_CALL

    pop    %ax
END_PROC

#void draw_pixel(x, y, color)
draw_pixel:

START_PROC
    push   %ax
    push   %bx
    push   %cx
    push   %dx
    
    call   hide_cursor

    movw   0x4(%bp),     %cx
    movw   0x6(%bp),     %dx
    movb   0x0a,     %al
    movb   (video_page), %bh
    movb   $BIOS_WRITE_GRAPH_DOT, %ah
    int    $BIOS_VIDEO_CALL

    call   show_cursor

    pop    %dx
    pop    %cx
    pop    %bx
    pop    %ax
END_PROC


# void draw_horizontal_line(x, y, len, color)
draw_horizontal_line:

START_PROC
    push   %ax
    push   %bx
    push   %cx
    push   %dx
    push   %di

    movw   0x4(%bp), %cx
    movw   0x6(%bp), %dx
    movw   0x8(%bp), %di

    call   hide_cursor

1:  testw  %di, %di
    je     1f
/*
    push   0xa(%bp)
    push   %dx
    push   %cx
    call   draw_pixel
    addw   $8, %sp
*/
    movb   0xa(%bp),    %al
    movb   (video_page), %bh
    movb   $BIOS_WRITE_GRAPH_DOT, %ah
    int    $BIOS_VIDEO_CALL

    inc    %cx
    dec    %di
    jmp    1b
1:
    call   show_cursor

    pop    %di
    pop    %dx
    pop    %cx
    pop    %bx
    pop    %ax
END_PROC


# void draw_vertical_line(x, y, len, color)
draw_vertical_line:

START_PROC
    push   %ax
    push   %bx
    push   %cx
    push   %dx
    push   %di

    movw   4(%bp), %cx
    movw   6(%bp), %dx
    movw   8(%bp), %di

    call   hide_cursor

1:  testw  %di, %di
    je     1f

    movb   0xa(%bp),    %al
    movb   (video_page), %bh
    movb   $BIOS_WRITE_GRAPH_DOT, %ah
    int    $BIOS_VIDEO_CALL

    incw   %dx
    dec    %di
    jmp    1b
1:
    call   show_cursor

    pop    %di
    pop    %dx
    pop    %cx
    pop    %bx
    pop    %ax
END_PROC


#void draw_horizontal_stripe(x, y, len, width, color)
draw_horizontal_stripe:

START_PROC
    push   %bx
    push   %cx
    push   %dx
    push   %di

    movw   0x4(%bp), %bx
    movw   0x6(%bp), %dx
    movw   0x8(%bp), %di
    movw   0xa(%bp), %cx

1:  push   0xc(%bp)
    push   %di
    push   %dx
    push   %bx
    call   draw_horizontal_line
    addw   $8, %sp

    incw   %dx
    loop   1b
    
    pop   %di
    pop   %dx
    pop   %cx
    pop   %bx
END_PROC


#void draw_vertical_stripe(x, y, len, width)
draw_vertical_stripe:

START_PROC
    push   %bx
    push   %cx
    push   %dx
    push   %di

    movw   0x4(%bp), %bx
    movw   0x6(%bp), %dx
    movw   0x8(%bp), %di
    movw   0xa(%bp), %cx

1:  push   0xc(%bp)
    push   %di
    push   %dx
    push   %bx
    call   draw_vertical_line
    addw   $8, %sp

    incw   %bx
    loop   1b
    
    pop   %di
    pop   %dx
    pop   %cx
    pop   %bx
END_PROC


#void draw_frame(start_x, start_y, end_x, end_y, width, color)
draw_frame:

START_PROC
    push   %ax
    push   %bx
    push   %cx
    push   %dx
    push   %di

    movw   0x4(%bp), %ax
    movw   0x6(%bp), %bx
    movw   0x8(%bp), %cx
    movw   0xa(%bp), %dx
    movw   0xc(%bp), %di

    subw   $0x04, %sp

    movw   %cx, -2(%bp)
    movw   %dx, -4(%bp)

    subw   %ax, -2(%bp)
    subw   %bx, -4(%bp)
    incw   -2(%bp)
    incw   -4(%bp)

    push   0xe(%bp)
    push   %di
    push   -2(%bp)
    push   %bx
    push   %ax
    call   draw_horizontal_stripe
    addw   $0x0a, %sp

    push   0xe(%bp)
    push   %di
    push   -4(%bp)
    push   %bx
    push   %ax
    call   draw_vertical_stripe
    addw   $0x0a, %sp

    subw   %di, %cx
    subw   %di, %dx
    incw   %cx
    incw   %dx

    push   0xe(%bp)
    push   %di
    push   -2(%bp)
    push   %dx
    push   %ax
    call   draw_horizontal_stripe
    addw   $0x0a, %sp

    push   0xe(%bp)
    push   %di
    push   -4(%bp)
    push   %bx
    push   %cx
    call   draw_vertical_stripe
    addw   $0x0a, %sp

    addw   $0x04, %sp

    pop    %di
    pop    %dx
    pop    %cx
    pop    %bx
    pop    %ax
END_PROC


#void show_cursor()
show_cursor:
    push   %ax
    movw   $MOUSE_SHOW_CURSOR, %ax
    int    $MOUSE_CALL
    pop    %ax
    ret


#void hide_cursor()
hide_cursor:
    push   %ax
    movw   $MOUSE_HIDE_CURSOR, %ax
    int    $MOUSE_CALL
    pop    %ax
    ret


.section .data
    video_page: .byte 0x00

    video_seg:  .word 0xA000
    vwidth:     .word 640
    vheight:    .word 480

    msg: .ascii "OLO!\n$"

.section .bss
    .lcomm old_mode, 1


.code16

.include "../libdos/dos-headers.S"

.globl init_mode_12h
.globl restore_mode
.globl draw_horizontal_line
.globl draw_horizontal_stripe
.globl draw_vertical_line
.globl draw_vertical_stripe
.globl draw_frame
.globl draw_circle
.globl install_cursor
.globl uninstall_cursor
.globl show_cursor
.globl hide_cursor
.globl wait_char
.globl on_frame
.globl on_circle

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
    
    movw   0x4(%bp),     %cx
    movw   0x6(%bp),     %dx
    movb   0x8(%bp),     %al
    movb   (video_page), %bh
    movb   $BIOS_WRITE_GRAPH_DOT, %ah
    int    $BIOS_VIDEO_CALL

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

1:  testw  %di, %di
    je     1f

    push   0xa(%bp)
    push   %dx
    push   %cx
    call   draw_pixel
    addw   $6, %sp

    inc    %cx
    dec    %di
    jmp    1b
1:
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

1:  testw  %di, %di
    je     1f

    push   0xa(%bp)
    push   %dx
    push   %cx
    call   draw_pixel
    addw   $6, %sp

    incw   %dx
    dec    %di
    jmp    1b
1:
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
    subw   $0x04, %sp
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


    pop    %di
    pop    %dx
    pop    %cx
    pop    %bx
    pop    %ax
END_PROC


#void draw_circle(x, y, radius, color)
draw_circle:

START_PROC
    push   %ax
    push   %bx
    push   %cx
    push   %dx
    push   %di
    push   %si 

    movw   $1,     %bx
    xorw   %cx,    %cx
    movw   8(%bp), %cx
    subw   %cx,    %bx 
    movw   $1,     %si 
    movw   $-2,    %ax
    imulw  %cx 
    movw   %ax,    %di 
    movw   $0,     %cx 
    xorw   %dx,    %dx
    movw   8(%bp), %dx       
    
    push   4(%bp)       
    movw   6(%bp), %ax       
    addw   8(%bp), %ax
    push   %ax
    push   10(%bp)
    call   draw_special_pixel

    push   4(%bp)       
    movw   6(%bp), %ax       
    subw   8(%bp), %ax
    push   %ax
    push   10(%bp)
    call   draw_special_pixel

    movw   4(%bp), %ax       
    addw   8(%bp), %ax
    push   %ax
    movw   4(%bp), %ax       
    subw   8(%bp), %ax
    push   %ax
    push   6(%bp)       
    push   10(%bp)
    call   draw_special_line
    
1:  cmpw   $0,     %bx
    jl     2f

    decw   %dx 
    addw   $2,     %di 
    addw   %di,    %bx 

2:  incw   %cx 
    addw   $2,     %si 
    addw   %si,    %bx 

    movw   4(%bp), %ax       
    addw   %cx,    %ax
    push   %ax
    movw   4(%bp), %ax       
    subw   %cx,    %ax
    push   %ax
    movw   6(%bp), %ax       
    addw   %dx,    %ax
    push   %ax
    push   10(%bp)
    call   draw_special_line

    movw   4(%bp), %ax       
    addw   %cx,    %ax
    push   %ax
    movw   4(%bp), %ax       
    subw   %cx,    %ax
    push   %ax
    movw   6(%bp), %ax       
    subw   %dx,    %ax
    push   %ax
    push   10(%bp)
    call   draw_special_line

    movw   4(%bp), %ax       
    addw   %dx,    %ax
    push   %ax
    movw   4(%bp), %ax       
    subw   %dx,    %ax
    push   %ax
    movw   6(%bp), %ax       
    addw   %cx,    %ax
    push   %ax
    push   10(%bp)
    call   draw_special_line

    movw   4(%bp), %ax       
    addw   %dx,    %ax
    push   %ax
    movw   4(%bp), %ax       
    subw   %dx,    %ax
    push   %ax
    movw   6(%bp), %ax       
    subw   %cx,    %ax
    push   %ax
    push   10(%bp)
    call   draw_special_line
    
    cmpw   %dx,    %cx
    jl     1b

    pop    %si
    pop    %di
    pop    %dx
    pop    %cx
    pop    %bx
    pop    %ax
END_PROC


#void draw_special_pixel(x, y, color)
draw_special_pixel:

START_PROC
    
    push   4(%bp)
    push   6(%bp)
    push   8(%bp)
    call   draw_pixel
    addw   $6, %sp

    movw   %bp, %sp
    pop    %bp
    ret    $6


#void draw_special_line(x_to, x_from, y, color)
draw_special_line:

START_PROC
    push   %ax

    movw   10(%bp), %ax
    subw   8(%bp), %ax
    incw   %ax

    push   4(%bp)
    push   %ax
    push   6(%bp)
    push   8(%bp)
    call   draw_horizontal_line
    addw   $8, %sp
    
    pop    %ax
    movw   %bp, %sp
    pop    %bp
    ret    $8


#bool on_frame(x, y, start_x, start_y, end_x, end_y, width)
on_frame:

START_PROC
    subw   $20, %sp

    push   %bx
    push   %cx

    movw   16(%bp), %bx # width

    movw   4(%bp), %ax
    movw   %ax,    -2(%bp)  # x
    movw   6(%bp), %ax
    movw   %ax,    -4(%bp)  # y
    movw   8(%bp), %ax
    movw   %ax,    -6(%bp)  # sx
    movw   10(%bp), %ax
    movw   %ax,    -8(%bp)  # sy
    movw   12(%bp), %ax
    movw   %ax,    -10(%bp) # ex
    movw   14(%bp), %ax
    movw   %ax,    -12(%bp) # ey

    movw   -6(%bp), %ax
    addw   %bx, %ax
    movw   %ax,    -14(%bp) # sx + w
    movw   -8(%bp), %ax
    addw   %bx, %ax
    movw   %ax,    -16(%bp) # sy + w
    movw   -10(%bp), %ax
    subw   %bx, %ax
    movw   %ax,    -18(%bp) # ex - w
    movw   -12(%bp), %ax
    subw   %bx, %ax
    movw   %ax,    -20(%bp) # ey - w
   
    movw   $FALSE, %ax

    movw   -4(%bp), %bx # y

    movw   -8(%bp), %cx # sy
    cmpw   %cx, %bx     # y < sy
    jb     1f

    movw   -16(%bp), %cx # sy + w
    cmpw   %cx, %bx      # y > sy + w
    jg     1f

    jmp    2f

1:  movw   -12(%bp), %cx # ey
    cmpw   %cx, %bx      # y > ey
    jg     3f

    movw   -20(%bp), %cx # ey - w
    cmpw   %cx, %bx      # y < ey - w
    jb     3f

    jmp    2f

2:  movw   -2(%bp), %bx # x

    movw   -6(%bp), %cx # sx
    cmpw   %cx, %bx     # x < sx
    jb     3f

    movw   -10(%bp), %cx # ex
    cmpw   %cx, %bx      # x > ex
    jg     3f

    movw   $TRUE, %ax
    jmp    4f

3:  movw   -2(%bp), %bx # x

    movw   -6(%bp), %cx # sx
    cmpw   %cx, %bx     # x < sx
    jb     1f

    movw   -14(%bp), %cx # sx + w
    cmpw   %cx, %bx      # x > sx + w
    jg     1f

    jmp    2f

1:  movw   -10(%bp), %cx # ex
    cmpw   %cx, %bx      # x > ex
    jg     3f

    movw   -18(%bp), %cx # ex - w
    cmpw   %cx, %bx      # x < ex - w
    jb     3f

    jmp    2f

2:  movw   -4(%bp), %bx # y

    movw   -8(%bp), %cx # sy
    cmpw   %cx, %bx     # y < sy
    jb     3f

    movw   -12(%bp), %cx # ey
    cmpw   %cx, %bx      # y > ey
    jg     3f

    movw   $TRUE, %ax
    jmp    4f

3:
4:
    pop    %cx
    pop    %bx
END_PROC


#bool on_circle(x, y, circle_x, circle_y, radius)
on_circle:

START_PROC
    push   %bx
    push   %cx
    push   %dx
    push   %di

    movw   $FALSE,  %ax

    movw   4(%bp),  %bx
    addw   6(%bp),  %bx

    andw   $0xf, %bx
    cmpw   $0xf, %bx
    jne    1f

    movw   $TRUE, %ax
1:
    pop    %di
    pop    %dx
    pop    %cx
    pop    %bx
END_PROC


#void install_cursor()
install_cursor:
    push   %ax
    movw   $MOUSE_INSTALL, %ax
    int    $MOUSE_CALL
    pop    %ax
    ret
    

#void uninstall_cursor()
uninstall_cursor:
    push   %ax
    push   %cx
    movw   $0, %cx
    movw   $MOUSE_SET_HANDLER, %ax
    int    $MOUSE_CALL
    pop    %cx
    pop    %ax
    ret
    

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


#void wait_char()
wait_char:
    push   %ax 
    movb   $KEYBOARD_WAIT_CHAR, %ah
    int    $KEYBOARD_CALL
    pop    %ax
    ret


.section .data
    video_page: .byte 0x00
    video_seg:  .word 0xA000

.section .bss
    .lcomm old_mode, 1

.include "../libdos/iofunc.S"


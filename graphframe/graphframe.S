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

.section .text
main:
    call   init_mode_12h
    call   install_cursor
    call   show_cursor

    push   $3
    push   $10
    push   $200
    push   $100
    push   $10
    push   $60
    call   draw_frame
    addw   $0xc, %sp

    movw   $MOUSE_SET_HANDLER, %ax
    movw   $0b00000001, %cx
    movw   $mouse_handler, %dx
    int    $MOUSE_CALL

    call   wait_char
    call   hide_cursor
    call   uninstall_cursor
    call   restore_mode

    movb  $DOS_EXIT, %ah
    int   $DOS_SYSCALL


mouse_handler:
    
    push $5
    
    push   $10
    push   $200
    push   $100
    push   $10
    push   $60
    push   %dx
    push   %cx
    call   on_frame
    addw   $14, %sp

    cmpw   $TRUE, %ax
    jne    1f

    pop    %cx
    push   $10
1:

    push $10
    push $10
    push $300
    push $300
    call draw_horizontal_stripe
    addw $0xa, %sp
    retf
 

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

    addw   $20, %sp
END_PROC

.include "../libdos/iofunc.S"



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
    movb   8(%bp), %cl
    subw   %cx,    %bx 
    movw   $1,     %si 
    movb   $-2,    %al
    imulb  %cl 
    movw   %ax,    %di 
    movw   $0,     %cx 
    xorw   %dx,    %dx
    movb   8(%bp), %dl       
    
    push   4(%bp)       
    movw   6(%bp), %ax       
    addw   8(%bp), %ax
    push   %ax
    push   10(%bp)
    call   draw_pixel

    push   4(%bp)       
    movw   6(%bp), %ax       
    subw   8(%bp), %ax
    push   %ax
    push   10(%bp)
    call   draw_pixel

    movw   4(%bp), %ax       
    addw   8(%bp), %ax
    push   %ax
    movw   4(%bp), %ax       
    subw   8(%bp), %ax
    push   %ax
    push   6(%bp)       
    push   10(%bp)
    call   draw_line
    
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
    call   draw_line

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
    call   draw_line

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
    call   draw_line

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
    call   draw_line
    
    cmpw   %dx,    %cx
    jl     1b

    pop    %si
    pop    %di
    pop    %dx
    pop    %cx
    pop    %bx
    pop    %ax
END_PROC


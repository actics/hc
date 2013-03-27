.code16

.section .text
    movb  %es:(0x80), %al
    movb  $0x00,      %ah
    movw  %ax,        %si
    movb  $0x00, %cs:0x81(%si)

    push  %ds
    push  %cs
    pop   %ds
    movw  $0x82, %dx
    movb  $0x00, %al
    movb  $DOS_OPEN_FILE, %ah
    int   $DOS_SYSCALL
    jb    exit

    pop   %ds

    movw  %ax,     %bx
    movw  $0xf000, %cx
    movw  $file,   %dx
    movb  $DOS_READ_FILE, %ah
    int   $DOS_SYSCALL
    jb    exit
    movw  %ax, %cx
    
    movb  $0x03, %al
    movb  $BIOS_SET_MODE, %ah
    int   $BIOS_VIDEO_CALL

    movb  $0x07, %ah
    movw  $0x00, %bx
str:
    movb  file(%bx), %al
    cmp   $'\d', %al
    je exit
    movw  %ax, video_address(%bx)
    incw  %bx
    decw  %cx
    movb %cl, %al
   #call print_char_hex
    cmpw  $0x00, %cx
    jne   str

    movb  $KEYBOARD_WAIT_CHAR, %ah
    int   $KEYBOARD_CALL

exit:
    movb  $DOS_EXIT, %ah
    movb  $0x00, %al
    int   $DOS_SYSCALL

.include "libdos/dos-headers.S"
.include "libdos/iofunc.S"

.set video_address, 0xb800

.section .data
    file:

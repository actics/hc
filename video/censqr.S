.code16

.section .code
    
    movb  %cs:(0x85), %bh
    movw  %cs:(0x83), %si
    andb  $0x0f,      %bh
    andw  $0x0f,      %si
    movb  row(%si),   %dh
    movb  col(%si),   %dl
    movb  $BIOS_SET_POSITION, %ah
    int   $BIOS_VIDEO_CALL
    
    movb  $0x00,      %al
    movb  $0b01010000, %bh
    movw  $0x00,      %cx
    movb  row(%si),   %dh
    movb  col(%si),   %dl
    addw  %dx,        %dx
    addw  $0x100f,    %dx
    movb  $BIOS_SCROLL_DOWN, %ah
    int   $BIOS_VIDEO_CALL

    movw  $0x01, %cx
    movb  %cs:(0x85), %bh
    andb  $0x0f, %bh
    subb  $0x02, %dl
    movb  $BIOS_SET_POSITION, %ah
    int   $BIOS_VIDEO_CALL

    movb  $0b00010011, %bl
    movw  %si, %ax
    orb   $0x30, %al
    movb  $BIOS_WRITE_CHAR_COLOR, %ah
    int   $BIOS_VIDEO_CALL
    
    incb  %dl
    movb  $BIOS_SET_POSITION, %ah
    int   $BIOS_VIDEO_CALL

    movb  $0x00, %al
    movb  $BIOS_WRITE_CHAR_COLOR, %ah
    int   $BIOS_VIDEO_CALL

    incb  %dl
    movb  $BIOS_SET_POSITION, %ah
    int   $BIOS_VIDEO_CALL

    movb  %bh,   %al
    orb   $0x30, %al
    movb  $BIOS_WRITE_CHAR_COLOR, %ah
    int   $BIOS_VIDEO_CALL

    movb  row(%si),   %dh
    movb  col(%si),   %dl
    movb  $BIOS_SET_POSITION, %ah
    int   $BIOS_VIDEO_CALL

    andb  $0x0f, %bh
    movb  $0x00, %al
_loop:
    movb  $0b01001010, %bl
    movb  $BIOS_WRITE_CHAR_COLOR, %ah
    int   $BIOS_VIDEO_CALL

    incb  %al
    incb  %dl
    movb  $BIOS_SET_POSITION, %ah
    int   $BIOS_VIDEO_CALL

    testb $0x0f, %al
    jne   _loop
    movb  col(%si), %dl
    inc   %dh
    movb  $BIOS_SET_POSITION, %ah
    int   $BIOS_VIDEO_CALL

    testb %al, %al
    jne   _loop
    movb  $KEYBOARD_WAIT_CHAR, %ah
    int   $KEYBOARD_CALL

    ret

.section .data
    row:
        .byte 4,4,4,4,0,0,0,4
    col:
        .byte 12, 12, 32, 32, 0, 0, 0, 32

.include "../libdos/dos-headers.S"

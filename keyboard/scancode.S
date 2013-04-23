.code16

.include "../libdos/dos-headers.S"

.section .text

1:  movb  $KEYBOARD_WAIT_EXTEND_CHAR, %ah
    int   $KEYBOARD_CALL

    movb  %ah, (scancode)
    movb  %al, (asciicode)

    cmpb  $0x01, (scancode)
    jne   2f
    
    movb  $SUCCESS, %al
    movb  $DOS_EXIT, %ah
    int   $DOS_SYSCALL

2:  movb  $KEYBOARD_EXTEND_FLAG_STATE, %ah
    int   $KEYBOARD_CALL

    movw  %ax, (flag_reg)

    movw  $scancode_message, %dx
    movb  $DOS_PRINT_STRING, %ah
    int   $DOS_SYSCALL

    movb  (scancode), %al
    call  print_char_hex

    movw  $asciicode_message, %dx
    movb  $DOS_PRINT_STRING, %ah
    int   $DOS_SYSCALL

    movb  (asciicode), %al
    call  print_char_hex

    movw  $symbol_message, %dx
    movb  $DOS_PRINT_STRING, %ah
    int   $DOS_SYSCALL

    movb  (asciicode), %al
    movb  $0x00, %bh
    movw  $0x01, %cx
    movb  $BIOS_WRITE_CHAR, %ah
    int   $BIOS_VIDEO_CALL
    
    movw  $special_message, %dx
    movb  $DOS_PRINT_STRING, %ah
    int   $DOS_SYSCALL

    push  $data_array
    push  (flag_reg)
    call  print_flags

    movw  $separator_string, %dx
    movb  $DOS_PRINT_STRING, %ah
    int   $DOS_SYSCALL

    jmp   1b


# void print_flags(short flag_reg, char** flags_messags);
print_flags:
    push  %bp
    movw  %sp, %bp

    movw  4(%bp), %ax
    movw  6(%bp), %di
    
    push  %ax
    push  %bx
    push  %cx
    push  %dx
    push  %di

    movw  $0x01, %bx
    movw  $0x00, %cx

1:  testw %bx, %ax
    jz    2f

    movw  (%di), %dx
    push  %ax
    movb  $DOS_PRINT_STRING, %ah
    int   $DOS_SYSCALL
    pop   %ax

2:  shlw  $0x01, %bx
    addw  $0x02, %di
    incw  %cx
    cmpw  $0x10, %cx
    jne   1b

2:  pop   %di
    pop   %dx
    pop   %cx
    pop   %bx
    pop   %ax

    movw  %bp, %sp
    pop   %bp
    ret
    

.section .data
    separator_string:
        .ascii "\n--------------------\n$"
    detected_message:
        .ascii "Detected keypress\n$"
    scancode_message:
        .ascii "Scancode:   $"
    asciicode_message:
        .ascii "\nASCII code: $"
    symbol_message:
        .ascii "\nSymbol:     $"
    special_message:
        .ascii "\nFlags: $"
    rigth_shift_message:
        .ascii "RigthShift $"
    left_shift_message:
        .ascii "LeftShift $"
    ctrl_message:
        .ascii "Ctrl $"
    alt_message:
        .ascii "Alt $"
    scroll_lock_message:
        .ascii "ScrollLock $"
    num_lock_message:
        .ascii "NumLock $"
    caps_lock_message:
        .ascii "CapsLock $"
    insert_message:
        .ascii "Insert $"
    left_ctrl_message:
        .ascii "LeftCtrl $"
    left_alt_message:
        .ascii "LeftAlt $"
    rigth_ctrl_message:
        .ascii "RigthCtrl $"
    rigth_alt_message:
        .ascii "RigthAlt $"
    scroll_lock_press_message:
        .ascii "ScrollLockPress $"
    num_lock_press_message:
        .ascii "NumLockPress $"
    caps_lock_press_message:
        .ascii "CapsLockPress $"
    sys_req_message:
        .ascii "SysReq $"

    data_array:
        .word rigth_shift_message
        .word left_shift_message
        .word ctrl_message
        .word alt_message
        .word scroll_lock_message
        .word num_lock_message
        .word caps_lock_message
        .word insert_message
        .word left_ctrl_message
        .word left_alt_message
        .word rigth_ctrl_message
        .word rigth_alt_message
        .word scroll_lock_press_message
        .word num_lock_press_message
        .word caps_lock_press_message
        .word sys_req_message


.section .bss
    .lcomm scancode,  1
    .lcomm asciicode, 1
    .lcomm flag_reg,  1

.include "../libdos/iofunc.S"


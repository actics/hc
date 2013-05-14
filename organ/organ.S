.code16

.include "../libdos/dos-headers.S"

.section .text

main: 
    movw     $start_message,         %dx
    movb     $DOS_PRINT_STRING,    %ah
    int      $DOS_SYSCALL

    movb     $KEYBOARD_IRQ,        %al
    movb     $DOS_GET_IRQ_HANDLER, %ah
    int      $DOS_SYSCALL
    movw     %es, %ds:(sys_keyboard_handler+2)
    movw     %bx, %ds:(sys_keyboard_handler)

    movw     $keyboard_hendler,    %dx
    movb     $KEYBOARD_IRQ,        %al
    movb     $DOS_SET_IRQ_HANDLER, %ah
    int      $DOS_SYSCALL

    call     main_loop

    movw     %ds:(sys_keyboard_handler),%dx
    pushw    %ds:(sys_keyboard_handler+2)
    movb     $KEYBOARD_IRQ,        %al
    movb     $DOS_SET_IRQ_HANDLER, %ah
    int      $DOS_SYSCALL

    movw     $end_message,            %dx
    movb     $DOS_PRINT_STRING,    %ah
    int      $DOS_SYSCALL

    jmp       exit


###################################################

main_loop: 
    call   buf_pop

    pushw  %ax

    cmpb   $0x80, %al
    jb     keypress
    jae    keyrelease

keypress: 
    cmpb   $0x58,%al 
    je     main_loop_music

    cmpb   $0x10,%al
    jb     endmain_loop
    cmpb   $0x1B,%al
    jbe    oct1_press

    cmpb   $0x1C,%al 
    je     oct2_press
    cmpb   $0x1E,%al
    jb     endmain_loop
    cmpb   $0x28,%al
    jbe    oct2_press

    cmpb   $0x2A,%al
    je     oct3_press
    cmpb   $0x2C,%al
    jb     endmain_loop
    cmpb   $0x36,%al
    jbe    oct3_press
    ja     endmain_loop

    oct1_press: 
        movb   $1,%ah
        call   key_push
        call   make_noise
        jmp    endmain_loop

    oct2_press: 
        movb   $2,%ah
        call   key_push
        cmpb   $0x1C,%al
        je     _oct2_enter
        addb   $2,%al 
        jmp    _oct2_ok
        _oct2_enter: 
            movb   $0x2B,%al 
        _oct2_ok: 
        call   make_noise
        jmp    endmain_loop

    oct3_press: 
        movb   $3,%ah
        call   key_push
        je     _oct3_lshift
        addb   $5,%al 
        jmp    _oct3_ok
        _oct3_lshift: 
            movb   $0x30,%al
        _oct3_ok: 
        call   make_noise
        jmp    endmain_loop

    main_loop_music: 
        call   speaker_off
        call   play_music
        jmp    endmain_loop

keyrelease: 
    andb   $0x7F,%al 

    cmpb   $0x10,%al
    jb     endmain_loop
    cmpb   $0x1B,%al
    jbe    oct1_release

    cmpb   $0x1C,%al 
    je     oct2_release
    cmpb   $0x1E,%al
    jb     endmain_loop
    cmpb   $0x28,%al
    jbe    oct2_release

    cmpb   $0x2A,%al
    je     oct3_release
    cmpb   $0x2C,%al
    jb     endmain_loop
    cmpb   $0x36,%al
    jbe    oct3_release
    ja     endmain_loop

    oct1_release: 
        movb   $1,%ah
        call   key_pop
        call   make_noise
        jmp    endmain_loop

    oct2_release: 
        movb   $2,%ah
        call   key_pop
        cmpb   $0x1C,%al
        je     _oct2_enter_
        addb   $2,%al 
        jmp    _oct2_ok_
        _oct2_enter_: 
            movb   $0x2B,%al 
        _oct2_ok_: 
        call   make_noise
        jmp    endmain_loop

    oct3_release: 
        movb   $3,%ah
        call   key_pop
        cmpb   $0x2A,%al
        je     _oct3_lshift_
        addb   $5,%al 
        jmp    _oct3_ok_
        _oct3_lshift_: 
            movb   $0x30,%al
        _oct3_ok_: 
        call   make_noise
        jmp    endmain_loop

endmain_loop: 
    popw     %ax
    cmpb     (esc_code), %al
    jne       main_loop

    call     speaker_off
    ret

key_push: 
    pushw  %bx
    movw   $keys, %bx
    decw   %bx
    _try_push: 
        incw   %bx
        cmpw   $keys_end, %bx
        je     exit   
        cmpb   %al, (%bx)
        je     _key_push_end
        cmpb   $0x0,(%bx)
        jne    _try_push
    movb   %al,(%bx)
    call   dump_keybuf
    _key_push_end: 
    popw   %bx
    ret

key_pop: 
    pushw  %bx
    movw   $keys, %bx
    decw   %bx
    _try_pop: 
        incw   %bx
        cmpw   $keys_end, %bx 
        je     _key_pop_end
        cmpb   %al,(%bx)
        jne    _try_pop
    call   _shift_left
    call   dump_keybuf
    _key_pop_end: 
    movw   $keys, %bx
    decw   %bx
    _try_find: 
        incw   %bx
        cmpb   $0x0,(%bx)
        jne    _try_find
    decw   %bx
    cmpw   $keys-1, %bx
    je     _not_found
    movb   (%bx),%al
    jmp    _key_pop_finally_end

    _not_found: 
        movb   $0,%ah 
    _key_pop_finally_end: 
    popw   %bx
    ret


_shift_left: 
    pushw  %ax
    pushw  %bx
    decw   %bx
    _shift_loop: 
        incw   %bx
        movw   1(%bx),%ax 
        movw   %ax,(%bx) 
        cmpb   $0,(%bx)
        jne    _shift_loop
    popw   %bx
    popw   %ax
    ret


make_noise: 
    pushw  %ax
    pushw  %bx
    pushw  %cx
    pushw  %dx
    pushw  %ax
    movb   $0x09,%ah
    movw   $tone_message, %dx
    int    $0x21
    popw   %ax
    call   print_char_hex
    call   print_endl
    cmpb   $0,%ah
    je     _stop
    cmpb   $1,%ah
    je     _oct1
    cmpb   $2,%ah
    je     _oct2
    cmpb   $3,%ah
    je     _oct3

    _stop: 
        call   speaker_off
        jmp    make_noise_end

    _oct1: 
        subb   $0x10,%al
        movw   $oct1, %bx
        jmp    make_noise_ok
    _oct2: 
        subb   $0x20,%al
        movw   $oct2, %bx
        jmp    make_noise_ok
    _oct3: 
        subb   $0x30,%al
        movw   $oct3, %bx
        jmp    make_noise_ok

    make_noise_ok: 
    shlb   %al 
    movb   $0,%ah
    addw   %ax,%bx 
    movw   (%bx),%ax 
    call   speaker_on

    make_noise_end: 
    popw   %dx
    popw   %cx
    popw   %bx
    popw   %ax
    ret

speaker_on: 
    pushw  %ax
    pushw  %ax
    movb   $0b10110110, %al 
    outb   %al, $0x43
    popw   %ax
    outb   %al, $0x42 
    movb   %ah,%al
    outb   %al, $0x42 
    inb    $0x61,%al
    orb    $0b000011, %al 
    outb   %al, $0x61
    popw   %ax
    ret

speaker_off: 
    pushw  %ax
    inb    $0x61,%al
    andb   $0b11111100, %al 
    outb   %al, $0x61
    popw   %ax
    ret

play_music: 
    pushw  %ax
    pushw  %bx
    pushw  %cx
    pushw  %dx
    pushw  %si
    pushw  %di
    movw   $0x3508,%ax
    int    $0x21 
    movw   %es, %ds:(sys_timer_handler+2)
    movw   %bx, %ds:(sys_timer_handler)

    movb   $0x25,%ah
    movb   $0x08,%al
    movw   $timer_handler, %dx
    int    $0x21

    movw   (m_count),%cx
    movw   $m_notes, %di
    movw   $m_delays, %si
    _player: 
        movb   (%di),%al
        call   simplify
        call   make_noise
        call   print_word_hex
        movw   (%si),%ax
        call   print_endl
        pushw  %di
        pushw  %si
        movw   %ax,(delay)
        _alala: 
            cmpw   $0,(delay)
            ja     _alala
        popw   %si
        popw   %di
        incw   %di
        addw   $2,%si
        loop _player


    call   speaker_off


    movw   $0x2508,%ax
    movw   %ds:(sys_timer_handler),%dx
    pushw  %ds
    pushw  %ds:(sys_timer_handler+2)
    popw   %ds
    int    $0x21 
    popw   %ds

    popw   %di
    popw   %si
    popw   %dx
    popw   %cx
    popw   %bx
    popw   %ax
    ret

simplify: 
    cmpb   $0,%al
    je     s_silent
    cmpb   $13,%al
    jbe    s_1
    cmpb   $113,%al
    jbe    s_2
    cmpb   $213,%al
    jbe    s_3
    jmp    s_silent

    s_silent: 
        movw   $0x0000,%ax
        jmp    s_end
    s_1: 
        movb   $0x01,%ah
        addb   $15,%al
        jmp    s_end
    s_2: 
        movb   $0x02,%ah
        subb   $69,%al
        jmp    s_end
    s_3: 
        movb   $0x03,%ah
        subb   $153,%al
        jmp    s_end
    s_end: 
    ret

keyboard_hendler: 
    inb    $0x60,%al 

    call   buf_push
    movw   %di,tail

    inb    $0x61,%al 
    movb   %al,%ah
    orb    $0b10000000,%al 
    outb   %al, $0x61 
    movb   %ah,%al
    outb   %al, $0x61 

    movb   $0x20,%al 
    outb   %al, $0x20 
    iret

timer_handler: 
    pushf
    cmpw   $0,%cs:(delay)
    je     _lol
    decw   %cs:(delay)
    _lol: 
    popf
    ljmp   *%cs:(sys_timer_handler)

    iret


dump_keybuf: 
    ret
    pushw  %ax
    pushw  %bx
    pushw  %dx
    movw   $keys, %bx
    decw   %bx
    movb   $0x02,%ah
    movb   $0x3C,%dl
    int    $0x21
    movb   $0x02,%ah
    movb   $0x20,%dl
    int    $0x21
    _dump_repeat: 
        incw   %bx
        movb   (%bx),%al
        call   print_char_hex
        movb   $0x02,%ah
        movb   $0x20,%dl
        int    $0x21
        cmpw   $keys_end-1, %bx
        jb     _dump_repeat

    movb   $0x02,%ah
    movb   $0x3E,%dl
    int    $0x21
    popw   %dx
    popw   %bx
    popw   %ax
    ret

buf_push: 
    movw   (head),%si
    movw   (tail),%di

    movb   %al, (%di)
    incw   %di
    cmpw   (buf_end),%di
    je     _just_round
    jmp    _just_end
    _just_round: 
        subw   (buf_size),%di
        jmp    _just_end
    _beep: 
        movb   $0x02,%ah
        movb   $0x14,%dl
        int    $0x21
        call   print_endl
        jmp    _just_end
    _just_end: 

    movw   %di,(tail)
    ret

buf_pop: 
    #pops into AL
    movw   (head),%si
    movw   (tail),%di
    _wait_for_data: 
        cmpw   %di,%si
        je     _wait_for_data
    movb   (%si),%al
    incw   %si
    cmpw   (buf_end),%si
    je     read_round
    jmp    _read_end

    read_round: 
        subw   (buf_size),%si

    _read_end: 
        movw   %si,(head)
    ret


print_endl: 
    pushw  %ax
    pushw  %dx
    movb   $0x09,%ah
    movw   $endl, %dx
    int    $0x21
    popw   %dx
    popw   %ax
    ret


exit: 
    movw   $0x4c00,%ax
    int    $0x21
    ret


.section .data
symbols:       .ascii "0123456789ABCDEF$"
endl:          .ascii "\r\n$"
start_message: .ascii "Hardware organ v0.0001.\r\n$"
tone_message:  .ascii "Tone:  $"
end_message:   .ascii "bye-bye, Tony\$"
esc_code:      .byte  0x01
buffer:        .byte  0,0,0,0,0,0,0,0,0,0
head:          .word  buffer
tail:          .word  buffer
buf_end:       .word  head
buf_size:      .word  head - buffer
keys:          .byte  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
keys_tz:       .byte  0
keys_end:      .word  .-1

oct1: .word     9121,   8609,   8126,   7670,   7239,   6833,   6449,   6087,   5746,   5423,   5119,   4831
oct2: .word     4560,   4304,   4063,   3834,   3619,   3416,   3224,   3043,   2873,   2711,   2559,   2415
oct3: .word     2280,   2152,   2031,   1917,   1809,   1715,   1612,   1521,   1436,   1355,   1292,   1207

delay:    .word 0x0018

m_notes:  .byte  103,0, 103,0, 103,0, 103,0, 105,0, 105,0
m_delays: .word   3, 4,  2,1,    2,1,   2,1,   4,5,   4,5

m_count:  .word m_delays - m_notes


.section .bss
    .lcomm sys_keyboard_handler, 1
    .lcomm sys_timer_handler, 1


.include "../libdos/iofunc.S"


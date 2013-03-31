.code16

# уникальный номер программы
.ifndef ANOTHER_RESIDENT
    .set PROCESS_NUMBER, 0xf8
.else
    .set PROCESS_NUMBER, 0xf9
.endif

.section .text
    jmp   start_manager

old_handler:
    .long 0x00

# начало резидента
start_resident:

    # проверка на необходимость обработки прерывания
    cmpb  $PROCESS_NUMBER, %ah
    jne   next_handler

    # magic
    movw  $0xdead, %ax
.ifndef ANOTHER_RESIDENT
    movw  $0xbeef, %bx
.else
    movw  $0xbef0, %bx
.endif
    
    iret

next_handler:
    # передача работы на старый обработчик
    ljmp   *%cs:(old_handler)

.set RESIDENT_SIZE, 0x14

# начало менеджера резидента
start_manager:

    # устанавливаем значения необходимые для работы автомата
    movb  $0x00, %dl        # dl - состояние автомата
    movw  $0x81, %si        # si - указатель на текущеее положение в строке аргеументов
    movw  $letter_map, %bx  # bx - указатель на таблицу отображения символов
    movw  %es:(0x80),  %cx  # cl - длина строки аргументов

    # проверка на существование строки аргументов
    xorb  %ch,  %ch
    testb %cl,  %cl
    je    end_automato_loop

# основной цикл. Здесь работает алгоритм автомата
automato_loop:

    # берем символ из строки аргументов и сохраняем его номер из таблицы паереходов
    movb  %es:(%si), %al
    xlat
    push  %ax

    # рассчитываем строку в таблице переходов
    mov   $ALPHABET_CARDINALITY, %al
    mulb  %dl
    movw  %ax,   %di

    # получаем новое состояние
    pop   %ax
    addw  %ax,   %di
    movb  automato(%di), %dl

    # переходим на следующий символ в строке и залупливаемся
    incw  %si
    loop  automato_loop
end_automato_loop:

    # условный переход от конечного состояния
    cmp   $0x00,  %dl
    je    help_argumet_label

    cmp   $0x01,  %dl
    je    invalid_argumet_label

    cmp   $0x02,  %dl
    je    help_argumet_label

    cmp   $0x03,  %dl
    je    install_argumet_label

    cmp   $0x04,  %dl
    je    check_argumet_label

    cmp   $0x05,  %dl
    je    remove_argumet_label

    cmp   $0x06,  %dl
    je    invalid_argumet_label


# вывод ошибки: "передано более одного аргумента"
    movw  $more_one_argument_message, %dx
    movb  $DOS_PRINT_STRING,          %ah
    int   $DOS_SYSCALL

    jmp   exit


# вывод ошибки: "неизвестный аргумент"
invalid_argumet_label:
    movw  $invalid_argument_message, %dx
    movb  $DOS_PRINT_STRING,         %ah
    int   $DOS_SYSCALL

    jmp   exit


# вывод справки
help_argumet_label:
    movw  $help_message,     %dx
    movb  $DOS_PRINT_STRING, %ah
    int   $DOS_SYSCALL

    jmp   exit


# установка резидента
install_argumet_label:

    # проверяем, есть ли уже резидент в системе
    call  check_resident
    cmpb  $TRUE, %al
    je    1f
    
    # вывод сообщения о успешной установке резидента
    movb  $DOS_PRINT_STRING,     %ah
    movw  $install_true_message, %dx
    int   $DOS_SYSCALL

    call  install_resident
1:
    # вывод сообщения о сбое установки резидента
    movb  $DOS_PRINT_STRING,      %ah
    movw  $install_false_message, %dx
    int   $DOS_SYSCALL

    jmp   exit


# проверка наличия резидента в системе
check_argumet_label:
    # выводим вспомогательное сообщение
    movb  $DOS_PRINT_STRING,     %ah
    movw  $check_prefix_message, %dx
    int   $DOS_SYSCALL

    call  check_resident
    cmpb  $TRUE, %al
    jne   1f

    # выводим сообщение о успесном обнаружении резидента
    movb  $DOS_PRINT_STRING,   %ah
    movw  $check_true_message, %dx
    int   $DOS_SYSCALL

    jmp   2f
1:
    # выводим сообщение о том, что резидента нет на месте
    movb  $DOS_PRINT_STRING,    %ah
    movw  $check_false_message, %dx
    int   $DOS_SYSCALL
2:
    jmp   exit


# удаление резидента
remove_argumet_label:

    call  check_resident
    cmpb  $TRUE, %al
    jne   1f

    # выводим сообщение о успешном удалении резидента
    movb  $DOS_PRINT_STRING,   %ah
    movw  $remove_true_message, %dx
    int   $DOS_SYSCALL

    call  remove_resident

    jmp   2f
1:
    # выводим сообщение о том, что резидента нет на месте
    movb  $DOS_PRINT_STRING,    %ah
    movw  $remove_false_message, %dx
    int   $DOS_SYSCALL
2:
    jmp   exit


# основная метка выхода
exit:
    movb  $DOS_EXIT,   %ah
    movb  $SUCCESS,    %al
    int   $DOS_SYSCALL


.section .data
    # мощность алфавита автомата
    .set ALPHABET_CARDINALITY, 0x07

    # таблица переходов автомата
    automato:
            # 0  1  2  3  4  5  6
            # -  h  i  c  r  _  *
        .byte 1, 6, 6, 6, 6, 0, 6 # 0
        .byte 6, 2, 3, 4, 5, 6, 6 # 1
        .byte 6, 6, 6, 6, 6, 7, 6 # 2 - h
        .byte 6, 6, 6, 6, 6, 7, 6 # 3 - i
        .byte 6, 6, 6, 6, 6, 7, 6 # 4 - c
        .byte 6, 6, 6, 6, 6, 7, 6 # 5 - r
        .byte 6, 6, 6, 6, 6, 6, 6 # 6 - invalid argument
        .byte 7, 7, 7, 7, 7, 7, 7 # 7 - more than one arguments

    help_message:
        .ascii "Usage: tsrmgr [options]\r\n" 
        .ascii "Options:\r\n"
        .ascii "  -h   print this help and exit\r\n"
        .ascii "  -i   install a tsr\r\n"
        .ascii "  -c   check presence this tsr in system\r\n"
        .ascii "  -r   remove tsr from system$" 

    install_true_message:
        .ascii "resident successfully installed$"

    install_false_message:
        .ascii "resident installing fail$"

    check_prefix_message:
        .ascii "resident status: $"

    check_true_message:
        .ascii "installed$"

    check_false_message:
        .ascii "no found$"

    remove_true_message:
        .ascii "resident successfully removed$"

    remove_false_message:
        .ascii "resident removing fail$"

    invalid_argument_message:
        .ascii "error: invalid argument$"

    more_one_argument_message:
        .ascii "error: send one argument$"

    # таблица отображающая ascii символы в номера 
    # для взятия значения в таблице переходов автомата
    letter_map:
        .skip 32,  6
        .byte 5      # _
        .skip 12,  6
        .byte 0      # -
        .skip 53,  6
        .byte 3      # c
        .skip 4,   6
        .byte 1      # h
        .byte 2      # i
        .skip 8,   6
        .byte 4      # r
        .skip 141, 6

.include "../libdos/dos-headers.S"
.include "../libdos/iofunc.S"
.include "./mgrfunc.S"


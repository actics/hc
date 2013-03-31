.section .text

# установить резидента на прерывание
# INPUT:  NONE
# OUTPUT: NONE
install_resident:
    # Удаляем переменные среды
    movw  %cs:(0x2c), %es
    movb  $DOS_FREE_MEMORY, %ah
    int   $DOS_SYSCALL

    # узнаем адрес старого обработчика
    movb  $DOS_GET_IRQ_HANDLER, %ah
    movb  $DOS_MULTIPLEX_IRQ,   %al
    int   $DOS_SYSCALL

    # сохраняем адрес
    movw  %bx,   (old_handler)
    movw  %es,   (old_handler+2)

    # записываем адрес резидента в таблицу прерываний
    movb  $DOS_SET_IRQ_HANDLER, %ah
    movb  $DOS_MULTIPLEX_IRQ,   %al
    movw  $start_resident,      %dx
    int   $DOS_SYSCALL

    # завершает программу и остается резидентом
    movb  $DOS_MAKE_RESIDENT, %ah
    movb  $SUCCESS, %al
    movw  $RESIDENT_SIZE, %dx # количество параграфов под резидент
    int   $DOS_SYSCALL

#-----------------------------------------------------

# Проверяет установлен ли резидент в системе
# INPUT:  NONE
# OUTPUT: %al TRUE  - resident stay
#         %al FALSE - resident unfound
check_resident:

    # сохраняем состояние системы
    push  %bx
    push  %dx

    # вызываем мультиплексное прерывание с кодом нашей программы
    movb  $PROCESS_NUMBER,   %ah
    int   $DOS_MULTIPLEX_IRQ

    # устанавливаем возвращаемое значение в FALSE
    movb  $FALSE, %dl

    # magic!
    cmp   $0xdead, %ax
    jne   1f
.ifndef ANOTHER_RESIDENT
    cmp   $0xbeef, %bx
.else
    cmp   $0xbef0, %bx
.endif
    jne   1f

    # устанавливаем возвращаемое значение в TRUE
    movb  $TRUE, %dl

1:
    # устанавливаем возвращаемое значение в %al
    movb  %dl, %al

    # восстанавливаем состояние системы
    pop   %dx
    pop   %bx

    ret

#-----------------------------------------------------

# удалить резидента из памяти и снять с прерывания
# восстановить старый обработчик
# INPUT:  NONE
# OUTPUT: NONE
remove_resident:
    # получаем адрес обработчика
    movb  $DOS_GET_IRQ_HANDLER, %ah
    movb  $DOS_MULTIPLEX_IRQ,   %al
    int   $DOS_SYSCALL

    # кладем в ds:dx адрес старого обработчика
    movw  %bx,   %si
    subw  $0x02, %si
    movw  %es:(%si), %ds
    subw  $0x02, %si
    movw  %es:(%si), %dx

    # освобождаем память
    movb  $DOS_FREE_MEMORY, %ah
    int   $DOS_SYSCALL

    # восстанавливаем старый обработчик
    movb  $DOS_SET_IRQ_HANDLER, %ah
    int   $DOS_SYSCALL

    ret


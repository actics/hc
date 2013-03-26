.section .text

# -----------------------------------------------------

# функция печатающая hex представление регистра %al
# void __fastcall print_char_hex(char target_char)#
print_char_hex:

    # сохранение состояния системы
    push  %ax
    push  %bx
    push  %cx
    push  %dx
    
    # сохраняем адрес таблицы hex символов для использования с xlat
    movw  $hex_symbol, %bx

    # сохраняем обрабатываемое значение
    movb  %al,   %cl

    # совершаем сдвиг, взятие из hex-таблицы и вывод
    shrb  $0x04, %al
    xlat
    movb  %al,   %dl
    movb  $DOS_PRINT_CHAR, %ah
    int   $DOS_SYSCALL

    # совершаем сопоставление с битовой маской, взятие из hex-таблицы и вывод
    movb  %cl,   %al
    andb  $0x0f, %al
    xlat
    movb  %al,   %dl
    movb  $DOS_PRINT_CHAR, %ah
    int   $DOS_SYSCALL

    # восстанавливаем состояние системы
    pop   %dx
    pop   %cx
    pop   %bx
    pop   %ax

    ret


# -----------------------------------------------------


.section .data

    # таблица hex-символов
    hex_symbol:
        .ascii "0123456789abcdef"


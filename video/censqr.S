.code16

.set VIDEO_MODE, 3
.set VIDEO_PAGE, 1
.set START_ROW,  4
.set START_COLUMN_WIDE_MODE,   23
.set START_COLUMN_NARROW_MODE, 12
.set SPACE, 0x20

.include "../libdos/dos-headers.S"

.section .text
    call  get_and_check
    cmp   $SUCCESS, %ah
    jne   exit

    movb  %dh, (video_mode)
    movb  %dl, (video_page)

    # Узнаем текущий режим
    movb  $BIOS_GET_MODE,   %ah
    int   $BIOS_VIDEO_CALL

    # Сохраняем текущий режим
    movb  %al, (video_mode_old)
    movb  %bh, (video_page_old)

    # Устанвливаем новый режим
    movb  (video_mode),     %al
    movb  $BIOS_SET_MODE,   %ah
    int   $BIOS_VIDEO_CALL

    # Устанавливаем новую страницу
    movb  (video_page),     %al
    movb  $BIOS_SET_PAGE,   %ah
    int   $BIOS_VIDEO_CALL

    # Узнаем стартовую колонку 
    movb  $START_COLUMN_WIDE_MODE,   (start_column)  
    cmpb  $1, (video_mode)
    ja    1f
    movb  $START_COLUMN_NARROW_MODE, (start_column)
1:  

    # Устанавливаем переменные необходимые для работы 
    movb  $0,  %al                  # Номер стартового символа
    movw  $0,  %di                  # Счетчик установщиков цвета
    movw  $16, %cx                  # Счетчик цикла
    movb  $START_ROW,  %dh          # Номер начальной строки
    movb  (start_column), %dl       # Номер начальной колонки
    
    # Основной цикл. На каждой итерации мы выбираем новый установщик
    # цвета, и выводим линию символов
1:  movw  color_setters(%di), %si
    call  write_char_line

    incb  %dh
    movb  (start_column), %dl
    addw  $2, %di

    loop  1b
    
    # Выводим сообщение о текущей странице
    movw  $page_string,        %bp
    movw  $page_string_length, %cx
    call  write_string
    
    movw  $1,                     %cx
    movb  $'0',                   %al
    addb  (video_page),           %al
    movb  $BIOS_WRITE_CHAR_COLOR, %ah
    int   $BIOS_VIDEO_CALL
   
    # Выводим сообщение о текущем режиме
    movw  $mode_string,        %bp
    movw  $mode_string_length, %cx
    movb  $START_ROW-1,        %dh
    movb  (start_column),      %dl
    call  write_string
    
    movw  $1, %cx
    movb  $'0',                   %al
    addb  (video_mode),           %al
    movb  $BIOS_WRITE_CHAR_COLOR, %ah
    int   $BIOS_VIDEO_CALL

    # Ждем нажатия на клавишу
    movb  $KEYBOARD_WAIT_CHAR, %ah
    int   $KEYBOARD_CALL

    # Восстанавливаем предыдущий режим
    movb  (video_mode_old),    %al
    movb  $BIOS_SET_MODE,      %ah
    int   $BIOS_VIDEO_CALL

    # Восстанавливаем предыдущую страницу
    movb  (video_page_old),    %al
    movb  $BIOS_SET_PAGE,      %ah
    int   $BIOS_VIDEO_CALL
    
exit:
    # Выходим из программы
    movb  $SUCCESS,            %al
    movb  $DOS_EXIT,           %ah
    int   $DOS_SYSCALL


# INPUT:  %bp - string
#         %cx - string length
#         %dx - row | column
# OUTPUT: NONE
write_string:
    movb  $1,                  %al
    movb  (video_page),        %bh
    movb  $0b00000010,         %bl
    movb  $BIOS_WRITE_STRING,  %ah
    int   $BIOS_VIDEO_CALL

    ret


# Функция рисует строку. В каждой новой итерации происходит
# генерация нового цвета с помощью переданной функции,
# вывод последующего символа и пробела. В режимах 1-2
# пробел не выводится для получения эффекта квадрата

# input: %dx - cursor row | column
#        %al - start symbol
#        %si - color function
write_char_line:
    push  %bx
    push  %cx

    # Устанавливаем параметры для функции вывода
    movw  $1,           %cx
    movb  (video_page), %bh

1:  movb  $BIOS_SET_POSITION,     %ah
    int   $BIOS_VIDEO_CALL

    call  *%si

    movb  $BIOS_WRITE_CHAR_COLOR, %ah
    int   $BIOS_VIDEO_CALL

    incb  %al
    incb  %dl

    movb  $BIOS_SET_POSITION,     %ah
    int   $BIOS_VIDEO_CALL    

    testb $15, %al
    jz    1f

    cmpb  $1, (video_mode)
    jbe   1b

    push  %ax
    movb  $SPACE, %al
    movb  $BIOS_WRITE_CHAR_COLOR, %ah
    int   $BIOS_VIDEO_CALL
    pop   %ax
    incb  %dl

    jmp   1b

1:  pop   %cx
    pop   %bx

    ret


# color setters: change %bl


color_set_different:
    movb  %al, %bl
    xorb  $15, %bl
    ret


color_set_blink_green:
    movb  $0b10000010, %bl
    ret


color_set_background:
    movb  %dh, %bl
    rolb  $4, %bl
    andb  $0b01110000, %bl
    cmpb  $0, %bl
    jne   1f
    movb  $0b00000111, %bl
1:  ret


color_set_blink_red:
    movb  $0b10000100, %bl
    ret


color_set_blue:
    movb  $0b00000001, %bl
    ret


.section .bss
    .lcomm video_mode,     1
    .lcomm video_page,     1
    .lcomm video_mode_old, 1
    .lcomm video_page_old, 1
    .lcomm start_column,   1


.section .data

# Массив цветофункций
color_setters:
    .word  color_set_different
    .word  color_set_blink_green
    .rept  12
        .word color_set_background
    .endr
    .word  color_set_blink_red
    .word  color_set_blue

mode_string:
    .ascii "current mode: "
.set mode_string_length, (. - mode_string)

page_string:
    .ascii "active page: "
.set page_string_length, (. - page_string)


.include "./set-mode.S"


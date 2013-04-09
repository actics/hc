.code16

.set START_ROW,  4
.set START_COLUMN_WIDE_MODE,   23
.set START_COLUMN_NARROW_MODE, 12
.set SPACE, 0x20
.set VERTICAL_LINE, 0xba
.set HORISONTAL_LINE, 0xcd
.set LEFT_TOP_CORNER, 0xc9
.set RIGTH_TOP_CORNER, 0xbb
.set LEFT_BOTTOM_CORNER, 0xc8
.set RIGTH_BOTTOM_CORNER, 0xbc
.set TABLE_START,       (4*40+11)*2
.set MODE_STRING_START, (40+12)*2 
.set PAGE_STRING_START, (40*22+12)*2
.set MODE_NUMBER_START, MODE_STRING_START + mode_string_length
.set PAGE_NUMBER_START, PAGE_STRING_START + page_string_length
.set TABLE_START_WIDE, (4*80+22)*2
.set MODE_STRING_START_WIDE, (80+23)*2
.set PAGE_STRING_START_WIDE, (80*22+23)*2

.include "../libdos/dos-headers.S"

.section .text
    call  get_and_check
    cmp   $SUCCESS, %ah
    jne   exit

    movb  %dh, (video_mode)
    movb  %dl, (video_page)

    # Сохраняем текущий режим
    call  get_video_mode
    movb  %al, (video_mode_old)

    # Сохраняем текущую страницу
    call  get_video_page
    movb  %al, (video_page_old)

    # Устанвливаем новый режим
    push  (video_mode)
    call  set_video_mode
    addw  $0x02, %sp

    # Устанавливаем новую страницу
    push  (video_page)
    call  set_video_page
    addw  $0x02, %sp
   
    # Узнаем видеосегмент для текущего режима
    push  (video_mode)
    call  get_video_segment
    addw  $0x02, %sp

    movw  %ax, (video_segment)

    # Узнаем смещение до адреса текущей страницы
    call  get_starting_address
    movw  %ax, (video_offset)

    # Узнаем длинну строки в текущем видеорежиме (в байтах)
    call  get_line_length
    movw  %ax, (line_length)

    # Вычисление режимоспецифичных данных
    cmpb  $0x01, (video_mode)
    ja    1f
    movw  $TABLE_START,       (table_start)
    movw  $FALSE,             (wide_mode)
    movw  $18,                (table_width)
    movw  $MODE_STRING_START, (mode_string_start)
    movw  $PAGE_STRING_START, (page_string_start)
    jmp   2f
1:  movw  $TABLE_START_WIDE,       (table_start)
    movw  $TRUE,                   (wide_mode)
    movw  $33,                     (table_width)
    movw  $MODE_STRING_START_WIDE, (mode_string_start)
    movw  $PAGE_STRING_START_WIDE, (page_string_start)
2:  movw  (video_offset), %ax
    addw  %ax, (table_start)
    addw  %ax, (mode_string_start)
    addw  %ax, (page_string_start)

    # Отрисовка таблицы
    push  (wide_mode)
    push  (line_length)
    push  (table_start)
    push  (video_segment)
    call  write_table
    addw  $0x08, %sp

    # Отрисовка рамки
    push  $0b00000100
    push  $18
    push  (table_width)
    push  (line_length)
    movw  (table_start), %ax
    subw  (line_length), %ax
    subw  $2, %ax
    push  %ax 
    push  (video_segment)
    call  write_box
    addw  $0x0c, %sp

    # Печатаем строку о режиме
    push  $0b00000100
    push  $mode_string
    push  (mode_string_start)
    push  (video_segment)
    call  write_string
    addw  $0x08, %sp

    # Печатаем строку о странице
    push  $0b00000100
    push  $page_string
    push  (page_string_start)
    push  (video_segment)
    call  write_string
    addw  $0x08, %sp

    # Печатаем режим и страницу
    push  %es
    push  (video_segment)
    pop   %es
    movb  $0b00000100, %ah

    movb  (video_mode), %al
    addb  $'0', %al
    movw  $mode_string_length, %di
    shlw  $1, %di
    addw  (mode_string_start), %di
    movw  %ax, %es:(%di)

    movb  (video_page), %al
    addb  $'0', %al
    movw  $page_string_length, %di
    shlw  $1, %di
    addw  (page_string_start), %di
    movw  %ax, %es:(%di)

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


# void print_string(char* str);
print_string:
    push  %bp
    movw  %sp, %bp

    push  %ax
    push  %dx
    push  %di

    movw  4(%bp), %di

1:  cmpb  $0, (%di)
    je    1f
    movb  (%di), %dl 
    movb  $DOS_PRINT_CHAR, %ah
    int   $DOS_SYSCALL
    incw  %di
    jmp   1b

    pop  %di
1:  pop  %dx
    pop  %ax

    movw %bp, %sp
    pop  %bp
    ret


command_line_parse:
    pop   %si

    movb  %es:(0x80), %cl
    xorb  %ch,        %ch
    xorw  %ax,        %ax
    movw  $0x81,      %di

    cmpb  $0, %cl
    je    4f

    movb  $FALSE,     %ah

1:  cmpb  $' ', %es:(%di)
    jne   2f

    cmpb  $TRUE, %ah
    jne   3f
    
    movb  $0,  (%di)
    movb  $FALSE, %ah
    jmp   3f
    
2:  cmpb  $FALSE, %ah
    jne   3f

    movb  $TRUE, %ah
    push  %di
    incb  %al

3:  incw  %di
    loop  1b

    movb  $0, (%di)
    xorb  %ah, %ah
    
    movw  %sp, %di
    push  %ax
    push  %di
    call  reverse
    addw  $4, %sp

4:  push  %si
    ret
    

# char strncmp(char *str1, char* str2)
strncmp:
    push  %bp
    movw  %sp, %bp

    push  %dx
    push  %di
    push  %si

    movw  4(%bp), %di
    movw  6(%bp), %si
    movw  $0x01,  %ax

1:  movb  (%di), %dh
    cmpb  %dh,   (%si)
    jne   2f

    cmpb  $0, %dh
    je    1f

    incw  %di
    incw  %si
    incw  %ax
    jmp   1b

1:  xorw  %ax, %ax

2:  pop   %si
    pop   %di
    pop   %dx

    movw  %bp, %sp
    pop   %bp
    ret
    

# void reverse (short* address, short length)
reverse:
    push  %bp
    movw  %sp, %bp

    push  %si
    push  %di
    push  %bx
    push  %cx
    push  %dx
    
    cmpw  $1, 6(%bp)
    jbe   2f

    movw  4(%bp), %si
    movw  6(%bp), %cx
    movw  %cx,    %dx
    shlw  $1,     %dx
    subw  $2,     %dx
    movw  %si,    %di
    addw  %dx,    %di
    shrw  $1,     %cx

1:  movw  (%si), %bx
    movw  (%di), %dx
    movw  %dx,   (%si)
    movw  %bx,   (%di)
    addw  $2,    %si
    subw  $2,    %di
    loop  1b

2:  pop   %dx
    pop   %cx
    pop   %bx
    pop   %di
    pop   %si

    movw  %bp, %sp
    pop   %bp
    ret


# void write_table (short segment, 
#                   short offset, 
#                   short line_length, 
#                   bool  wide_mode)
write_table:
    push  %bp
    movw  %sp, %bp

    push  6(%bp)

    push  %es
    push  %di
    push  %ax
    push  %bx

    xorw  %di, %di
    xorw  %ax, %ax

1:  
    push  10(%bp)
    push  color_setters(%di)
    push  %ax
    push  -2(%bp)
    push  4(%bp)
    call  write_char_line
    addw  $10, %sp
    
    addw  $0x10,  %ax
    addw  $2,     %di
    movw  8(%bp), %bx
    addw  %bx,    -2(%bp)

    cmpw  $0x20, %di
    jne   1b

    pop   %bx
    pop   %ax
    pop   %di
    pop   %es

    movw %bp, %sp
    pop  %bp
    ret


# void write_char_line(short segment, 
#                      short offset, 
#                      short start_char, 
#                      short setter_address, 
#                      bool wide_mode)
write_char_line:
    push  %bp
    movw  %sp, %bp

    push  %ax
    push  %di
    push  %si
    push  %es

    movw  10(%bp), %si
    movb  8(%bp),  %al
    movw  6(%bp),  %di
    movw  4(%bp),  %es

1:  call  *%si
    
    movw  %ax, %es:(%di)

    incb  %al
    addw  $0x02, %di

    testb $15, %al
    jz    1f

    cmpb  $TRUE, 12(%bp)
    jne   1b

    push  %ax
    movb  $SPACE, %al
    movw  %ax,    %es:(%di)
    pop   %ax
    addw  $0x02, %di

    jmp   1b

1:  pop   %es
    pop   %si
    pop   %di
    pop   %ax

    movw  %bp, %sp
    pop   %bp
    ret


# void write_box (short segment,
#                 short offset,
#                 short line_length,
#                 short width,
#                 short height,
#                 short color)
write_box:
    push  %bp
    movw  %sp, %bp

    push  %es
    push  %di
    push  %si
    push  %ax
    push  %cx
    push  %bx

    movw  4(%bp),  %es
    movw  6(%bp),  %di
    subw  $0x02, 10(%bp)
    subw  $0x02, 12(%bp)
    movw  14(%bp), %ax
    movb  %al,     %ah

    movb  $HORISONTAL_LINE, %al
    addw  $2,  %di
    movw  10(%bp), %cx

1:  movw  %ax, %es:(%di)
    addw  $2, %di
    loop  1b

    movb  $VERTICAL_LINE, %al
    movw  6(%bp),  %di
    addw  8(%bp),  %di
    movw  %di,     %si
    movw  10(%bp), %bx
    shlw  $1,      %bx
    addw  $2,      %bx
    addw  %bx,     %si
    movw  12(%bp), %cx

1:  movw  %ax, %es:(%di)
    movw  %ax, %es:(%si)
    addw  8(%bp), %di
    addw  8(%bp), %si
    loop  1b

    movb  $HORISONTAL_LINE, %al
    addw  $2,  %di
    movw  10(%bp), %cx

1:  movw  %ax, %es:(%di)
    addw  $2, %di
    loop  1b

    movb  $RIGTH_BOTTOM_CORNER, %al
    movw  %ax, %es:(%di)

    subw  10(%bp),  %di
    subw  10(%bp),  %di
    subw  $2, %di
    movb  $LEFT_BOTTOM_CORNER, %al
    movw  %ax, %es:(%di)

    movw  6(%bp),  %di
    movb  $LEFT_TOP_CORNER, %al
    movw  %ax, %es:(%di)

    addw  10(%bp),  %di
    addw  10(%bp),  %di
    addw  $2, %di
    movb  $RIGTH_TOP_CORNER, %al
    movw  %ax, %es:(%di)

    pop   %bx
    pop   %cx
    pop   %ax
    pop   %si
    pop   %di
    pop   %es

    movw  %bp, %sp
    pop   %bp
    ret

# void write_string (short segment
#                    short offset
#                    short string,
#                    short color)
write_string:
    push  %bp
    movw  %sp, %bp

    push  %es
    push  %si
    push  %di
    push  %ax

    movw  4(%bp),  %es
    movw  6(%bp),  %di
    movw  8(%bp),  %si
    movb  10(%bp), %ah

    movb  (%si), %al
1:  cmpb  $0, %al
    je    1f
    movw  %ax, %es:(%di)
    addw  $2, %di
    incw  %si
    movb  (%si), %al
    jmp   1b

1:  pop   %ax
    pop   %di
    pop   %si
    pop   %es

    movw  %bp, %sp
    pop   %bp
    ret


# color setters: change %ah

color_set_different:
    movb  %al, %ah
    xorb  $15, %ah
    ret


color_set_blink_green:
    movb  $0b10000010, %ah
    ret


color_set_background:
    movb  %al,   %ah
    andb  $0x70, %ah
    cmpb  $0,    %ah
    jne   1f
    movb  $0x07, %ah

1:  ret


color_set_blink_red:
    movb  $0b10000100, %ah
    ret


color_set_blue:
    movb  $0b00000001, %ah
    ret


# byte get_video_mode(void);
get_video_mode:
    push  %es

    push  $0x00
    pop   %es
    movb  %es:(0x449), %al

    pop   %es

    ret


# byte get_video_page(void);
get_video_page:
    push  %es

    push  $0x00
    pop   %es
    movb  %es:(0x462), %al

    pop   %es

    ret


# short get_video_mode(void);
get_starting_address:
    push  %es

    push  $0x00
    pop   %es
    movw  %es:(0x44e), %ax

    pop   %es

    ret


# short get_video_segment(char mode);
get_video_segment:
    push  %bp
    movw  %sp, %bp

    movw  $0xb800, %ax
    cmpb  $0x07, 4(%bp)
    jne   1f
    movw  $0xb000, %ax

1:  movw  %bp, %sp
    pop   %bp
    ret


# char get_line_length(void);
get_line_length:
    push  %es

    push  $0x00
    pop   %es
    movw  %es:(0x44a), %ax
    shlw  $1, %ax

    pop   %es

    ret
    ret


# void set_video_mode(char mode);
set_video_mode:
    push  %bp
    movw  %sp,    %bp

    movw  4(%bp), %ax
    movb  $BIOS_SET_MODE,   %ah
    int   $BIOS_VIDEO_CALL

    movw  %bp, %sp
    pop   %bp
    ret


# void set_video_page(char page);
set_video_page:
    push  %bp
    movw  %sp, %bp

    movw  4(%bp),     %ax
    movb  $BIOS_SET_PAGE,   %ah
    int   $BIOS_VIDEO_CALL

    movw  %bp, %sp
    pop   %bp
    ret



.section .bss
    .lcomm video_mode,        2
    .lcomm video_page,        2
    .lcomm video_mode_old,    2
    .lcomm video_page_old,    2
    .lcomm video_segment,     2
    .lcomm video_offset,      2
    .lcomm start_column,      2
    .lcomm line_length,       2
    .lcomm table_start,       2
    .lcomm wide_mode,         2
    .lcomm table_width,       2
    .lcomm mode_string_start, 2
    .lcomm page_string_start, 2


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
    .asciz "current mode:"
.set mode_string_length, (. - mode_string)

page_string:
    .asciz "active page:"
.set page_string_length, (. - page_string)

help_key:
    .asciz "-h"

mode_key:
    .asciz "-m"

page_key:
    .asciz "-p"

clean_key:
    .asciz "-c"

blink_key:
    .asciz "-b"


.include "./set-mode.S"


# interrupts number
.set DOS_MULTIPLEX_IRQ,      0x2f
.set DOS_SYSCALL,            0x21
.set BIOS_VIDEO_CALL,        0x10
.set KEYBOARD_CALL,          0x16

# DOS int 0x21 functions
.set DOS_PRINT_CHAR,         0x02
.set DOS_PRINT_STRING,       0x09
.set DOS_SET_IRQ_HANDLER,    0x25
.set DOS_MAKE_RESIDENT,      0x31
.set DOS_GET_IRQ_HANDLER,    0x35
.set DOS_OPEN_FILE,          0x3d
.set DOS_READ_FILE,          0x3f
.set DOS_FREE_MEMORY,        0x49
.set DOS_EXIT,               0x4c

# BIOS video function
.set BIOS_SET_MODE,          0x00
.set BIOS_SET_POSITION,      0x02
.set BIOS_SET_PAGE,          0x05
.set BIOS_SCROLL_UP,         0x06
.set BIOS_SCROLL_DOWN,       0x07
.set BIOS_WRITE_CHAR_COLOR,  0x09
.set BIOS_WRITE_CHAR,        0x0a
.set BIOS_GET_MODE,          0x0f

# Keyboard function
.set KEYBOARD_WAIT_CHAR,     0x00

# other
.set TRUE,                   0x00
.set FALSE,                  0x01

.set SUCCESS,                0x00
.set FAIL,                   0x01

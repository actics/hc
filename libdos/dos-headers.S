# interrupts number
.set DOS_MULTIPLEX_IRQ,   0x2f
.set DOS_SYSCALL,         0x21

# DOS int 0x21 functions
.set DOS_PRINT_CHAR,      0x02
.set DOS_PRINT_STRING,    0x09
.set DOS_SET_IRQ_HANDLER, 0x25
.set DOS_MAKE_RESIDENT,   0x31
.set DOS_GET_IRQ_HANDLER, 0x35
.set DOS_FREE_MEMORY,     0x49
.set DOS_EXIT,            0x4c

# other
.set TRUE,                0x00
.set FALSE,               0x01


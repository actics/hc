ld_script  = ../libdos/ldcom
as_flags   = -march=i386 -mtune=i8086 --32
link_flags = -T $(ld_script) --oformat binary 
dos_root   = ~/university/dos/

build: scancode.S 
	as $(as_flags)   scancode.S -o scancode.o
	ld $(link_flags) scancode.o -o scancode.com
	cp scancode.com $(dos_root)


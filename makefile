ld_script  = ./libdos/ldcom
as_flags   = -march=i386 -mtune=i8086 --32
link_flags = -T $(ld_script) --oformat binary 
dos_root   = ~/university/dos/

build: map.S 
	as $(as_flags)   map.S -o map.o
	ld $(link_flags) map.o -o map.com
	cp map.com $(dos_root)


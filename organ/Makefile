ld_script  = ../libdos/ldcom
as_flags   = -march=i386 -mtune=i8086 --32
link_flags = -T $(ld_script) --oformat binary 
dos_root   = ~/university/dos/

build: organ.S 
	as $(as_flags)   organ.S -o organ.o
	ld $(link_flags) organ.o -o organ.com
	cp organ.com $(dos_root)


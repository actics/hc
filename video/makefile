ld_script  = ../libdos/ldcom
as_flags   = -march=i386 -mtune=i8086 --32
link_flags = -T $(ld_script) --oformat binary 
dos_root   = ~/university/dos/

build: censqr.S 
	as $(as_flags)   censqr.S -o censqr.o
	ld $(link_flags) censqr.o -o censqr.com
	cp censqr.com $(dos_root)


ld_script  = ../libdos/ldcom
as_flags   = -march=i386 -mtune=i8086 --32
link_flags = -T $(ld_script) --oformat binary 
dos_root   = ~/university/dos/

build: mp.S censqr.S 
	as $(as_flags)   censqr.S -o censqr.o
	ld $(link_flags) censqr.o -o censqr.com
	cp censqr.com $(dos_root)
	as $(as_flags)   mp.S -o mp.o
	ld $(link_flags) mp.o -o mp.com
	cp mp.com $(dos_root)


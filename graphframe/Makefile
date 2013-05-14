ld_script  = ../libdos/ldcom
as_flags   = -march=i386 -mtune=i8086 --32
link_flags = -T $(ld_script) --oformat binary 
dos_root   = ~/university/dos/

build: graphframe.S lib.S
	as $(as_flags)   graphframe.S -o graphframe.o
	as $(as_flags)   lib.S        -o lib.o
	ld $(link_flags) graphframe.o lib.o -o grpfr.com
	cp grpfr.com $(dos_root)


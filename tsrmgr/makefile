ld_script  = ../libdos/ldcom
as_flags   = -march=i386 -mtune=i8086 --32
link_flags = -T $(ld_script) --oformat binary 
dos_root   =~/university/dos/

build: tsrmgr.S 
	as $(as_flags)   tsrmgr.S -o tsrmgr.o
	ld $(link_flags) tsrmgr.o -o tsrmgr.com
	cp tsrmgr.com $(dos_root)


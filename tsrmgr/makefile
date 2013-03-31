ld_script  = ../libdos/ldcom
as_flags   = -march=i386 -mtune=i8086 --32
link_flags = -T $(ld_script) --oformat binary 
dos_root   =~/university/dos/

build: tsrmgr.S 
	as $(as_flags)   tsrmgr.S -o tsrmgr1.o
	as $(as_flags)   tsrmgr.S -o tsrmgr2.o --defsym ANOTHER_RESIDENT=1
	ld $(link_flags) tsrmgr1.o -o tsrmgr1.com
	ld $(link_flags) tsrmgr2.o -o tsrmgr2.com
	cp tsrmgr1.com $(dos_root)
	cp tsrmgr2.com $(dos_root)


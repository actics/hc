ld_script  = ../libdos/ldcom
as_flags   = -march=i386 -mtune=i8086 --32
link_flags = -T $(ld_script) --oformat binary 
dos_root   = ~/university/dos/

build: censqr mode_setter exec.bat
	cp exec.bat $(dos_root)

mode_setter: set-mode.S
	as $(as_flags)   set-mode.S -o set-mode.o
	ld $(link_flags) set-mode.o -o set-mode.com
	cp set-mode.com $(dos_root)

censqr: censqr.S 
	as $(as_flags)   censqr.S -o censqr.o
	ld $(link_flags) censqr.o -o censqr.com
	cp censqr.com $(dos_root)


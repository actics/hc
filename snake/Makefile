build:
	as -march=i386 -mtune=i8086 --32 main.S -o main.o
	as -march=i386 -mtune=i8086 --32 gas.S -o gas.o
	nasm -g -f elf32 nasm.asm -o nasm.o
	ld -T ../libdos/ldcom --oformat binary main.o gas.o nasm.o -o ml.com


target = asmerver
sources = src/main.asm src/net.asm src/print.asm src/string.asm

all: asmerver

release:
		nasm -felf64 -I src/ src/main.asm -o obj/main.o
		ld obj/main.o -o $(target)
		strip -s $(target)


$(target): obj/main.o
		ld obj/main.o -o $(target)

obj/main.o: $(sources)
		nasm -gdwarf -felf64 -Isrc/ src/main.asm -o obj/main.o

clean:
	rm -rf obj/* $(target)

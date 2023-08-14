target = asmerver

all: asmerver

release: obj
		nasm -felf64 -I src/ src/main.asm -o obj/main.o
		ld obj/main.o -o $(target)
		strip -s $(target)

debug: obj
		nasm -gdwarf -felf64 -Isrc/ src/main.asm -o obj/main.o
		ld obj/main.o -o $(target)

# Default build is debug
$(target): debug

obj:
		mkdir $@

clean:
	rm -rf obj $(target)

# asmerver
Single threaded HTTP server for 64-bit Linux.

Features:
* No libs required
* Serve specific root
* 200 and 404 responses

# Installation
`make` for debug version and `make release` for stripped version.

Without make:
```
nasm -I src/ -felf64 src/main.asm -o main.o
ld main.o -o asmerver
```

Of course, `nasm` must be installed.

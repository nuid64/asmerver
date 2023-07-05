struc sockaddr_in
    sin_family resw 1
    sin_port   resw 1
    sin_addr   resd 1
    sin_zero   resb 8
endstruc

; convert numbers to network byte order
%define htonl(x) ((x & 0xFF000000) >> 24) | ((x & 0x00FF0000) >> 8) | ((x & 0x0000FF00) << 8) | ((x & 0x000000FF) << 24)
%define htons(x) ((x >> 8) & 0xFF) | ((x & 0xFF) << 8)

SOCK_STREAM equ 0x01
AF_INET     equ 0x02
IPPROTO_TCP equ 0x06
INADDR_ANY  equ 0x00000000

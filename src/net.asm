; convert numbers to network byte order
%define htonl(x) ((x & 0xFF000000) >> 24) | ((x & 0x00FF0000) >> 8) | ((x & 0x0000FF00) << 8) | ((x & 0x000000FF) << 24)
%define htons(x) ((x >> 8) & 0xFF) | ((x & 0xFF) << 8)

struc sockaddr_in
        sin_family resw 1
        sin_port   resw 1
        sin_addr   resd 1
        sin_zero   resq 1
endstruc

SOCK_STREAM equ 0x01
AF_INET     equ 0x02
IPPROTO_TCP equ 0x06
INADDR_ANY  equ 0x00000000


        section .text

; IN  = RDI: u64 socketfd
;       RSI: void *message
;       RDX: u64 length
send:
        push       r10
        push       r8
        push       r9

        mov        r10, 0                                      ; pass flags
        mov        r8, 0                                       ; pass *dest_addr (NULL)
        mov        r9, 0                                       ; pass dest_len (0)
        call       sys_sendto                                  ; bytes sent in rax on success

        cmp        rax, 0
        jge        .exit
        mov        rdi, err_msg_send
        jmp        error                                       ; exit with error
.exit:
        pop        r9
        pop        r8
        pop        r10

        ret

        section .text

; IN  = RDI: u64 fd
;       RSI: void *buf
;       RDX: u64 count
; OUT = RAX: u64 byte read
;                -1 on err
sys_read:
        mov        rax, 0x00
        syscall
        ret


; IN  = RDI: u64 fd
;       RSI: void *buf
;       RDX: u64 count
; OUT = RAX: u64 bytes written
;                -1 on err
sys_write:
        mov        rax, 0x01
        syscall
        ret


; IN  = RDI: char *pathname
;       RSI: u64 flags
; OUT = RAX: u64 fd
;                -1 on err
sys_open:
        mov        rax, 0x02
        syscall
        ret


; IN  = RDI: u64 fd
; OUT = RAX: u64 0
;                -1 on err
sys_close:
        mov        rax, 0x03
        syscall
        ret


; IN  = RDI: u64 fd struct stat *buf
;       RSI: struct stat *buf
; OUT = RAX: u64 0
;                -1 on err
;       RSI: struct stat *buf
sys_fstat:
        mov        rax, 0x05
        syscall
        ret


; IN  = RDI: void *addr
; OUT = RAX: u64 0
;                -1 on err
sys_brk:
    mov     rax, 0x0C
    syscall
    ret


; IN  = RDI: u64 domain
;       RSI: u64 type
;       RDX: u64 protocol
; OUT = RAX: u64 fd
;                -1 on err
sys_socket:
        mov        rax, 0x29
        syscall
        ret


; IN  = RDI: u64 sockfd
;       RSI: struct sockaddr *addr
;       RDX: socklen_t* addrlen
;       RCX: u64 flags
; OUT = RAX: u64 accepted socket's fd
;                -1 on err
sys_accept:
        mov        rax, 0x2b
        syscall
        ret


; IN  = RDI: u64 sockfd
;       RSI: void *message
;       RDX: u64 length
;       RCX: u64 flags
;       R8:  struct sockaddr *dest_addr
;       R9:  socklen_t dest_len
; OUT = RAX: u64 bytes sent
;                -1 on err
sys_sendto:
        mov        rax, 0x2c
        syscall
        ret


; IN  = RDI: u64
;       RSI: struct sockaddr *addr
;       RDX: socklen_t addrlen
; OUT = RAX: u64 0
;                -1 on err
sys_bind:
        mov        rax, 0x31
        syscall
        ret


; IN  = RDI: u64 sockfd
;       RSI: u64 backlog
; OUT = RAX: u64 0
;                -1 on err
sys_listen:
        mov        rax, 0x32
        syscall
        ret


; IN  = RDI: u64 sockfd setsockopt(int socket, int level, int option_name,
;       RSI: u64 level
;       RDX: u64 option_name
;       RCX: void *option_value
;       R8:  socklen_t option_len
; OUT = RAX: u64 0
;                -1 on err
sys_setsockopt:
        mov        rax, 0x36
        syscall
        ret


; IN  = RDI: u64 status
sys_exit:
        mov        rax, 0x3c
        syscall
        ret


; IN  = RDI: char *path
; OUT = RAX: u64 0
;                -1 on err
sys_chdir:
        mov        rax, 0x50
        syscall
        ret

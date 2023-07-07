    SECTION .text

; int read(int fd, void *buf, size_t count)
; return: bytes read on success, -1 on error
sys_read:
    mov     rax, 0x00
    syscall
    ret


; size_t write(int fd, const void *buf, size_t count)
; return: bytes written on success, -1 on error
sys_write:
    mov     rax, 0x01
    syscall
    ret


; int open(char *pathname, int flags, mode_t mode)
; return: fd on success, -1 on error
sys_open:
    mov     rax, 0x02
    syscall
    ret


; int close(int fd)
; return: 0 on success, -1 on error
sys_close:
    mov     rax, 0x03
    syscall
    ret


; int fstat(int fd, struct stat *buf)
; return: 0 on success and stat, -1 on error
sys_fstat:
    mov     rax, 0x05
    syscall
    ret


; int brk(void *addr)
; return: 0 on success, -1 on error
sys_brk:
    mov     rax, 0x0C
    syscall
    ret


; int socket(int domain, int type, int protocol)
; return: fd on success, -1 on error
sys_socket:
    mov     rax, 0x29
    syscall
    ret


; int accept(int sockfd, struct sockaddr *restrict addr,
;            socklen_t *restrict addrlen, int flags)
; return: accepted socket's fd on success, -1 on error
sys_accept:
    mov     rax, 0x2b
    syscall
    ret


; size_t sendto(int socket, const void *message, size_t length, int flags,
;               const struct sockaddr *dest_addr, socklen_t dest_len)
; return: bytes sent on success, -1 on error
sys_sendto:
    mov     rax, 0x2c
    syscall
    ret


; int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
; return: 0 on success, -1 on error
sys_bind:
    mov     rax, 0x31
    syscall
    ret


; int listen(int sockfd, int backlog)
; return: 0 on success, -1 on error
sys_listen:
    mov     rax, 0x32
    syscall
    ret


; int setsockopt(int socket, int level, int option_name,
;                const void *option_value, socklen_t option_len)
; return: 0 on success, -1 on error
sys_setsockopt:
    mov     rax, 0x36
    syscall
    ret


; void exit(int status)
sys_exit:
    mov     rax, 0x3c
    syscall
    ret


; int chdir(const char *path)
; return: 0 on success, -1 on error
sys_chdir:
    mov     rax, 0x50
    syscall
    ret

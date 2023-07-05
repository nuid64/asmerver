; constants
%define IP               htonl(INADDR_ANY) ; 0x00000000
%define PORT             8008
%define BACKLOG          8
%define RESPONSE_BUF_CAP 1024

    SECTION .text
%include "string.asm"
%include "print.asm"
%include "net.asm"
%include "syscall.asm"

global _start
_start:
    ; clear registers
    xor     rax, rax
    xor     rdi, rdi
    xor     rsi, rsi
    xor     rdx, rdx

handle_arguments:
    pop     r8                         ; pop number of arguments
    cmp     r8, 2                      ; check arguments count is good
    je      .check_arguments

    mov     rdi, help_msg              ; print help message otherwise
    call    println
    jmp     exit_failure

.check_arguments:
    pop     r8                         ; discard binary name
    pop     rdi                        ; listening port
    call    atoi                       ; convert to integer
    xchg    ah, al                     ; change byte order to big endian
    mov     [list_port], rax           ; save listening port
    pop     r8                         ; serving directory
    mov     [serving_directory], r8    ; save serving directory

; SENDING STATIC RESPONSE FOR NOW
open_response_file:
    mov     rdi, content_file_path     ; pass pathname
    mov     rsi, 0                     ; O_RDONLY
    call    sys_open                   ; fd on success

    ; error info
    cmp     rax, 0x00 
    jge     read_response
    mov     rdi, err_msg_open
    jmp     error                      ; exit with error

read_response:
    mov     rdi, rax                   ; pass fd
    mov     rsi, response_buf          ; pass *buf
    mov     rdx, RESPONSE_BUF_CAP      ; pass count
    call    sys_read                   ; bytes read in rax on success

    ; error info
    cmp     rax, 0x00
    jge     .success
    mov     rdi, err_msg_read
    jmp     error                      ; exit with error

.success:
    mov     [response_buf_len], rax    ; write length of response

create_socket:
    mov     rdi, AF_INET               ; pass domain (0x02)
    mov     rsi, SOCK_STREAM           ; pass type (0x01)
    mov     rdx, IPPROTO_TCP           ; pass protocol (0x06)
    call    sys_socket                 ; list_sockfd in rax on success

    ; error info
    cmp     rax, 0x00
    jge     set_sock_opt
    mov     rdi, err_msg_socket
    jmp     error                      ; exit with error

set_sock_opt:
    mov     [list_sock], rax           ; save list_sockfd
    mov     rdi, rax                   ; pass socket
    mov     rsi, 0x01                  ; pass level (SOL_SOCKET)
    mov     rdx, 0x02                  ; pass option_name (SO_REUSEADDR)
    mov     r10, sock_addr             ; pass option_value 
    mov     r8, sockaddr_in_size       ; pass option_len (size of sock_addr)
    call    sys_setsockopt             ; 0 in rax on success

    ; error info
    cmp     rax, 0x00
    je      bind
    mov     rdi, err_msg_socket_opt
    jmp     error                      ; exit with error

bind:
    mov     rsi, [list_port]           ; get list_sockfd
    mov     [sock_addr + sin_port], rsi; set port

    mov     rdi, [list_sock]           ; pass list_sockfd
    mov     rsi, sock_addr             ; pass *addr
    mov     rdx, sockaddr_in_size      ; pass addrlen (size of sock_addr)
    call    sys_bind                   ; 0 in rax on success

    ; error info
    cmp     rax, 0x00
    je      listen
    mov     rdi, err_msg_bind
    jmp     error                      ; exit with error

listen:
    mov     rdi, [list_sock]           ; pass list_sockfd
    mov     rsi, BACKLOG               ; pass backlog (max len of queue of pending conns)
    call    sys_listen                 ; 0 in rax on success

    cmp     rax, 0x00
    je      accept
    call    sys_close                  ; close socket
    mov     rdi, err_msg_listen
    jmp     error                      ; exit with error

accept:
    mov     rdi, [list_sock]           ; pass list_sockfd
    mov     rsi, 0x00                  ; pass addr (NULL)
    mov     rdx, 0x00                  ; pass addrlen (size of sockaddr) (NULL)
    call    sys_accept                 ; accepted socket's fd in rax on success

    cmp     rax, 0x00
    jge     send_status
    mov     rdi, err_msg_accept
    jmp     error                      ; exit with error

send_status:
    mov     r8, rax                    ; save acc_sockfd

    mov     rsi, http_200              ; pass *buf
    mov     rdi, rsi
    call    slen
    mov     rdx, rax                   ; pass count
    mov     rdi, r8                    ; pass fd (acc_sockfd)
    call    sys_sendto                 ; bytes sent in rax on success

.send_content_length_label:
    mov     rdi, r8                    ; pass fd (acc_sockfd)
    mov     rsi, cont_length           ; pass *buf
    mov     rdx, cont_length_len       ; pass count
    call    sys_sendto                 ; bytes sent in rax on success


.send_content_length:
    mov     rdi, [response_buf_len]
    mov     rsi, cont_len_buf
    call    itoa                       ; convert response length to string

    mov     rdi, rsi                   ; pass *buf
    call    slen
    mov     rdx, rax                   ; pass count

    mov     rdi, r8                    ; pass fd (acc_sockfd)
    call    sys_sendto                 ; bytes sent in rax on success

.send_cr_lf:
    mov     rdi, r8                    ; pass fd (acc_sockfd)
    mov     rsi, cr_lf                 ; pass *buf
    mov     rdx, 2                     ; pass count
    call    sys_sendto                 ; bytes sent in rax on success
    

    mov     rdi, r8                    ; passs fd (acc_sockfd)
    mov     rsi, cr_lf                 ; pass *buf
    mov     rdx, 2                     ; pass count
    call    sys_sendto                 ; bytes sent in rax on success

.send_content:
    mov     rdi, response_buf
    call    slen                       ; calc response length
    mov     rdx, rax                   ; pass count

    mov     rdi, r8                    ; pass fd
    mov     rsi, response_buf          ; pass *buf
    call    sys_sendto                 ; bytes sent placed in rax on success

    call    sys_close                  ; close socket

    cmp     rax, 0x00
    jge     .success
    mov     rdi, err_msg_send
    jmp     error                      ; exit with error

.success:
    jmp     accept                     ; accept loop


error:
    call    eprintln
    jmp     exit_failure


; exit program and restore resources
exit_success:
    mov     rdi, 0x00                  ; EXIT_SUCCESS
    call    sys_exit


; exit program with error
exit_failure:
    mov     rdi, 0x01                  ; EXIT_FAILURE
    call    sys_exit


    SECTION .bss

    serving_directory  resq 1
    response_buf       resb RESPONSE_BUF_CAP
    response_buf_len   resq 1
    list_sock          resq 1
    list_port          resw 1
    cont_len_buf       resb 19


    SECTION .data

    sock_addr: istruc sockaddr_in
        at sin_family, dw AF_INET
        at sin_port,   dw 0
        at sin_addr,   dd INADDR_ANY
        at sin_zero,   dd 0x0000000000000000
    iend


    SECTION .rodata

    help_msg           db    "asmerver 0.2",0x0a,"nuid64 <lvkuzvesov@proton.me>",0x0a,"Usage: ",0x0a,0x09,"asmerver <port>",0x00

    err_msg_open       db    "Failed to open response file",0x00
    err_msg_read       db    "Failed to read response",0x00
    err_msg_socket     db    "Failed to create socket",0x00
    err_msg_socket_opt db    "Failed to set socket options",0x00
    err_msg_bind       db    "Failed to bind the address",0x00
    err_msg_listen     db    "Failed to make socket listen",0x00
    err_msg_accept     db    "Failed to accept connection",0x00
    err_msg_send       db    "Failed to send",0x00

    content_file_path  db    "index.html",0x00

    http_200           db    "HTTP/1.1 200 OK",0x0d,0x0a,0x00
    http_200_len       equ   $ - http_200 - 1

    cont_length        db    "Content-Length: ",0x00
    cont_length_len    equ   $ - cont_length - 1

    cr_lf              db    0x0d,0x0a,0x00

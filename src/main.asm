; constants
%define BACKLOG             8
%define REQUEST_BUF_CAP     2048
%define RESPONSE_HEADER_CAP 2048

%include "http.asm"
%include "net.asm"
%include "os.asm"
%include "print.asm"
%include "string.asm"
%include "syscall.asm"

    SECTION .text

global _start
_start:
    ; clear registers
    xor     rax, rax
    xor     rdi, rdi
    xor     rsi, rsi
    xor     rdx, rdx

handle_arguments:
    pop     r8                         ; pop number of arguments
    cmp     r8, 3                      ; check arguments count is good
    je      .get_arguments

    mov     rdi, help_msg              ; print the help and exit otherwise
    call    println
    jmp     exit_failure

.get_arguments:
    pop     r8                         ; discard binary name

    pop     rdi                        ; listening port
    call    atoi                       ; convert to integer
    xchg    ah, al                     ; change byte order to big endian
    mov     [list_sock_port], rax      ; save listening port

    pop     rdi                        ; serving directory

.change_directory:
    call    sys_chdir                  ; 0 on success
    cmp     rax, 0
    je      .continue
    mov     rdi, err_msg_dir
    jmp     error                      ; exit with error
.continue:


create_socket:
    mov     rdi, AF_INET               ; pass domain (0x02)
    mov     rsi, SOCK_STREAM           ; pass type (0x01)
    mov     rdx, IPPROTO_TCP           ; pass protocol (0x06)
    call    sys_socket                 ; list_sockfd in rax on success

    ; error info
    cmp     rax, 0
    jge     .continue
    mov     rdi, err_msg_socket
    jmp     error                      ; exit with error
.continue:

set_sock_opt:
    mov     [list_sock], rax           ; save list_sockfd
    mov     rdi, rax                   ; pass socket
    mov     rsi, 0x01                  ; pass level (SOL_SOCKET)
    mov     rdx, 0x02                  ; pass option_name (SO_REUSEADDR)
    mov     r10, sock_addr             ; pass option_value 
    mov     r8, sockaddr_in_size       ; pass option_len (size of sock_addr)
    call    sys_setsockopt             ; 0 in rax on success

    ; error info
    cmp     rax, 0
    je      .continue
    mov     rdi, err_msg_socket_opt
    jmp     error                      ; exit with error
.continue:

bind:
    mov     rsi, [list_sock_port]
    mov     [sock_addr+sin_port], rsi  ; set port

    mov     rdi, [list_sock]           ; pass list_sockfd
    mov     rsi, sock_addr             ; pass *addr
    mov     rdx, sockaddr_in_size      ; pass addrlen (size of sock_addr)
    call    sys_bind                   ; 0 in rax on success

    ; error info
    cmp     rax, 0
    je      .continue
    mov     rdi, err_msg_bind
    jmp     error                      ; exit with error
.continue:

listen:
    mov     rdi, [list_sock]           ; pass list_sockfd
    mov     rsi, BACKLOG               ; pass backlog (max len of queue of pending conns)
    call    sys_listen                 ; 0 in rax on success

    cmp     rax, 0
    je      .continue
    call    sys_close                  ; close socket
    mov     rdi, err_msg_listen
    jmp     error                      ; exit with error
.continue:

accept:
    mov     rdi, [list_sock]           ; pass list_sockfd
    mov     rsi, 0x00                  ; pass addr (NULL)
    mov     rdx, 0x00                  ; pass addrlen (size of sockaddr) (NULL)
    call    sys_accept                 ; accepted socket's fd in rax on success

    cmp     rax, 0
    jge     .continue
    mov     rdi, err_msg_accept
    jmp     error                      ; exit with error
.continue:
    mov     r12, rax                   ; save acc_sockfd

read_request:
    mov     rdi, r12                   ; pass acc_sockfd
    mov     rsi, request_buf           ; pass *buf
    mov     rdx, REQUEST_BUF_CAP       ; pass count
    call    sys_read                   ; bytes read on success

    cmp     rax, 0
    jge     .continue
    mov     rdi, err_msg_read_req
    jmp     error                      ; exit with error
.continue:

check_request_is_get:
    mov     rdi, request_buf           ; pass *request
    call    is_get_request
    cmp     rax, 0                     ; if not GET then don't response
    jz      listen

get_file_path:
    mov     rdi, request_buf           ; pass *request
    call    extract_resource_path

    cmp     byte[rax], 0               ; if standard file path (points at term zero)
    jnz     .continue
    mov     rax, index_file            ; response with index
.continue:

open_response_file:
    mov     rdi, rax                   ; pass *pathname
    mov     rsi, 0                     ; O_RDONLY
    call    sys_open                   ; fd on success

    ; error info
    cmp     rax, 0 
    jl      response_404               ; response 404 if can't open file

response_200:
    mov     rdi, rax                   ; pass contentfd
    mov     rsi, r12                   ; pass sockfd
    call    send_http_200
    jmp     close_socket

response_404:
    mov     rdi, r12                   ; pass sockfd
    call    send_http_404

close_socket:
    mov     rdi, r12                   ; pass fd
    call    sys_close                  ; close socket

    cmp     rax, 0
    je      .continue
    mov     rdi, err_msg_close_sock
    jmp     error                      ; exit with error
.continue:
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

    list_sock           resq 1
    list_sock_port      resw 1
    request_buf         resb REQUEST_BUF_CAP
    request_buf_len     resq 1
    file_stat           resb 64


    SECTION .data

    sock_addr: istruc sockaddr_in
        at sin_family,  dw AF_INET
        at sin_port,    dw 0
        at sin_addr,    dd INADDR_ANY
        at sin_zero,    dd 0x0000000000000000
    iend


    SECTION .rodata

    help_msg            db    "asmerver 0.4",0x0a,"nuid64 <lvkuzvesov@proton.me>",0x0a,"Usage: ",0x0a,0x09,"asmerver <port> <served directory>",0x00

    err_msg_alloc       db    "Memory allocating completed with error",0x00
    err_msg_dir         db    "Can't open served directory",0x00
    err_msg_read        db    "An error occured during reading a file",0x00
    err_msg_read_req    db    "An error occured during reading a request",0x00
    err_msg_socket      db    "Failed to create socket",0x00
    err_msg_socket_opt  db    "Failed to set socket options",0x00
    err_msg_bind        db    "Can't bind address",0x00
    err_msg_listen      db    "Socket don't want to listen",0x00
    err_msg_accept      db    "Connection not accepted",0x00
    err_msg_send        db    "An error occured during sending response",0x00
    err_msg_close_sock  db    "Failed to close socket",0x0

    index_file          db    "index.html",0x00

    cont_length         db    "Content-Length: ",0x00
    cont_length_len     equ   $ - cont_length - 1

    cr_lf               db    0x0d,0x0a,0x00

struc stat
    .st_dev        resq 1
    .st_ino        resq 1
    .st_nlink      resq 1
    .st_mode       resd 1
    .st_uid        resd 1
    .st_gid        resd 1
    .pad0          resb 4
    .st_rdev       resq 1
    .st_size       resq 1
    .st_blksize    resq 1
    .st_blocks     resq 1
    .st_atime      resq 1
    .st_atime_nsec resq 1
    .st_mtime      resq 1
    .st_mtime_nsec resq 1
    .st_ctime      resq 1
    .st_ctime_nsec resq 1
endstruc

    SECTION .text
; void* mem_alloc(size_t size)
; return: new heap addr on success, -1 on error
mem_alloc:
    push    rdi                        ; save size
    xor     rdi, rdi                   ; zero to get current heap addr
    call    sys_brk

    cmp     rax, 0                     ; return if error occured
    jl      .exit_early

    pop     rdi                        ; get size
    lea     rdi, [rdi + rax]           ; load new heap addr
    call    sys_brk
    jmp     .exit

.exit_early:
    pop     rdi
.exit:
    ret


; void* current_heap_addr()
current_heap_addr:
    push rdi
    xor     rdi, rdi                   ; zero to get current heap addr
    call    sys_brk
    pop rdi

    ret

; int read_flie(int fd, void* buf, size_t count)
; read the file to the buffer
read_file:
    call    sys_read                   ; bytes read in rax on success

    ; error info
    cmp     rax, 0
    jge     .exit
    mov     rdi, err_msg_read
    jmp     error                      ; exit with error
.exit:
    ret

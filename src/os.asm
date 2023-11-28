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


        section .text

; IN  = RDI: u64 size
; OUT = RAX: void *allocated memory
;            -1 on err
mem_alloc:
        push       rdi
        push       r8

        mov        r8, rdi                                     ; save size
        xor        rdi, rdi                                    ; zero to get current heap addr
        call       sys_brk

        cmp        rax, 0                                      ; return if error occured
        jl         .exit

        mov        rdi, r8                                     ; get size
        lea        rdi, [rdi + rax]                            ; load new heap addr
        call       sys_brk
        jmp        .exit

.exit:
        pop        r8
        pop        rdi

        ret


; OUT = RAX: u64 heap addr
current_heap_addr:
        push       rdi

        xor        rdi, rdi                                    ; zero to get current heap addr
        call       sys_brk

        pop        rdi

        ret

; IN  = RDI: u64 fd
;       RSI: void *buf
;       RDX: u64 count
; OUT = RAX: u64 bytes read
;                -1 on err
read_file:
        call       sys_read                                    ; bytes read in rax on success

    ; error info
        cmp        rax, 0
        jge        .exit
        mov        rdi, err_msg_read
        jmp        error                                       ; exit with error
.exit:
        ret

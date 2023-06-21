; void *mem_alloc(int bytes)
; return: new heap addr on success, -1 on error
mem_alloc:
    push    rdi                        ; save bytes
    xor     rdi, rdi                   ; zero for getting current heap addr
    call    sys_brk

    cmp     rax, 0                     ; return if error occured
    jl      .exit_early

    pop     rdi                        ; get bytes
    lea     rdi, [rdi + rax]           ; load new heap addr
    call    sys_brk
    jmp     .exit

.exit_early:
    pop     rdi
.exit:
    ret

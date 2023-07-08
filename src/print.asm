    SECTION .text

; void println(char* buf)
; print buf in STDOUT with linefeed
println:
    push    rdi

    call    print                      ; print buf
    mov     rdi, linefeed              ; pass *buf
    call    print                      ; print linefeed

    pop     rdi
    ret


; int print(char* buf)
; print buf in STDOUT
print:
    push    rdi
    push    rsi
    push    rdx

    call    slen
    mov     rdx, rax                   ; pass count
    mov     rsi, rdi                   ; pass *buf
    mov     rdi, 1                     ; pass fd (STDOUT)
    call    sys_write

    pop     rdx
    pop     rsi
    pop     rdi
    ret


; void eprintln(char* err_msg)
; print err_msg in STDERR with linefeed
eprintln:
    push    rdi

    call    eprint                     ; print error

    mov     rdi, linefeed              ; pass *buf
    call    print                      ; print linefeed

    pop     rdi
    ret


; void eprint(char* err_msg)
; print err_msg in STDERR
eprint:
    push    rdi
    push    rsi
    push    rdx
    push    rax

    mov     r8, rdi                    ; save err_msg

    mov     rdi, 2                     ; pass fd (STDERR)
    mov     rsi, err_prefix            ; pass *buf
    mov     rdx, err_prefix_len        ; pass count
    call    sys_write

    mov     rsi, r8                    ; pass *buf
    mov     rdi, rsi                   ; calculate length of err_msg
    call    slen
    mov     rdx, rax                   ; pass count
    mov     rdi, 2                     ; pass fd (STDERR)
    call    sys_write

    pop     rax
    pop     rdx
    pop     rsi
    pop     rdi
    ret


    SECTION .data

err_prefix      db  "Error: ",0x00
err_prefix_len  equ $-err_prefix - 1
linefeed        db  0x0a, 0x00

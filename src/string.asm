    SECTION .text

; void strcat(char *dest, char* src)
; concatenates src to dest
strcat:
    push    rdi
    push    rsi
    push    rax

.find_end:
    mov     al, byte [rdi]             ; load char
    inc     rdi                        ; increase ptr
    cmp     al, 0x00                   ; until it reached terminating zero
    jne     .find_end

    dec     rdi                        ; place ptr back to terminating zero
    cld                                ; clear decimal for lodsb
.place_char:
    lodsb                              ; load char
    mov     [rdi], al                  ; place char
    inc     rdi                        ; increase ptr
    cmp     al, 0x00                   ; until it reached terminating zero
    jne     .place_char
.end:
    pop     rax
    pop     rsi
    pop     rdi
    ret


; int slen(char *str)
; calculates length of string
slen:
    push    rdi
    push    rsi
    push    rcx

    cld                                ; clear decimal for lodsb
    mov     rcx, -1                    ; take termintating zero into account
    mov     rsi, rdi                   ; move ptr to rsi for lodsb
.nextchar:
    inc     rcx                        ; increase counter
    lodsb                              ; load char
    cmp     al, 0x00                   ; until it reached terminating zero
    jne     .nextchar

    mov     rax, rcx                   ; return value
    pop     rcx
    pop     rsi
    pop     rdi
    ret


; void itoa(int num, char *buf)
; int to char* conversion
itoa:
    push    rdi
    push    rsi
    push    rdx
    push    rax
    push    rbx

.start_converting:
    call    calc_digits_count          ; get number of digits
    mov     rcx, rax

    mov     al, 0x00
    mov     [rsi+rcx], al              ; place terminating zero at the end
    dec     rcx                        ; move pointer left

    mov     rax, rdi                   ; place number for dividing
    mov     rbx, 10
.loop:
    xor     rdx, rdx                   ; avoiding error
    div     rbx                        ; get remainder of dividing by ten

    add     rdx, 0x30                  ; converting to ASCII digit's symbol
    mov     [rsi+rcx], dl              ; place char
    dec     rcx                        ; move pointer left
    cmp     rax, 9
    ja     .loop                       ; until rax is zero
.last_digit:
    add     rax, 0x30                  ; last digit
    mov     [rsi+rcx], al

.end:
    pop     rbx
    pop     rax
    pop     rdx
    pop     rsi
    pop     rdi
    ret


; int atoi(char *buf)
; char* to int conversion
atoi:
    push    rsi
    mov     rax, 0

.loop:
    movzx   rsi, byte [rdi]
    test    rsi, rsi                   ; check for \0
    je      .done

    cmp     rsi, 48                    ; check symbol is digit
    jl      .error
    cmp     rsi, 57
    jg      .error

    sub     rsi, 48                    ; convert to decimal
    imul    rax, 10
    add     rax, rsi

    inc     rdi
    jmp     .loop

.error:
    mov     rax, -1                    ; -1 on error

.done:
    pop     rsi

    ret


; int calc_digits_count(int num)
; calculates count of digits in number
calc_digits_count:
    push    rdi
    push    rdx
    push    rbx
    push    rcx

    mov     rax, rdi                   ; move number
    mov     rbx, 10
    xor     rcx, rcx                   ; zeroing counter
.loop:
    inc     rcx
    cmp     rax, 10
    jb      .end
    xor     rdx, rdx                   ; avoiding error
    div     rbx                        ; dividing by base until ratio is zero
    jmp     .loop
.end:
    mov     rax, rcx                   ; move result in rax

    pop     rcx
    pop     rbx
    pop     rdx
    pop     rdi
    ret

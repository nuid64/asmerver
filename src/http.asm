; void construct_http_200(char* buf, char* content)
; Constructs http 200 response in buf
construct_http_200:
    push    r8
    push    r9

    mov     [rdi], byte 0x00           ; 'mark' buffer as empty
    mov     r8, rdi                    ; save *buf
    mov     r9, rsi                    ; save *content

    mov     rsi, http_200
    call    strcat                     ; status

    mov     rsi, cont_length
    call    strcat                     ; content length label

    mov     rdi, r9                    ; pass *content
    call    slen                       ; calculate length of content
    mov     rdi, rax                   ; pass num
    mov     rsi, cont_len_buf          ; pass *buf
    call    itoa                       ; convert content length to string
    mov     rdi, r8
    mov     rsi, cont_len_buf
    call    strcat                     ; content length

    mov     rdi, r8
    mov     rsi, cr_lf
    call    strcat
    call    strcat                     ; cr_lf

    mov     rsi, r9
    call    strcat                     ; content

    pop     r9
    pop     r8

    ret


; bool is_get_request(char *request)
; 1 if request is GET, 0 if not
is_get_request:
    mov     ax, 0                      ; false

    cmp     byte[rdi+0], 0x47          ; 'G'
    jne     .exit
    cmp     byte[rdi+1], 0x45          ; 'E'
    jne     .exit
    cmp     byte[rdi+2], 0x54          ; 'T'
    jne     .exit

    mov     ax, 1                      ; true
.exit:
    ret


    SECTION .rodata

    get     db    "GET",0x00

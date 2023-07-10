; TODO Minimize amount of global variables

; void send_http_200(int contentfd, int sockfd)
; send http 200 response with with content from given file to given socket
send_http_200:
; get file size
    mov     r8, rdi                    ; save fd
    mov     r9, rsi                    ; save sockfd

    ; fd at rdi
    mov     rsi, file_stat             ; pass *buf
    call    sys_fstat                  ; 0 on success
    ; error is unlikely
    mov     rax, [file_stat + stat.st_size]
    mov     [content_len], rax         ; save content length

; allocate buffer for response
    call    current_heap_addr
    push    rax                        ; save current heap addr

    mov     rdi, content_len           ; pass size
    call    alloc_response_buffer

    mov     [response_buf_ptr], rax    ; save response buffer pointer
    ; HACK Adding pad for using this buffer to construct response later
    add     rax, RESPONSE_HEADER_CAP
    mov     [content_buf_ptr], rax     ; save content buffer pointer

; read content
    mov     rdi, r8                    ; pass fd
    mov     rsi, rax                   ; pass *buf
    mov     rdx, content_len           ; pass count
    call    read_file

; make response
    mov     rdi, [response_buf_ptr]    ; pass *buf
    mov     rsi, [content_buf_ptr]     ; pass *content
    call    construct_http_200         ; http 200 response

; send response
    call    slen                       ; calculate length of response
    mov     rdx, rax                   ; pass length
    mov     rsi, [response_buf_ptr]    ; pass *message
    mov     rdi, r9                    ; pass socket
    call    send

; free buffer
    pop     rdi                        ; get old heap addr
    call    sys_brk

    ret


send_http_404:
    ; socket in rdi
    mov     rsi, http_404              ; pass message
    mov     rdx, http_404_len          ; pass length
    call    send


; void construct_http_200(char* buf, char* content)
; construct http 200 response in buf
construct_http_200:
    push    r8
    push    r9

    mov     [rdi], byte 0x00           ; HACK 'mark' buffer as empty
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


; bool is_get_request(char* request)
; 1 if request is GET, 0 if not
is_get_request:
    mov     ax, 0                      ; false

    cmp     byte[rdi+0], 'G'
    jne     .exit
    cmp     byte[rdi+1], 'E'
    jne     .exit
    cmp     byte[rdi+2], 'T'
    jne     .exit

    mov     ax, 1                      ; true
.exit:
    ret


; char* alloc_response_buffer(int size)
; allocate buffer for response body + head and get buffer's address
alloc_response_buffer:
    add     rdi, RESPONSE_HEADER_CAP   ; add header size
    call    mem_alloc                  ; new heap addr on success

    cmp     rax, 0
    jge     .exit
    mov     rdi, err_msg_alloc
    jmp     error                      ; exit with error
.exit:

    ret


; HACK Places terminating zero at the end of resource path
; char* extract_resource_path(char* request)
; returns pointer to the resource path
extract_resource_path:
    add     rdi, 5                     ; skip "GET /"
    mov     rax, rdi                   ; save beginning
.loop:
    cmp     byte[rdi], ' '             ; check if space
    je      .place_zero
    inc     rdi                        ; next char
    jmp     .loop                      ; loop
.place_zero:
    mov     byte[rdi], 0x00

    ret


    SECTION .rodata

    http_200            db    "HTTP/1.1 200 OK",0x0d,0x0a,0x00
    http_200_len        equ   $ - http_200 - 1
    http_404            db    "HTTP/1.1 404 Not Found",0x0d,0x0a,0x00
    http_404_len        equ   $ - http_404 - 1

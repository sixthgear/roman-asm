; roman.s
; x86/BSD
; nasm -O1 -f macho roman.s && ld -o roman roman.o && ./roman 2014

section .text
global start

start:
    pop ecx                     ; argc
    cmp ecx, 2                  ; make sure we have input
    jl argerror
    pop ecx                     ; argv[0]
    pop ecx                     ; argv[1]
    push ecx
    call atoi                   ; convert command line arg to int
    add esp, 4                  ; clean up stack

    mov ebx, nums               ; copy nums to ebx, this is the current number
    mov ecx, syms               ; copy syms to ecx, this is the current symbol
    jmp sym_cond
    sym_inc:
    add ebx, 4                  ; increment the number pointer
    add ecx, 2                  ; increment the symbol pointer
    sym_loop:
    cmp eax, [ebx]              ; check if accumulator is less than current number
    jl sym_inc
    sub eax, [ebx]              ; subtract the current number from the accumulator
    mov edi, buf
    mov esi, ecx
    push dword 2
    call strcat                 ; add the symbol to the buffer
    add esp, 4
    sym_cond:
    cmp eax, 0                  ; continue if accumulator is greater than 0
    jg sym_loop

    sym_done:
    mov edi, buf
    mov esi, newline
    push dword 1
    call strcat                 ; append newline
    push buf
    call strlen                 ; find the length of buf
    add esp, 4
    push eax                    ; length calculated from strlen
    push buf                    ; address of buf
    push dword 1                ; stdout
    call write
    add esp, 12

    push dword 0                ; exit status returned to the operating system
    call exit

argerror:
    push dword argerr_len
    push dword argerr
    push dword 1
    call write
    add esp, 4
    push dword 0                ; exit status returned to the operating system
    call exit

write:
    mov eax, 0x4                ; system call number for write
    int 0x80
    ret

exit:
    mov eax, 0x1                ; system call number for exit
    int 0x80

atoi:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    mov ebx, [ebp+8]            ; string argument
    mov eax, 0                  ; 32-bit multiplication accumulator

    jmp atoi_cond
    atoi_loop:
    imul eax, 10
    movzx ecx, byte [ebx]
    sub ecx, 48
    add eax, ecx
    add ebx, dword 1
    atoi_cond:
    cmp byte [ebx], 0x0
    jne atoi_loop

    pop ecx
    pop ebx
    pop ebp
    ret


strlen:
    push ebp
    mov ebp, esp
    push ebx
    mov ebx, [ebp+8]
    mov eax, 0

    jmp strlen_cond
    strlen_loop:
    add eax, 1
    add ebx, 1
    strlen_cond:
    cmp byte [ebx], 0x0
    jne strlen_loop

    pop ebx
    pop ebp
    ret

strcat:
    push ebp
    mov ebp, esp
    push ecx
    mov ecx, [ebp+8]           ; int number

    ; find end of dest
    jmp strcat_cond
    strcat_loop:
    add edi, 1
    strcat_cond:
    cmp byte [edi], 0x0
    jne strcat_loop

    ; copy bytes from source
    jmp strcat_cond_2
    strcat_loop_2:
    movsb
    sub ecx, 1                  ; decrement counter
    strcat_cond_2:
    cmp ecx, 0                  ; check if number counter is 0
    je strcat_done_2
    cmp byte [esi], 0           ; check if byte is 0
    jne strcat_loop_2
    strcat_done_2:
    mov byte [edi], 0           ; append null byte

    pop ecx
    pop ebp
    ret


section .data

    nums    dd 1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1
    syms    dw "M"
            dw "CM"
            dw "D"
            dw "CD"
            dw "C"
            dw "XC"
            dw "L"
            dw "XL"
            dw "X"
            dw "IX"
            dw "V"
            dw "IV"
            dw "I"

    buf     times 64 db 0

    newline     db      0xA
    argerr      db      "Error: No argument.", 0xA
    argerr_len  equ     $-argerr

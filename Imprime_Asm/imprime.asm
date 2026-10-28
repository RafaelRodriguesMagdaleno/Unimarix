;"Função" em Assembly x86 para impressão de strings

; ponto de entrada da "função"
imprime:

;push all: empilha os valores dos regs, AX, BX, CX, e DX

    pusha

inicio:

;BX deve conter o endereço da string

    mov al, [bx] ; copia para Al o caractere apontado por BX
    cmp al, 0 ; compara o valor em AL com zero (terminador)

    ;pula para "fim" se o valor for zero (string terminou)

    je fim ; JE = Jump if Equal (Pula se igual)
    ; caso contrario (não é zero), ainda existem caracteres

    mov ab, 0x0e ; Código do serviço da bios de impressão
    int 0x10 ; chama a bios e imprime o caractere

    ; incrementamos o endereço para apontar para o próximo caractere
    add bx, I
    jmp inicio ; volta ao início (Loop)

fim:

    ; popa = pop alt: desempilha os valores de AX, BX, CX e DX

    popa ; restaurando os valores originais destes registradores
    ret ; retorna ao código onde "imprime" foi chamado
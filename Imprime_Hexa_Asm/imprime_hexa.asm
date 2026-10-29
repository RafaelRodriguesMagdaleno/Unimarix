; "Função" de impressão de valores hexadecimais na tela
; imprime quatro valores hexadecimais que deverão ser colocados em DX antes de chamar a rotina

imprime_hexa:

    pusha
    mov CX, 0 ; CX servirá como um contador de impressão

; Na tabela ASCII, o caractere para o número 0 é designado pelo valor 0x30, o caractere para 1 é o 0x31 e assim sucessivamente até o 0x39, referente ao 9
; Já o caractere "A" é indicado pelo valor 0x41, "B" por 0x42 e assim sucessivamente á 0x46 que se refere ao Função

imprimeHexa:
    pusha
    mov cx, 0 ; CX servirá com um contador de impressão

; na tabela ASCII, o charactere para o número 0 é designado pelo valor 0x30
; o caractere para 1 é 0x31 e assim sucessivamente até 0x39, referente ao 9.
; já os caracteres que representam letras são designados pelo seguinte padrão:
; 0x4<posição>, indo de 0x41 ('A') até 0x46 ('F')

hexaLoop:
    cmp cx, 4 ; se CX == 4, convertemos tudo
    je fim_hexa ; pula para fimHexa se CX == 4

    mov ax, dx ; copiando o valor hexa de DX para AX
    and ax, 0x000f ; fazemos um AND bit a bit em AX
    ; dessa forma, vai "sobrar" em AX apenas o último valor

    add al, 0x30 ; adicionamos 30 ao valor que sobrou
    
    ; se o resultado for menor ou igual a 39, então trata-se de um valor entre 0 e 9
    ; assim, vamos para o passo 2
    cmp al, 0x39
    jle passo2 ; jump if less or equal


    ; caso contrário, continua normalmente
    ; primeiro adicionamos 7
    add al, 7

    ;agora vamos ao passo 2
    jmp passo2

passo2:

    ; Bx aponta inicialmente para a ultima posição da string
    mov bx, STRING_SAIDA + 5 

    ; Subtraimos o contador em CX de BX para econtrar a posição exata do caracter atual
    sub bx, cx

    ;Copia o caractere ASCII em AL para o local apontado por BX
    mov [bx], al
    
    ; "deslocamos" o valor em DX 4 bits para a direita isso faz com que "joguemos fora" o último dígito (que já foi convertido)
    shr dx, 4 ; SHR : Shift Right


; Já deixamos reservado um espaço na memória onde colocaremos a string com os digitos hexa
STRING_SAIDA: db "0x000", 0

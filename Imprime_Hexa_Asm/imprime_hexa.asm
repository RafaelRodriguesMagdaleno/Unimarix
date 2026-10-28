; "Função" de impressão de valores hexadecimais na tela
; imprime quatro valores hexadecimais que deverão ser colocados em DX antes de chamar a rotina

imprime_hexa:

    pusha
    mov CX, 0 ; CX servirá como um contador de impressão

; Na tabela ASCII, o caractere para o número 0 é designado pelo valor 0x30, o caractere para 1 é o 0x31 e assim sucessivamente até o 0x39, referente ao 9
; Já o caractere "A" é indicado pelo valor 0x41, "B" por 0x42 e assim sucessivamente á 0x46 que se refere ao Função

hexa loop:
; impressão de strings em modo protegido (32 bits)

; Em 32 bits não podemos usar o int 0x10 da BIOS. Escrevemos direto na
; memória de vídeo do modo texto, que começa em 0xb8000. Cada caractere
; na tela ocupa 2 bytes: o código ASCII e a cor.

[bits 32]

MEMORIA_VIDEO equ 0xb8000
BRANCO_NO_PRETO equ 0x0f ; byte de cor: fundo preto (0), texto branco (f)

; EBX deve conter o endereço da string terminada em 0
; a string é escrita no canto superior esquerdo da tela
imprime_mp:
    pusha
    mov edx, MEMORIA_VIDEO ; EDX aponta para a primeira posição da tela

imprime_mp_loop:
    mov al, [ebx]           ; caractere da string
    mov ah, BRANCO_NO_PRETO ; cor do caractere

    cmp al, 0 ; fim da string?
    je imprime_mp_fim

    mov [edx], ax ; grava caractere + cor na memória de vídeo

    add ebx, 1 ; próximo caractere da string
    add edx, 2 ; próxima posição da tela (2 bytes por caractere)

    jmp imprime_mp_loop

imprime_mp_fim:
    popa
    ret

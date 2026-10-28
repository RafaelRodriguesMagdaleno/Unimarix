; posição em que o boot sector será colocado na memória
; o assembler assim adaptará os endereços internos do programa automaticamente

[org 0x7c00]

mov bx, mensagem1
call imprime

mov bx, mensagem2
call imprime

jmp sector

include "../Imprime_Asm/imprime.asm"

mensagem1: db "Bem-vindo(a) ao Unimarix 0.1", 0
mensagem2: db "Sistema Operacional da Computação 6A", 0

times 510-(S-SS) db 0
dw 0xaa55
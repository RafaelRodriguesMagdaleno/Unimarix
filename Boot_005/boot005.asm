; posição em que o boot sector será colocado na memória
; o assembler assim adaptará os endereços internos do programa automaticamente

[org 0x7c00]

mov bx, mensagem1
call imprime

mov bx, mensagem2
call imprime

mov bx, mensagem3
call imprime



jmp $

%include "../Imprime_Asm/imprime.asm"
%include "../Imprime_Hexa_Asm/imprime_hexa.asm"

mensagem1: db "Bem-vindo(a) ao Unimarix 0.1", 0
mensagem2: db "Sistema Operacional da Computação 6A", 0
mensagem3: db "Carregando o Kernel do Sistema...", 0

times 510-($-$$) db 0
dw 0xaa55
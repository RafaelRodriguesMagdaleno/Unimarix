; primeira versão do boot sector que vai para 32 bits
[org 0x7c00]
mov bp, 0x9000 ; definição do endereço da base da pilha
mov sp, bp ; definição do topo, tendeo posição inicial igual ao inicio

; ainda em 16 bits, vamos imprimir algo usando a BIOS
mov bx, MENSAGEM_EM_MODO_REAL
call imprime


; chamamos agora a rotina para mudar para 32 bits (modo32.asm)
call mudar_para_modo_protegido

jmp $ ; loop porque ainda não podemos carregar o kernel

; inclusão de rotinas em outros arquivos
%include "imprime.asm"
%include "gdt32.asm"
%include "imprime32.asm"
%include "modo32.asm"

[bits 32]
INICIAR_MP:
    mov ebx, MENSAGEM_EM_MODO_PROTEGIDO
    call imprime_mp
    jmp $

MENSAGEM_EM_MODO_REAL db "mensagem em modo real (16b)", 0
MENSAGEM_EM_MODO_PROTEGIDO db "mensagem em modo protegido (32b)", 0

times 510-($-$$) db 0
dw 0xaa55
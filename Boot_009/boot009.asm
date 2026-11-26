; Boot sector do Sistema Operacional UNimarIX 0.0.0.0.1
[org 0x7c00]

; constante com o endereço da posição onde o kernel será
; colocado na memória
ENDERECO_KERNEL equ 0x1000 

; salvamos o identificador do dispositivo de inicialização
; na memória
mov [DRIVE_BOOT], dl 
; preparamos a pilha do setor de boot
mov bp, 0x9000 ; a base da pilha ficará no endereço 0x9000
mov sp, bp ; a pilha começa com seu topo apontando para a sua base

; começamos em modo real 16 bits
mov bx, MENSAGEM_REAL_MODE
call imprime
call imprime_quebra

call carregar_kernel ; função definida mais abaixo
call mudar_para_modo_protegido ; função no arquivo modo32.asm
jmp $

; incluimos os demais arquivos necessários
%include "../Imprime_Asm/imprime.asm"
%include "../Imprime_Hexa_Asm/imprime_hexa.asm"
%include "../Ler_Disco/ler_disco.asm"
%include "../Gdt32_Asm/gdt32.asm"
%include "../Imprime32_Asm/imprime32.asm"
%include "../Modo32_Asm/modo32.asm"

[bits 16]
carregar_kernel:
    ; leremos o kernel no disco usando a função ler_disco.asm
    mov bx, MENSAGEM_KERNEL
    call imprime
    call imprime_quebra

    ; coloca o kernel lido na posição correta da memória
    mov bx, ENDERECO_KERNEL
    mov dh, 17 ; quantidade de setores a serem lidos no disco
    mov dl, [DRIVE_BOOT]
    call lerDisco
    ret

[bits 32]
INICIAR_MP:
    ; mudança para 32 bits (modo protegido)
    mov ebx, MENSAGEM_PROTECTED
    call imprime_mp
    call ENDERECO_KERNEL ; passamos o controle ao kernel
    jmp $

DRIVE_BOOT db 0
MENSAGEM_REAL_MODE db "UNimarIX iniciado em 16 bits (modo real)",0
MENSAGEM_PROTECTED db "UNimarIX em 32 bits (modo protegido)",0
MENSAGEM_KERNEL db "Carregando o kernel na memoria...",0

; final do boot sector
times 510-($-$$) db 0
dw 0xaa55

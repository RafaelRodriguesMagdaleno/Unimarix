[org 0x7c00]

mov [BOOT_DRIVE], dl ; a BIOS entrega em DL a unidade de onde o boot sector foi carregado

mov bp, 0x8000 ; endereço base da pilha
mov sp, bp ; ponteiro do topo aponta para a base inicialmente

mov bx, 0x9000 ; endereço da memoria dos dados lidos
mov dh, 2 ; vamos ler dois setores
mov dl, [BOOT_DRIVE] ; lemos da mesma unidade do boot

call lerDisco

mov dx, [0x9000] ; começo dos dados do primeiro setor
call imprime_hexa
call imprime_quebra

mov dx, [0x9000 + 512] ; começo do segundo setor
call imprime_hexa
call imprime_quebra

jmp $

%include "../Imprime_Asm/imprime.asm"
%include "../Imprime_Hexa_Asm/imprime_hexa.asm"
%include "../Ler_Disco/ler_disco.asm"

BOOT_DRIVE: db 0

times 510-($-$$) db 0
dw 0xaa55

; setores extras gravados logo depois do boot sector, para o lerDisco ter o que ler
times 256 dw 0xdada ; setor 2
times 256 dw 0xface ; setor 3

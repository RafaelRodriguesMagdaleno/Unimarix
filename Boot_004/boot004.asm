mov ah, 0x0e

mov bp, 0x8000 ; endereço da base da pilha
mov sp, bp ; topo da pilha: no início do programa é igual à base (pilha vazia)

push 'A' ; empilhando valores
push 'B' ; o sp é decrementado automaticamente a cada push
push 'C'

; começando a "desempilhar"
pop bx ; colocando o valor desempilhado em bx
mov al, bl ; copiamos os 8 bits baixos de bx (bl) em al

int 0x10

pop bx ;
mov al, bl ;

int 0x10

pop bx ;
mov al, bl ;

int 0x10

jmp $

times 510-($-$$) db 0
dw 0xaa55

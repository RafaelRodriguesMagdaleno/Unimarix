mov ah, 0x0e

mov bp, 0x8000 ; endereço onde a pilha começa
mov sp, bp ; endereço onde a pilha termina, é o mesmo valor de onde começa no inicio do programa

push 'A' ; empilhando valores
push 'B' ; o sp é empilhado automaticente
push 'C'

; começando a "desempilhar"
pop bx ; colocando o valor desempilhado em bx
mov al, bl ; copiamos os primeiros 0 bits de bx em al

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
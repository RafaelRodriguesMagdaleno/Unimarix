mov ah, 0x0e ; valor hexa do serviço 14 da bios (imprime caracteres)
mov al, 'U' ; código ASCII da letra colocado no registrador
int 0x10 ; Interrupção 10 hexa chama os serviços de video da bios
mov al, 'n'
int 0x10
mov al, 'i'
int 0x10
mov al, 'm'
int 0x10
mov al, 'a'
int 0x10
mov al, 'r'
int 0x10
mov al, 'i'
int 0x10
mov al, 'x'
int 0x10
mov al, ' '
int 0x10
mov al, 'v'
int 0x10
mov al, '0'
int 0x10
mov al, '.'
int 0x10
mov al, '1'
int 0x10

jmp $ ; outra forma de criar um loop infinito em assembly
times 510-($-$$) db 0 ; preenche o resto do arquivo com 0 até totalizar 512b
dw 0xaa55 ; armazena o número mágico no final do setor (define word)
; um boot sect que escreve :D
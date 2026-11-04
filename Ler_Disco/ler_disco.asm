 função para a leitura de N setores no HD/SSD

; A quantidade de setores a serem lidos deverá ser colocada 
; antes da chamada no registrador DH 
; (8 bits mais significativos de DX)

; O código da unidade a ser lida deve também já estar no DL 
; (8 bits menos significativos do DX)

; Ao término da função os dados lidos ficarão no endereço de memória
; apontado pelos registradores ES:BX

lerDisco:
    pusha
    push dx
    mov ah, 0x02 ; função de leitura de disco da bios

    ; essa função procura em al a qntd de setores a ler
    mov al, dh

    ; número do setor a ser lido (0x01 é o boot sector)
    mov cl, 0x02
    mov ch, 0x00 ; número do cilindro (HD)
    ; em DL colocamos o código (id) da unidade, sendo:
    ;   0x00 A:, 0x01 B:, 0x80 C:, 0x81 D:

    mov dl, 0x80
    mov dh, 0x00
    int 0x13 ; interrupção 13 hexa: serviços de disco da BIOS
    ; se houve erro, o carry but em FLAGS será setado para 1

    jc erro_disco ; pula para o tratamento de erro

    pop dx ; desempilha dx
    cmp al, ah ; comparar se foi lida a qntd de setores desejada
    jne erro_setor ; JNE, se não for igual, pula para o tratamento
    popa ; se não houver erro, desempilha e encerra
    ret

erro_disco:
    mov bx; Mensagem de erro disco
    call imprime
    call imprime_quebra
    mov  dh, ah ; Ah contem o codigo de erro
    call imprime_hexa ; imprime o codigo de erro na tela
    jmp loop disco

erro_setor:
    mov bx ; Mensagem Erro setor
    call imprime

loop disco:
    jmp $

MENSAGEM_ERRO_DISCO db "Erro de leitura"; 0
MENSAGEM_ERRO_SETOR: db "Qtd incorreta de setores lidos", 0
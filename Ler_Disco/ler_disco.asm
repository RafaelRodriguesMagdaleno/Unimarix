; função para a leitura de N setores no HD/SSD

; A quantidade de setores a serem lidos deverá ser colocada
; antes da chamada no registrador DH
; (8 bits mais significativos de DX)

; O código da unidade a ser lida deve também já estar no DL
; (8 bits menos significativos do DX)

; Ao término da função os dados lidos ficarão no endereço de memória
; apontado pelos registradores ES:BX

lerDisco:
    pusha
    push dx ; guarda DH (qtd pedida) para comparar depois
    mov ah, 0x02 ; função de leitura de disco da bios

    ; essa função procura em al a qntd de setores a ler
    mov al, dh

    ; número do setor a ser lido (0x01 é o boot sector)
    mov cl, 0x02
    mov ch, 0x00 ; número do cilindro (HD)
    mov dh, 0x00 ; número da cabeça
    ; em DL já está o código (id) da unidade, sendo:
    ;   0x00 A:, 0x01 B:, 0x80 C:, 0x81 D:

    int 0x13 ; interrupção 13 hexa: serviços de disco da BIOS
    ; se houve erro, o carry bit em FLAGS será setado para 1

    jc erro_disco ; pula para o tratamento de erro

    pop dx ; desempilha dx (DH volta a ter a qntd pedida)
    cmp al, dh ; AL = qntd lida, DH = qntd pedida
    jne erro_setor ; JNE, se não for igual, pula para o tratamento
    popa ; se não houver erro, desempilha e encerra
    ret

erro_disco:
    mov bx, MENSAGEM_ERRO_DISCO
    call imprime
    call imprime_quebra
    mov dh, ah ; AH contem o codigo de erro
    call imprime_hexa ; imprime o codigo de erro na tela
    jmp loop_disco

erro_setor:
    mov bx, MENSAGEM_ERRO_SETOR
    call imprime

loop_disco:
    jmp $

MENSAGEM_ERRO_DISCO: db "Erro de leitura", 0
MENSAGEM_ERRO_SETOR: db "Qtd incorreta de setores lidos", 0
MENSAGEM_ERRO_SETOR: db "Qtd incorreta de setores lidos", 0

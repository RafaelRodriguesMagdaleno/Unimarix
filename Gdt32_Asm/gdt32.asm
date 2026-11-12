; GDT (Global Descriptor Table): tabela que o processador consulta em
; modo protegido para saber onde começa, até onde vai e quais as
; permissões de cada segmento de memória.

; Usamos o modelo "flat" (plano): um segmento de código e um de dados,
; ambos começando em 0x0 e cobrindo os 4 GB, sobrepostos.

gdt_inicio:

gdt_nulo: ; o primeiro descritor é obrigatoriamente nulo (8 bytes zerados)
    dd 0x0
    dd 0x0

gdt_codigo: ; descritor do segmento de código
    dw 0xffff    ; limite (bits 0-15)
    dw 0x0       ; base (bits 0-15)
    db 0x0       ; base (bits 16-23)
    db 10011010b ; presente=1, privilégio=00, tipo=1, código=1, conforming=0, leitura=1, acessado=0
    db 11001111b ; granularidade=1 (4 KB), 32 bits=1, 0, 0, limite (bits 16-19)
    db 0x0       ; base (bits 24-31)

gdt_dados: ; descritor do segmento de dados, igual ao de código, menos o tipo
    dw 0xffff    ; limite (bits 0-15)
    dw 0x0       ; base (bits 0-15)
    db 0x0       ; base (bits 16-23)
    db 10010010b ; presente=1, privilégio=00, tipo=1, código=0, expand down=0, escrita=1, acessado=0
    db 11001111b ; granularidade=1 (4 KB), 32 bits=1, 0, 0, limite (bits 16-19)
    db 0x0       ; base (bits 24-31)

gdt_fim: ; serve só para o assembler calcular o tamanho da GDT

; descritor da GDT: é o que a instrução lgdt recebe
descritor_gdt:
    dw gdt_fim - gdt_inicio - 1 ; tamanho da GDT menos 1
    dd gdt_inicio               ; endereço onde a GDT começa

; deslocamento de cada descritor dentro da GDT. Em modo protegido,
; é esse valor que vai nos registradores de segmento (CS, DS, SS...)
SEG_CODIGO equ gdt_codigo - gdt_inicio ; 0x08
SEG_DADOS equ gdt_dados - gdt_inicio   ; 0x10

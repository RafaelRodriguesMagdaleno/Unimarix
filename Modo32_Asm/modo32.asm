; troca do modo real (16 bits) para o modo protegido (32 bits)

[bits 16]
mudar_para_modo_protegido:
    cli ; desliga as interrupções: a tabela de interrupções da BIOS
        ; é de 16 bits e não funciona mais em modo protegido

    lgdt [descritor_gdt] ; carrega a GDT (gdt32.asm)

    mov eax, cr0 ; o bit 0 do registrador de controle CR0 liga o modo protegido
    or eax, 0x1
    mov cr0, eax

    ; salto "longo" para o segmento de código da GDT. Isso troca o CS
    ; e esvazia a fila de instruções que o processador já tinha lido
    ; ainda em 16 bits
    jmp SEG_CODIGO:iniciar_modo_protegido

[bits 32]
iniciar_modo_protegido:
    ; os registradores de segmento ainda têm valores do modo real:
    ; todos passam a apontar para o segmento de dados da GDT
    mov ax, SEG_DADOS
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000 ; nova pilha, agora com registradores de 32 bits
    mov esp, ebp

    call INICIAR_MP ; volta para o boot sector, já em 32 bits

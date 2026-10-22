loop:
    jmp loop ; loop infinito em assembly

times 510-($-$$) db 0 ; preenche o resto do arquivo com 0
dw 0xAA55 ; armazena a word no fim do arquivo indicando um boot sector
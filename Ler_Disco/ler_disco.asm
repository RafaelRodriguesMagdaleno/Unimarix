;função para leitura de n setores no hd/ssd
;A quantidade de setores a serem lidos devera ser colocada antes da chamada da rotinas
;No registrado dh (8 bits mais significativos do DX, o código da unidade a ser lido deve também ja estar no dç 98 bits menos  signt do DX)
;Ao termino da função os dados lidos ficarão no endereço de memoria apontado pelos registradores ES: ex

ler disco:
    pusha
    p
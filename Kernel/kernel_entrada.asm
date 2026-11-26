[bits 32]
[extern main] ; define o nome do ponto de chamada no código do kernel
call main ; chama função main() dentro do binário do kernel
jmp $ ; apenas para garantir que se não conseguir chamar o kernel
      ; o programa vai "travar"
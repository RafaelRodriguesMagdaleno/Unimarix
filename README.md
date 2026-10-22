# Unimarix

Estudo de desenvolvimento de sistemas operacionais em **Assembly x86 (modo real, 16 bits)**, começando pelo setor de boot. Projeto acadêmico do curso de Ciência da Computação (UNIMAR), feito no Ubuntu Linux com NASM e QEMU.

> **Estado atual:** fase inicial. O projeto ainda não é um sistema operacional: hoje ele tem uma sequência de *boot sectors* de 512 bytes que a BIOS carrega e executa. Cada pasta `Boot_00X` é uma etapa do estudo.

---

## Sumário

- [Etapas](#etapas)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Requisitos](#requisitos)
- [Como compilar e executar](#como-compilar-e-executar)
- [Como funciona um boot sector](#como-funciona-um-boot-sector)
- [A pilha (etapa 004)](#a-pilha-etapa-004)
- [Limitações conhecidas](#limitações-conhecidas)
- [Licença](#licença)

---

## Etapas

| Etapa | Arquivo | O que faz | Situação |
|-------|---------|-----------|----------|
| 001 | `Boot_001/boot001.asm` | Boot sector mínimo: um loop infinito (`jmp loop`), preenchimento com zeros e assinatura `0xAA55`. A BIOS reconhece o disco como inicializável e a máquina fica parada. | Concluída |
| 002 | `Boot_002/boot002.asm` | Escreve **`Unimarix v0.1`** na tela, um caractere por vez, usando o serviço de teletipo da BIOS (`int 0x10`, `AH = 0x0E`). | Concluída |
| 003 | `Boot_003/boot003.asm` | Início do estudo de endereçamento de memória: define `[org 0x7c00]` e um dado rotulado (`segredo: db "A"`). As linhas que leem e imprimem esse dado ainda estão comentadas. | Em andamento |
| 004 | `Boot_004/boot004.asm` | Uso da pilha: posiciona `BP`/`SP` em `0x8000`, empilha `'A'`, `'B'` e `'C'` com `push` e depois desempilha com `pop`, imprimindo cada valor. Na tela aparece **`CBA`**, a ordem inversa da que foi empilhada. | Concluída |

## Estrutura do repositório

```
Unimarix/
├── Boot_001/
│   ├── boot001.asm    # código-fonte
│   └── boot001.bin    # imagem de 512 bytes gerada pelo NASM
├── Boot_002/
│   ├── boot002.asm
│   └── boot002.bin
├── Boot_003/
│   ├── boot003.asm
│   └── boot003.bin
├── Boot_004/
│   └── boot004.asm    # o .bin desta etapa não está versionado
├── README.md
└── SECURITY.md        # texto da licença MIT
```

Os arquivos `.bin` versionados (etapas 001 a 003) são idênticos, byte a byte, aos gerados a partir dos `.asm` com o comando da seção abaixo. O da etapa 004 precisa ser gerado localmente.

## Requisitos

- Linux (o projeto é desenvolvido no Ubuntu)
- [NASM](https://www.nasm.us/), para montar o código Assembly
- [QEMU](https://www.qemu.org/), para emular um PC x86 e dar boot na imagem

No Ubuntu:

```bash
sudo apt install nasm qemu-system-x86
```

Testado com NASM 2.16.01 e QEMU 8.2.2.

## Como compilar e executar

Na raiz do repositório, para a etapa 002 (as outras seguem o mesmo padrão):

```bash
# 1. Montar o código em binário puro (sem cabeçalho de executável)
nasm -f bin Boot_002/boot002.asm -o Boot_002/boot002.bin

# 2. Dar boot no binário como se fosse um disco
qemu-system-x86_64 -drive format=raw,file=Boot_002/boot002.bin
```

Resultado esperado da etapa 002: depois das mensagens da BIOS e de `Booting from Hard Disk...`, aparece `Unimarix v0.1` e o sistema fica parado. Para sair, feche a janela do QEMU.

> O `-f bin` é obrigatório: a BIOS executa o setor direto como código de máquina, então o arquivo não pode ter nenhum formato de executável (ELF etc.) em volta.

## Como funciona um boot sector

Quando o PC liga, a BIOS lê o **primeiro setor (512 bytes)** do disco e verifica se os dois últimos bytes são `0x55 0xAA`. Se forem, ela copia o setor para o endereço de memória `0x7C00` e passa a execução para ele, em modo real de 16 bits.

Por isso todos os arquivos terminam com:

```nasm
times 510-($-$$) db 0   ; completa com zeros até o byte 510
dw 0xaa55               ; assinatura de boot nos bytes 511 e 512
```

- `$` é o endereço da linha atual e `$$` o início da seção; `510-($-$$)` é quantos bytes faltam para chegar a 510.
- `dw 0xaa55` grava os bytes `55 AA`, já que o x86 é *little-endian*.
- `jmp $` (ou `loop: jmp loop`) mantém a CPU presa num laço, já que não há sistema para onde "voltar".

Para escrever na tela, a etapa 002 usa a interrupção de vídeo da BIOS:

```nasm
mov ah, 0x0e    ; serviço 0x0E: escreve o caractere em AL e avança o cursor
mov al, 'U'     ; caractere a ser impresso
int 0x10        ; chama os serviços de vídeo da BIOS
```

`AH` é definido uma vez só, porque na prática as BIOS não alteram esse registrador nesse serviço; depois basta trocar `AL` e chamar a interrupção de novo.

A diretiva `[org 0x7c00]` da etapa 003 informa ao NASM em que endereço o código vai rodar, para que ele calcule direito o endereço de rótulos como `segredo`.

## A pilha (etapa 004)

A pilha é uma área de memória em que o último valor guardado é o primeiro a sair (LIFO). No x86 ela é controlada por dois registradores:

- `SP` (*stack pointer*) aponta para o topo da pilha. A cada `push` o processador **diminui** `SP` em 2 e grava o valor; a cada `pop` ele lê o valor e **aumenta** `SP` em 2. Ou seja, a pilha cresce para endereços menores.
- `BP` (*base pointer*) guarda a base da pilha. Aqui ele só serve de referência para o valor inicial de `SP`.

```nasm
mov bp, 0x8000   ; base da pilha
mov sp, bp       ; pilha vazia: topo = base

push 'A'         ; em modo 16 bits, cada push grava uma word (2 bytes)
push 'B'
push 'C'

pop bx           ; sai o último empilhado: 'C'
mov al, bl       ; BL é o byte baixo de BX, onde está o caractere
int 0x10         ; imprime 'C'; depois o mesmo para 'B' e 'A'
```

O endereço `0x8000` fica acima do boot sector (`0x7C00` a `0x7DFF`). Como a pilha cresce para baixo, sobra um espaço livre entre os dois e ela não sobrescreve o código.

## Limitações conhecidas

- **Etapa 003 incompleta:** do jeito que está, ela chama `int 0x10` sem definir `AL`, então imprime o valor que tiver sobrado nesse registrador. No QEMU 8.2.2 (SeaBIOS 1.16.3) aparece um `U`, mas isso depende da BIOS e não deve ser tratado como resultado esperado.
- **Registradores de segmento não inicializados:** nenhuma etapa define `DS`, `ES` ou `SS`. A etapa 004 ajusta `SP`, mas o endereço real da pilha é `SS:SP`, e `SS` continua com o valor deixado pela BIOS. No QEMU isso funciona, mas o mais seguro é zerar `SS` (e `DS`, antes de ler dados como `mov al, [segredo]`) no início do código.
- **Só testado em emulador:** as imagens foram testadas no QEMU, não em hardware real.
- **Sem script de build:** cada etapa é montada à mão com o `nasm`.

## Licença

Distribuído sob a licença MIT. O texto completo está em [`SECURITY.md`](SECURITY.md).

---

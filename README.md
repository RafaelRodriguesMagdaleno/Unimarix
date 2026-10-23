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
- [Lendo dados da memória (etapa 003)](#lendo-dados-da-memória-etapa-003)
- [A pilha (etapa 004)](#a-pilha-etapa-004)
- [Limitações conhecidas](#limitações-conhecidas)
- [Licença](#licença)

---

## Etapas

| Etapa | Arquivo | O que faz | Situação |
|-------|---------|-----------|----------|
| 001 | `Boot_001/boot001.asm` | Boot sector mínimo: um loop infinito (`jmp loop`), preenchimento com zeros e assinatura `0xAA55`. A BIOS reconhece o disco como inicializável e a máquina fica parada. | Concluída |
| 002 | `Boot_002/boot002.asm` | Escreve **`Unimarix v0.1`** na tela, um caractere por vez, usando o serviço de teletipo da BIOS (`int 0x10`, `AH = 0x0E`). | Concluída |
| 003 | `Boot_003/boot003.asm` | Leitura de dados da memória: com `[org 0x7c00]`, lê o byte do rótulo `segredo` (`db "A"`) com `mov al, [segredo]` e o imprime. Na tela aparece **`UA`**: o `A` vem do `segredo`, e o `U` vem de uma chamada a `int 0x10` feita antes de definir `AL` (ver [Limitações conhecidas](#limitações-conhecidas)). | Concluída, com ressalva |
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
│   ├── boot004.asm
│   └── boot004.bin
├── README.md
└── SECURITY.md        # texto da licença MIT
```

Cada `.bin` é gerado a partir do `.asm` da mesma pasta com o comando da seção abaixo. Sempre que um `.asm` mudar, gere o `.bin` de novo antes de fazer o commit, para os dois não ficarem dessincronizados.

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

## Lendo dados da memória (etapa 003)

Um rótulo como `segredo` é só um nome para um endereço. O NASM calcula esse endereço contando a partir do início do arquivo, mas a BIOS carrega o setor em `0x7C00`, não em `0`. A diretiva `[org 0x7c00]` avisa o NASM disso, para que ele some `0x7C00` ao endereço de cada rótulo.

```nasm
[org 0x7c00]        ; o código vai rodar a partir de 0x7C00

mov al, [segredo]   ; colchetes = "o conteúdo do endereço", não o endereço
int 0x10            ; imprime 'A'

segredo: db "A"     ; um byte com o código ASCII de 'A'
```

Sem o `[org 0x7c00]`, o `mov al, [segredo]` leria um endereço perto de `0x0000`, fora do boot sector, e imprimiria um caractere qualquer.

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

- **Chamada sobrando na etapa 003:** a terceira linha do código (`int 0x10`) roda antes de qualquer `mov al`, então imprime o valor que tiver sobrado em `AL`. No QEMU 8.2.2 (SeaBIOS 1.16.3) esse valor sai como `U`, por isso a tela mostra `UA` em vez de só `A`. Em outra BIOS pode sair outro caractere. Para corrigir, basta apagar essa linha.
- **Registradores de segmento não inicializados:** nenhuma etapa define `DS`, `ES` ou `SS`. Na etapa 003, o endereço real lido por `mov al, [segredo]` é `DS:segredo`. Na etapa 004, o endereço real da pilha é `SS:SP`. Os dois funcionam no QEMU porque a BIOS deixa `DS` e `SS` com valores que servem, mas isso não é garantido. O mais seguro é zerar `DS` e `SS` no início do código.
- **Só testado em emulador:** as imagens foram testadas no QEMU, não em hardware real.
- **Sem script de build:** cada etapa é montada à mão com o `nasm`.

## Licença

Distribuído sob a licença MIT. O texto completo está em [`SECURITY.md`](SECURITY.md).

---

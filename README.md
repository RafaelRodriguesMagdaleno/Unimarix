# Unimarix

Estudo de desenvolvimento de sistemas operacionais em **Assembly x86**, começando pelo setor de boot em modo real (16 bits) e partindo para o modo protegido (32 bits). Projeto acadêmico do curso de Ciência da Computação (UNIMAR), desenvolvido no Ubuntu Linux com NASM e QEMU. As mesmas ferramentas existem para Windows, e o código é o mesmo nos dois.

> **Estado atual:** fase inicial. O projeto ainda não é um sistema operacional: hoje ele tem uma sequência de *boot sectors* de 512 bytes que a BIOS carrega e executa, mais as primeiras rotinas reutilizáveis (impressão de texto, impressão de números em hexadecimal e leitura de setores do disco). Na etapa 008, o boot sector já sai do modo real e entra no modo protegido de 32 bits. Cada pasta `Boot_00X` é uma etapa do estudo.

---

## Sumário

- [Etapas](#etapas)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Linux ou Windows: o que muda](#linux-ou-windows-o-que-muda)
- [Como rodar no Linux](#como-rodar-no-linux)
- [Como rodar no Windows](#como-rodar-no-windows)
- [Como funciona um boot sector](#como-funciona-um-boot-sector)
- [Lendo dados da memória (etapa 003)](#lendo-dados-da-memória-etapa-003)
- [A pilha (etapa 004)](#a-pilha-etapa-004)
- [Rotinas reutilizáveis (etapa 005)](#rotinas-reutilizáveis-etapa-005)
- [Lendo setores do disco (etapa 007)](#lendo-setores-do-disco-etapa-007)
- [Modo protegido de 32 bits (etapa 008)](#modo-protegido-de-32-bits-etapa-008)
- [Limitações conhecidas](#limitações-conhecidas)
- [Licença](#licença)

---

## Etapas

| Etapa | Arquivo | O que faz | Situação |
|-------|---------|-----------|----------|
| 001 | `Boot_001/boot001.asm` | Boot sector mínimo: um loop infinito (`jmp loop`), preenchimento com zeros e assinatura `0xAA55`. A BIOS reconhece o disco como inicializável e a máquina fica parada. | Concluída |
| 002 | `Boot_002/boot002.asm` | Escreve **`Unimarix v0.1`** na tela, um caractere por vez, usando o serviço de teletipo da BIOS (`int 0x10`, `AH = 0x0E`). | Concluída |
| 003 | `Boot_003/boot003.asm` | Leitura de dados da memória: com `[org 0x7c00]`, lê o byte do rótulo `segredo` (`db "A"`) com `mov al, [segredo]` e o imprime. Na tela aparece **`A`**. | Concluída |
| 004 | `Boot_004/boot004.asm` | Uso da pilha: posiciona `BP`/`SP` em `0x8000`, empilha `'A'`, `'B'` e `'C'` com `push` e depois desempilha com `pop`, imprimindo cada valor. Na tela aparece **`CBA`**, a ordem inversa da que foi empilhada. | Concluída |
| 005 | `Boot_005/boot005.asm` | Primeiras "funções": inclui as rotinas `imprime` e `imprime_hexa` com `%include`, escreve três mensagens com `call imprime`, uma por linha (`call imprime_quebra`), e mostra o valor `0xCAFE` com `call imprime_hexa`. | Concluída |
| 007 | `Boot_007/boot007.asm` | Leitura de disco: guarda a unidade de boot que a BIOS entrega em `DL`, usa a rotina `lerDisco` para carregar os setores 2 e 3 dessa unidade no endereço `0x9000` e imprime, em hexadecimal, a primeira word de cada setor. Os dois setores são gravados no próprio `.asm`, logo depois da assinatura. Na tela aparecem **`0xDADA`** e **`0xFACE`**, em linhas separadas. | Concluída |
| 008 | `Boot_008/boot008.asm` | Passagem para o modo protegido (32 bits): imprime uma mensagem ainda em modo real com `imprime` (BIOS), chama `mudar_para_modo_protegido` e, já em 32 bits, imprime uma segunda mensagem com `imprime_mp`, escrevendo direto na memória de vídeo. Na tela aparece `mensagem em modo real (16b)` abaixo de `Booting from Hard Disk...` e `mensagem em modo protegido (32b)` no canto superior esquerdo, por cima do texto da BIOS. | Concluída |

Não há pasta `Boot_006` no repositório: a numeração passa da etapa 005 direto para a 007.

## Estrutura do repositório

```
Unimarix/
├── Boot_001/
│   └── boot001.asm
├── Boot_002/
│   └── boot002.asm
├── Boot_003/
│   └── boot003.asm
├── Boot_004/
│   └── boot004.asm
├── Boot_005/
│   └── boot005.asm         # usa imprime e imprime_hexa via %include
├── Boot_007/
│   └── boot007.asm         # usa imprime, imprime_hexa e lerDisco via %include
├── Boot_008/
│   ├── boot008.asm         # entra no modo protegido; usa os três arquivos abaixo e imprime
│   ├── gdt32.asm           # tabela de segmentos (GDT)
│   ├── modo32.asm          # rotina mudar_para_modo_protegido
│   └── imprime32.asm       # rotina imprime_mp (impressão em 32 bits)
├── Imprime_Asm/
│   └── imprime.asm         # rotinas imprime e imprime_quebra
├── Imprime_Hexa_Asm/
│   └── imprime_hexa.asm    # rotina imprime_hexa (depende de imprime)
├── Ler_Disco/
│   └── ler_disco.asm       # rotina lerDisco (depende de imprime e imprime_hexa)
├── LICENSE                 # licença MIT
└── README.md
```

O repositório guarda só o código-fonte. Os `.bin` (imagens de disco: 1536 bytes na etapa 007 e 512 bytes nas outras) não são versionados: gere cada um localmente com os comandos das seções abaixo.

As pastas `Imprime_Asm`, `Imprime_Hexa_Asm` e `Ler_Disco` não são boot sectors: são trechos de código que não rodam sozinhos e servem para ser incluídos dentro de um boot sector. O mesmo vale para `gdt32.asm`, `modo32.asm` e `imprime32.asm`, que ficam dentro de `Boot_008` porque, por enquanto, só essa etapa os usa.

## Linux ou Windows: o que muda

**O código Assembly é o mesmo nos dois sistemas.** Um boot sector não roda "no Linux" nem "no Windows": ele roda direto no processador, antes de existir qualquer sistema operacional. Neste projeto, quem faz o papel do computador é o QEMU, que emula um PC x86 com BIOS. O sistema instalado na sua máquina só serve para duas coisas:

1. **Montar** o `.asm` em `.bin` com o NASM.
2. **Abrir** o QEMU apontando para esse `.bin`.

O `.bin` gerado é o mesmo, byte a byte, no Linux e no Windows. O que muda entre os dois é só a instalação das ferramentas e a forma de digitar os caminhos.

Ferramentas usadas:

- [NASM](https://www.nasm.us/), para montar o código Assembly
- [QEMU](https://www.qemu.org/), para emular um PC x86 e dar boot na imagem

> O `-f bin` usado nos comandos abaixo é obrigatório: a BIOS executa o setor direto como código de máquina, então o arquivo não pode ter nenhum formato de executável (ELF no Linux, PE/`.exe` no Windows) em volta.

## Como rodar no Linux

Testado no Ubuntu com NASM 2.16.01 e QEMU 8.2.2.

**1. Instalar as ferramentas:**

```bash
sudo apt install nasm qemu-system-x86
```

**2. Montar e executar**, na raiz do repositório. O exemplo usa a etapa 002, e as etapas 001 a 004 seguem o mesmo padrão:

```bash
# Montar o código em binário puro (sem cabeçalho de executável)
nasm -f bin Boot_002/boot002.asm -o Boot_002/boot002.bin

# Dar boot no binário como se fosse um disco
qemu-system-x86_64 -drive format=raw,file=Boot_002/boot002.bin
```

Resultado esperado da etapa 002: depois das mensagens da BIOS e de `Booting from Hard Disk...`, aparece `Unimarix v0.1` e o sistema fica parado. Para sair, feche a janela do QEMU.

**Etapas 005 em diante: monte de dentro da pasta da etapa.** Os `%include` usam caminhos relativos (`../Imprime_Asm/imprime.asm`), e o NASM resolve esses caminhos a partir da pasta onde o comando é executado. Rodando da raiz, ele dá o erro `unable to open include file`.

```bash
cd Boot_005
nasm -f bin boot005.asm -o boot005.bin
qemu-system-x86_64 -drive format=raw,file=boot005.bin
```

## Como rodar no Windows

> Os passos desta seção ainda não foram testados no Windows. Os comandos e o resultado esperado são os mesmos da seção do Linux.

Há dois caminhos: instalar as ferramentas direto no Windows (opção A) ou usar o Ubuntu dentro do Windows pelo WSL (opção B).

### Opção A: direto no Windows (PowerShell)

**1. Instalar as ferramentas** com o `winget`, o gerenciador de pacotes do Windows 10 e 11:

```powershell
winget install --id NASM.NASM -e
winget install --id SoftwareFreedomConservancy.QEMU -e
```

Se preferir instalar à mão, os instaladores estão em [nasm.us](https://www.nasm.us/) e [qemu.org/download](https://www.qemu.org/download/#windows).

**2. Conferir se os comandos são reconhecidos.** Feche e abra o PowerShell de novo e rode:

```powershell
nasm -v
qemu-system-x86_64 --version
```

Se algum der *"não é reconhecido como nome de cmdlet"*, a pasta do programa não está no `PATH`. Nesse caso:

- Abra **Editar as variáveis de ambiente do sistema** → **Variáveis de Ambiente** → em `Path`, clique em **Editar** → **Novo**.
- Adicione a pasta de instalação do QEMU (por padrão, `C:\Program Files\qemu`) e a pasta onde foi instalado o `nasm.exe`.
- Feche e abra o PowerShell de novo.

**3. Montar e executar**, na raiz do repositório:

```powershell
nasm -f bin Boot_002\boot002.asm -o Boot_002\boot002.bin
qemu-system-x86_64 -drive format=raw,file=Boot_002\boot002.bin
```

A única diferença em relação ao Linux é a barra invertida (`\`) nos caminhos. Da etapa 005 em diante, monte de dentro da pasta da etapa (exemplo com a 005):

```powershell
cd Boot_005
nasm -f bin boot005.asm -o boot005.bin
qemu-system-x86_64 -drive format=raw,file=boot005.bin
```

### Opção B: Ubuntu no Windows com WSL

O WSL roda um Ubuntu dentro do Windows. Com ele, os passos da seção [Como rodar no Linux](#como-rodar-no-linux) funcionam sem nenhuma mudança.

```powershell
wsl --install -d Ubuntu
```

Depois de reiniciar e criar o usuário do Ubuntu, abra o terminal do Ubuntu e siga a seção do Linux. Para a janela do QEMU aparecer, o WSL precisa ter suporte a aplicativos gráficos (WSLg), que já vem no Windows 11.

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

## Rotinas reutilizáveis (etapa 005)

Até a etapa 004, cada caractere era impresso com um `mov al` e um `int 0x10` escritos à mão. A etapa 005 separa esse trabalho em rotinas que ficam em arquivos próprios e são coladas no boot sector pelo NASM:

```nasm
%include "../Imprime_Asm/imprime.asm"
%include "../Imprime_Hexa_Asm/imprime_hexa.asm"
```

O `%include` copia o conteúdo do arquivo naquele ponto, na hora de montar. O resultado continua sendo um único `.bin` de 512 bytes. As rotinas ficam depois do `jmp $`, para a CPU nunca chegar nelas "por acaso", só via `call`.

### `call` e `ret`

`call imprime` empilha o endereço da instrução seguinte e salta para `imprime`. No final da rotina, `ret` desempilha esse endereço e volta para ele. É a mesma pilha da etapa 004, agora usada pelo próprio processador.

Cada rotina começa com `pusha` e termina com `popa`. Essas instruções guardam e restauram os registradores de uso geral (`AX`, `CX`, `DX`, `BX`, `SP`, `BP`, `SI`, `DI`), para que quem chamou a rotina encontre os registradores do jeito que deixou.

### `imprime` e `imprime_quebra` (`Imprime_Asm/imprime.asm`)

| Rotina | Entrada | O que faz |
|--------|---------|-----------|
| `imprime` | `BX` = endereço de uma string terminada em `0` | Lê um caractere por vez (`mov al, [bx]`), para quando encontra o `0` e imprime os outros com `int 0x10`. |
| `imprime_quebra` | nenhuma | Imprime `0x0A` (*line feed*, desce uma linha) e `0x0D` (*carriage return*, volta para o início da linha). |

As strings precisam terminar com o byte `0`, que marca onde elas acabam:

```nasm
mensagem1: db "Bem-vindo(a) ao Unimarix 0.1", 0
```

### `imprime_hexa` (`Imprime_Hexa_Asm/imprime_hexa.asm`)

Recebe um valor de 16 bits em `DX` e o imprime no formato `0x0000`. Ela depende de `imprime`, então o arquivo `imprime.asm` precisa ser incluído junto.

Cada dígito hexadecimal corresponde a 4 bits (um *nibble*). A rotina repete quatro vezes:

1. `and ax, 0x000f` isola os 4 bits mais à direita de `DX`.
2. Soma `0x30` para virar caractere ASCII: `0` a `9` viram `'0'` a `'9'` (`0x30` a `0x39`).
3. Se o resultado passou de `0x39`, soma mais `7` para pular até `'A'` a `'F'` (`0x41` a `0x46`).
4. Grava o caractere em `STRING_SAIDA`, começando pela última posição e indo para a esquerda.
5. `shr dx, 4` desloca `DX` 4 bits para a direita, descartando o dígito que acabou de ser convertido.

Exemplo com `DX = 0xCAFE`: os dígitos saem na ordem `E`, `F`, `A`, `C`, são gravados de trás para frente, e a string fica `"0xCAFE"`. No fim, a rotina chama `imprime` com `BX` apontando para essa string.

## Lendo setores do disco (etapa 007)

A BIOS só carrega o primeiro setor do disco (o boot sector), e 512 bytes acabam rápido. Para ir além, o próprio boot sector precisa pedir à BIOS que leia os próximos setores para a memória. É isso que a rotina `lerDisco` (`Ler_Disco/ler_disco.asm`) faz, com o serviço `0x02` da interrupção `0x13`.

### O que a BIOS espera em cada registrador

| Registrador | Valor em `lerDisco` | Significado |
|-------------|---------------------|-------------|
| `AH` | `0x02` | Serviço "ler setores" |
| `AL` | valor de `DH` na chamada | Quantos setores ler |
| `CH` | `0x00` | Cilindro 0 |
| `DH` | `0x00` | Cabeça 0 |
| `CL` | `0x02` | Setor inicial. A contagem começa em 1, e o setor 1 é o próprio boot sector, então a leitura começa logo depois dele |
| `DL` | definido por quem chama | Unidade: `0x00` é o primeiro disquete, `0x80` o primeiro disco rígido |
| `ES:BX` | definido por quem chama | Endereço da memória onde os dados lidos serão gravados |

Na etapa 007, quem chama coloca `BX = 0x9000` e `DH = 2`, ou seja, pede 2 setores (1024 bytes) gravados a partir de `0x9000`. Em `DL` vai a unidade de onde o boot sector foi carregado.

### De qual unidade ler

Quando a BIOS passa o controle para o boot sector, ela deixa em `DL` o número da unidade de onde ele foi carregado. A primeira instrução da etapa 007 guarda esse valor numa variável, antes que algum outro código mude `DL`:

```nasm
mov [BOOT_DRIVE], dl   ; guarda a unidade de boot
...
mov dl, [BOOT_DRIVE]   ; e usa na leitura
call lerDisco

BOOT_DRIVE: db 0       ; 1 byte reservado para a variável
```

Assim, a leitura funciona tanto no disco rígido (`0x80`, como no QEMU) quanto em outra unidade de boot, sem número fixo no código.

### Como a BIOS responde

- Se a leitura falhar, a BIOS liga o *carry flag* (`CF`) e coloca um código de erro em `AH`. A rotina testa isso com `jc erro_disco`.
- Se der certo, `AL` volta com a quantidade de setores que foram de fato lidos. A rotina compara esse número com o que foi pedido e, se for diferente, vai para `erro_setor`.

No caso de erro de leitura, a rotina imprime `"Erro de leitura"` e depois chama `imprime_hexa` com `DH` = código de erro. Como `DL` ainda tem o número da unidade, a tela mostra os dois juntos. Por exemplo, `0x0C80` significa código de erro `0x0C` na unidade `0x80`.

### Os setores lidos precisam existir na imagem

O `lerDisco` lê os setores 2 e 3 **do mesmo disco** de onde a BIOS carregou o boot sector. No QEMU, esse disco é o próprio arquivo `.bin`. Se o `.bin` tivesse só 512 bytes, os setores 2 e 3 não existiriam e a leitura falharia com `Erro de leitura` / `0x0C80`. Por isso o `boot007.asm` grava dois setores de dados depois da assinatura `0xAA55`:

```nasm
dw 0xaa55

times 256 dw 0xdada   ; setor 2: 256 words = 512 bytes
times 256 dw 0xface   ; setor 3
```

Assim, o `boot007.bin` fica com 1536 bytes (3 setores), e não 512 como nas etapas anteriores. A BIOS continua carregando só o primeiro setor, e os outros dois são lidos pelo `lerDisco`. A etapa imprime `0xDADA` e `0xFACE`, a primeira word de cada setor lido.

## Modo protegido de 32 bits (etapa 008)

Até a etapa 007, tudo roda em **modo real**: registradores de 16 bits, acesso a só 1 MB de memória e serviços da BIOS por interrupções (`int 0x10`, `int 0x13`). Os sistemas operacionais modernos rodam em **modo protegido**, com registradores de 32 bits (`EAX`, `EBX`...) e acesso a até 4 GB. A etapa 008 faz essa troca.

### A GDT (`gdt32.asm`)

Em modo protegido, os registradores de segmento (`CS`, `DS`, `SS`...) deixam de guardar um endereço. Eles passam a guardar a posição de um **descritor** numa tabela chamada GDT (*Global Descriptor Table*). Cada descritor diz onde o segmento começa, até onde vai e o que se pode fazer nele (executar, ler, escrever).

O Unimarix usa o modelo mais simples, o "plano" (*flat*). A tabela tem três descritores de 8 bytes:

| Descritor | Posição na GDT | Para quê |
|-----------|----------------|----------|
| nulo | `0x00` | Obrigatório pelo processador, todo zerado |
| código | `0x08` (`SEG_CODIGO`) | Base `0`, limite 4 GB, executável e legível |
| dados | `0x10` (`SEG_DADOS`) | Base `0`, limite 4 GB, legível e gravável |

Como os dois segmentos começam em `0` e cobrem a memória toda, um endereço em 32 bits é simplesmente o endereço físico. Logo depois da tabela vem o `descritor_gdt`, que guarda o tamanho e o endereço da GDT. É ele que a instrução `lgdt` recebe.

### A troca de modo (`modo32.asm`)

A rotina `mudar_para_modo_protegido` faz a troca em quatro passos:

```nasm
cli                    ; 1. desliga as interrupções (as da BIOS são de 16 bits)
lgdt [descritor_gdt]   ; 2. informa ao processador onde está a GDT

mov eax, cr0           ; 3. liga o bit 0 do registrador de controle CR0:
or eax, 0x1            ;    a partir daqui o processador está em modo protegido
mov cr0, eax

jmp SEG_CODIGO:iniciar_modo_protegido   ; 4. salto "longo"
```

O salto longo do passo 4 troca o `CS` para o segmento de código da GDT e descarta as instruções que o processador já tinha lido adiantado em modo de 16 bits. Do outro lado do salto, já em `[bits 32]`, a rotina aponta `DS`, `SS`, `ES`, `FS` e `GS` para o segmento de dados, cria uma pilha nova em `0x90000` e chama `INICIAR_MP`, de volta no `boot008.asm`.

### Imprimindo sem a BIOS (`imprime32.asm`)

Em modo protegido não há mais `int 0x10`. A rotina `imprime_mp` escreve direto na **memória de vídeo** do modo texto, que começa no endereço `0xB8000`. Cada posição da tela ocupa 2 bytes:

```
0xB8000: 'm'   0xB8001: 0x0F (cor: branco no preto)
0xB8002: 'e'   0xB8003: 0x0F
...
```

A rotina recebe a string em `EBX` e grava caractere e cor a partir de `0xB8000`, que é o canto superior esquerdo da tela. Por isso, no QEMU, a mensagem de 32 bits aparece **por cima da primeira linha** do texto da BIOS, enquanto a mensagem de 16 bits aparece mais abaixo, onde o cursor da BIOS estava.

## Limitações conhecidas

- **Caminhos dos `%include` dependem de onde o NASM é executado:** da etapa 005 em diante, monte de dentro da pasta da etapa (ver [Como rodar no Linux](#como-rodar-no-linux)).
- **Registradores de segmento não inicializados no modo real:** nenhuma etapa define `DS`, `ES` ou `SS` enquanto está em 16 bits. Nas etapas 003, 005, 007 e 008, os dados lidos da memória (`mov al, [segredo]`, `mov al, [bx]`, `mov dx, [0x9000]`) vêm de `DS`. Na etapa 007, os setores lidos do disco são gravados em `ES:BX`. Nas etapas 004, 005, 007 e 008, a pilha (usada por `push`, `pop`, `call` e `ret`) fica em `SS:SP`. Tudo funciona no QEMU porque a BIOS deixa `DS`, `ES` e `SS` com valores que servem, mas isso não é garantido. O mais seguro é zerar `DS`, `ES` e `SS` no início do código. A etapa 008 só define esses registradores depois de entrar em 32 bits.
- **Linha A20 não habilitada:** a etapa 008 entra no modo protegido sem habilitar a linha A20, que controla o acesso à memória acima de 1 MB. Por enquanto não faz diferença, porque todo o código e a pilha (`0x90000`) ficam abaixo de 1 MB. Isso vai importar quando o kernel precisar de memória acima desse limite.
- **Espaço:** dos 510 bytes disponíveis no boot sector, a etapa 005 ocupa 219, a 007 ocupa 221 e a 008 ocupa 223. Daqui em diante, o caminho para ter mais espaço é deixar no boot sector só o que for preciso para ler o resto do código do disco.
- **Só testado em emulador:** as imagens foram testadas no QEMU, não em hardware real.
- **Sem script de build:** cada etapa é montada à mão com o `nasm`.

## Licença

Distribuído sob a licença MIT. O texto completo está em [`LICENSE`](LICENSE).

---

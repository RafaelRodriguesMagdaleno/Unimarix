/*
	UNImariX 0.2 - Kernel mínimo com "protodriver" de vídeo
	
	Ver no arquivo COMANDOS.txt as instruções para compilação e execução
*/

#include "stdbool.h"
#include "stddef.h"
#include "stdint.h"

// valores para cores do texto e fundo
enum vga_color {
	VGA_COLOR_BLACK = 0,
	VGA_COLOR_BLUE = 1,
	VGA_COLOR_GREEN = 2,
	VGA_COLOR_CYAN = 3,
	VGA_COLOR_RED = 4,
	VGA_COLOR_MAGENTA = 5,
	VGA_COLOR_BROWN = 6,
	VGA_COLOR_LIGHT_GREY = 7,
	VGA_COLOR_DARK_GREY = 8,
	VGA_COLOR_LIGHT_BLUE = 9,
	VGA_COLOR_LIGHT_GREEN = 10,
	VGA_COLOR_LIGHT_CYAN = 11,
	VGA_COLOR_LIGHT_RED = 12,
	VGA_COLOR_LIGHT_MAGENTA = 13,
	VGA_COLOR_LIGHT_BROWN = 14,
	VGA_COLOR_WHITE = 15,
};

/* 
	parâmetros:
		fg (foreground): cor para o texto
		bg (background): cor para o fundo
	retorno:
		inteiro de 1 byte sem sinal contendo os códigos para cor do texto e do fundo
*/
static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg) 
{
	return fg | bg << 4;
}

/* 
	parâmetros:
		uc: caractere a ser impresso
		color: inteiro de 1 byte sem sinal contendo o código da cor do texto e do fundo
		       (criado com a função vga_entry_color)
	retorno:
		inteiro de 1 byte sem sinal contendo os códigos para cor do texto e do fundo
*/

static inline uint16_t vga_entry(unsigned char uc, uint8_t color) 
{
	return (uint16_t) uc | (uint16_t) color << 8;
}

/*
	parâmetro:
		str: ponteiro para uma string
	retorno:
		inteiro com o tamanho da string
*/
size_t strlen(const char* str) 
{
	size_t len = 0;
	while (str[len])
		len++;
	return len;
}


#define VGA_WIDTH   80			// constante com a quantidade de colunas em uma linha
#define VGA_HEIGHT  25			// constante com a quantidade de linhas na tela
#define VGA_MEMORY  0xB8000 	// constante com o endereço da memória do buffer de video

size_t terminal_row;			// armazena a "linha de impressão atual"
size_t terminal_column;			// armazena a "coluna de impressão atual"
uint8_t terminal_color;			// armazena a "atual" 

// ponteiro para a posição da memória do buffer de vídeo
uint16_t* terminal_buffer = (uint16_t*)VGA_MEMORY;

// "inicializa" o terminal (basicamente, limpa a tela)
void terminal_initialize(void) 
{
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
	
	for (size_t y = 0; y < VGA_HEIGHT; y++) {
		for (size_t x = 0; x < VGA_WIDTH; x++) {
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = vga_entry(' ', terminal_color);
		}
	}
}

/* define a cor do texto/fundo padrão ("atual")
 	
 	parâmetro:
 		color: inteiro de 1 byte sem sinal contendo o código da cor do texto e do fundo
		       (criado com a função vga_entry_color)
*/
void terminal_setcolor(uint8_t color) 
{
	terminal_color = color;
}

// imprime um caractere (c) na coordenada de tela passada (x e y)
void terminal_putentryat(char c, uint8_t color, size_t x, size_t y) 
{
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = vga_entry(c, color);
}

// imprime um caractere (c) na linha e coluna atual 
// variáveis globais terminal_row e terminal_column, respectivamente)
void terminal_putchar(char c) 
{
	terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
	if (++terminal_column == VGA_WIDTH) {
		terminal_column = 0;
		if (++terminal_row == VGA_HEIGHT)
			terminal_row = 0;
	}
}


// imprime a string apontada pelo parâmetro "data" na linha e coluna atual 
// (variáveis globais terminal_row e terminal_column, respectivamente).
// é necessário passar o tamanho da string no parâmetro size
void terminal_write(const char* data, size_t size) 
{
	for (size_t i = 0; i < size; i++)
		terminal_putchar(data[i]);
}

/*
 * INCLUA NESTE PONTO AS FUNÇÕES IMPLEMENTADAS NO SEU TRABALHO
 *
 */

// imprime a string apontada pelo parâmetro "data" na linha e coluna atual 
// (variáveis globais terminal_row e terminal_column, respectivamente).
// quando encontra um '\n', volta para a coluna 0 e desce uma linha.
void terminal_writestring(const char* data)
{
	for (size_t i = 0; data[i] != '\0'; i++) {
		if (data[i] == '\n') {
			terminal_column = 0;
			if (++terminal_row == VGA_HEIGHT)
				terminal_row = 0;
		} else {
			terminal_putchar(data[i]);
		}
	}
}

// imprime a string apontada por "text" nas coordenadas x (coluna) e y (linha),
// usando a cor especificada em "color" (criada com a função vga_entry_color).
void terminal_writestring_location(size_t x, size_t y, const char* text, uint8_t color)
{
	for (size_t i = 0; text[i] != '\0'; i++)
		terminal_putentryat(text[i], color, x + i, y);
}

// imprime a string apontada por "text" no centro da linha y,
// usando a cor determinada em "color" (criada com a função vga_entry_color).
void terminal_writestring_centered(size_t y, const char* text, uint8_t color)
{
	size_t x = (VGA_WIDTH - strlen(text)) / 2;
	terminal_writestring_location(x, y, text, color);
}

// imprime uma borda em volta da tela (linhas 0 e 24, colunas 0 e 79)
// usando o caractere passado em "character", na cor atual do terminal.
void terminal_write_border(char character)
{
	for (size_t x = 0; x < VGA_WIDTH; x++) {
		terminal_putentryat(character, terminal_color, x, 0);
		terminal_putentryat(character, terminal_color, x, VGA_HEIGHT - 1);
	}

	for (size_t y = 0; y < VGA_HEIGHT; y++) {
		terminal_putentryat(character, terminal_color, 0, y);
		terminal_putentryat(character, terminal_color, VGA_WIDTH - 1, y);
	}
}

// imprime um retângulo preenchido pelo caractere "character", com largura "width"
// e altura "height", com o canto superior esquerdo nas coordenadas x e y,
// usando a cor especificada em "color" (criada com a função vga_entry_color).
void terminal_write_rectangle(size_t x, size_t y, size_t width, size_t height, char character, uint8_t color)
{
	for (size_t linha = 0; linha < height; linha++) {
		for (size_t coluna = 0; coluna < width; coluna++)
			terminal_putentryat(character, color, x + coluna, y + linha);
	}
}

void main() {
    
    //char* memoria_de_video = (char *)0xB8000;
    //*memoria_de_video = 'X';
    
   terminal_initialize();
   terminal_writestring("Oi teste");
   // mudando a cor
   terminal_setcolor(VGA_COLOR_RED);
   terminal_writestring("Em vermelho agora");
   // imprime um X no centro (mais ou menos...) da tela (x: 40 e y: 12)
   terminal_putentryat('X', vga_entry_color(VGA_COLOR_RED, VGA_COLOR_LIGHT_GREY), 40, 12);
   
   // INCLUA AQUI AS CHAMADAS PARA TESTE DAS FUNÇÕES IMPLEMENTADAS NO SEU TRABALHO

   // 1. terminal_writestring() com quebra de linha
   terminal_setcolor(vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK));
   terminal_writestring("\n Linha 1\n Linha 2\n\n Linha 4 (a linha 3 ficou vazia)");

   // 2. terminal_writestring_location()
   terminal_writestring_location(30, 2, "Texto na coluna 30, linha 2", vga_entry_color(VGA_COLOR_BLUE, VGA_COLOR_LIGHT_GREY));
   terminal_writestring_location(10, 20, "Texto na coluna 10, linha 20", vga_entry_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK));

   // 3. terminal_writestring_centered()
   terminal_writestring_centered(7, "Centralizado na linha 7", vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLUE));
   terminal_writestring_centered(9, "Centro", vga_entry_color(VGA_COLOR_BLACK, VGA_COLOR_LIGHT_BROWN));

   // 5. terminal_write_rectangle()
   terminal_write_rectangle(60, 2, 10, 5, '#', vga_entry_color(VGA_COLOR_BLUE, VGA_COLOR_LIGHT_GREY));

   // 4. terminal_write_border()
   terminal_write_border('#');
}
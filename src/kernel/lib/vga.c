#include "vga.h"

uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg) 
{
    uint8_t color = fg | bg << 4;
    return color;
}

uint16_t vga_entry(unsigned char uc, uint8_t color) 
{
    return (uint16_t) uc | (uint16_t) color << 8;
}
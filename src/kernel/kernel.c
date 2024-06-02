#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "lib/terminal.h"
#include "lib/vga.h"
#include "lib/stringu.h"

void kernel_main(void) 
{
	// Initialize terminal interface
	terminal_initialize();
 
	// Test Terminal scrolling by counting to 100
    terminal_writestring("Counting to 100...\n");
    for (int i = 0; i < 100; i++) {
        terminal_writestring(numbtostr(i));
        terminal_writestring("\n");
    }
    terminal_writestring("100!\nCan you see this text? If so, terminal scrolling is working!\n");
}
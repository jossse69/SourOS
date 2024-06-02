#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "lib/terminal.h"
#include "lib/vga.h"
#include "lib/stringu.h"
#include "interrupts.h"

void kernel_main(void) 
{
    // Initialize the IDT
    idt_install();
	// Initialize terminal interface
	terminal_initialize();
 
	// Simple ifinite loop test
    while (true) {
        terminal_writestring("test\n");
    }
}
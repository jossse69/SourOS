; Declare constants for the multiboot header.
MBALIGN  equ  1 << 0            ; align loaded modules on page boundaries
MEMINFO  equ  1 << 1            ; provide memory map
MBFLAGS  equ  MBALIGN | MEMINFO ; this is the Multiboot 'flag' field
MAGIC    equ  0x1BADB002        ; 'magic number' lets bootloader find the header
CHECKSUM equ -(MAGIC + MBFLAGS)   ; checksum of above, to prove we are multiboot
 
; Declare a header as in the Multiboot spec.
align 4
	dd MAGIC
	dd MBFLAGS
	dd CHECKSUM
 

section .bss
align 16
stack_bottom:
resb 16384 ; 16 KiB
stack_top:
 

section .text
global _start:function (_start.end - _start)
_start:
	; Setup the stack pointer.
	mov esp, stack_top
 
	; Call the kernel main function.
	extern kernel_main
	call kernel_main
 
	; Hang
	cli
.hang:	hlt
	jmp .hang
.end:
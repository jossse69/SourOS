# Makefile for building SourOS

# Variables
BUILD_DIR=build
ISO_DIR=isodir
GRUB_CFG=src/kernel/grub.cfg

# Commands
NASM=nasm
GCC=i686-elf-gcc
GRUB_FILE=grub-file
GRUB_MKRESCUE=grub-mkrescue
CP=cp
RM=rm
MKDIR=mkdir

# Phony targets
.PHONY: all clean

# Default target
all: $(BUILD_DIR)/SourOS.iso

# Boot loader
$(BUILD_DIR)/boot.o: src/boot/boot.asm
	$(MKDIR) -p $(dir $@)
	$(NASM) -felf32 $< -o $@
	$(MKDIR) -p $(BUILD_DIR)/kernel/lib

# Kernel objects
$(BUILD_DIR)/kernel/%.o: src/kernel/lib/%.c
	$(GCC) -c $< -o $@ -std=gnu99 -ffreestanding -O2 -Wall -Wextra

# Kernel
$(BUILD_DIR)/kernel/kernel.o: src/kernel/kernel.c
	$(MKDIR) -p $(BUILD_DIR)/kernel/lib
	$(GCC) -c $< -o $@ -std=gnu99 -ffreestanding -O2 -Wall -Wextra

# Kernel library
$(BUILD_DIR)/kernel.o: $(BUILD_DIR)/kernel/kernel.o $(BUILD_DIR)/kernel/terminal.o $(BUILD_DIR)/kernel/vga.o $(BUILD_DIR)/kernel/stringu.o
	$(GCC) -o $@ -ffreestanding -O2 -nostdlib $^ -lgcc

# Linking
$(BUILD_DIR)/SourOS.bin: $(BUILD_DIR)/boot.o $(BUILD_DIR)/kernel/kernel.o
	$(GCC) -T src/kernel/linker.ld -o $@ -ffreestanding -O2 -nostdlib $^ -lgcc

# Multiboot check
$(BUILD_DIR)/SourOS.bin.multiboot: $(BUILD_DIR)/SourOS.bin
	$(GRUB_FILE) --is-x86-multiboot $<
	@echo "Multiboot confirmed!"

# ISO
$(BUILD_DIR)/SourOS.iso: $(BUILD_DIR)/SourOS.bin.multiboot $(GRUB_CFG)
	$(MKDIR) -p $(ISO_DIR)/boot/grub
	$(CP) build/SourOS.bin $(ISO_DIR)/boot/SourOS.bin
	$(CP) $(GRUB_CFG) $(ISO_DIR)/boot/grub/grub.cfg
	$(GRUB_MKRESCUE) -o $@ $(ISO_DIR)
	@echo "Success!"

# Cleanup
clean:
	$(RM) -rf $(BUILD_DIR) $(BUILD_DIR).iso
	
# Default target
.DEFAULT_GOAL := all
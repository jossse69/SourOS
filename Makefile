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

# Kernel
$(BUILD_DIR)/kernel.o: src/kernel/kernel.c
	$(GCC) -c $< -o $@ -std=gnu99 -ffreestanding -O2 -Wall -Wextra

# Linking
$(BUILD_DIR)/SourOS.bin: $(BUILD_DIR)/boot.o $(BUILD_DIR)/kernel.o
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

# Check if multiboot file exists before copying
$(BUILD_DIR)/SourOS.iso: $(BUILD_DIR)/SourOS.bin.multiboot
ifneq ("$(wildcard $(BUILD_DIR)/SourOS.bin.multiboot)","")
	$(MKDIR) -p $(ISO_DIR)/boot/grub
	$(CP) $< $(ISO_DIR)/boot/SourOS.bin
	$(CP) $(GRUB_CFG) $(ISO_DIR)/boot/grub/grub.cfg
	$(GRUB_MKRESCUE) -o $@ $(ISO_DIR)
	@echo "Success!"
endif

# Default target
.DEFAULT_GOAL := all
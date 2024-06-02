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

# Interrupts
$(BUILD_DIR)/interrupts.o: src/kernel/interrupts.s
	$(NASM) -felf32 $< -o $@

# Kernel objects
$(BUILD_DIR)/%.o: src/kernel/%.c
	$(MKDIR) -p $(dir $@)
	$(GCC) -c $< -o $@ -std=gnu99 -ffreestanding -O2 -Wall -Wextra

# Kernel library objects
$(BUILD_DIR)/lib/%.o: src/kernel/lib/%.c
	$(MKDIR) -p $(dir $@)
	$(GCC) -c $< -o $@ -std=gnu99 -ffreestanding -O2 -Wall -Wextra

# Linking
$(BUILD_DIR)/SourOS.bin: $(BUILD_DIR)/boot.o $(BUILD_DIR)/kernel.o $(wildcard $(BUILD_DIR)/lib/*.o) $(BUILD_DIR)/interrupts.o
	$(GCC) -T src/kernel/linker.ld -o $@ -ffreestanding -O2 -nostdlib $^ -lgcc

# Multiboot check
$(BUILD_DIR)/SourOS.bin.multiboot: $(BUILD_DIR)/SourOS.bin
	$(GRUB_FILE) --is-x86-multiboot $<
	@echo "Multiboot confirmed!"

# ISO
$(BUILD_DIR)/SourOS.iso: $(BUILD_DIR)/SourOS.bin.multiboot $(GRUB_CFG)
	$(MKDIR) -p $(ISO_DIR)/boot/grub
	$(CP) $(BUILD_DIR)/SourOS.bin $(ISO_DIR)/boot/SourOS.bin
	$(CP) $(GRUB_CFG) $(ISO_DIR)/boot/grub/grub.cfg
	$(GRUB_MKRESCUE) -o $@ $(ISO_DIR)
	@echo "Success!"

# Cleanup
clean:
	$(RM) -rf $(BUILD_DIR) $(ISO_DIR)

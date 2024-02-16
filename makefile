ASM=nasm
SRC_DIR=src
BUILD_DIR=build
DEBUG_DIR=debug
FILENAME=build/bootloader.bin
GCC=gcc

.PHONY: all floppy_image bootloader clean

run: floppy_image
	qemu-system-x86_64 -fda ${BUILD_DIR}/main_floppy.img

floppy_image: $(BUILD_DIR)/main_floppy.img

${BUILD_DIR}/main_floppy.img: bootloader kernel
	cat $(BUILD_DIR)/sector2.bin $(BUILD_DIR)/disk.bin >> $(BUILD_DIR)/bootloader.bin  
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main_floppy.img

bootloader: $(BUILD_DIR)/bootloader.bin $(BUILD_DIR)/sector2.bin

${BUILD_DIR}/bootloader.bin: always
	${ASM} ${SRC_DIR}/bootloader/boot.asm -f bin -o ${BUILD_DIR}/bootloader.bin

${BUILD_DIR}/sector2.bin: always
	${ASM} ${SRC_DIR}/bootloader/sector2.asm -f bin -o ${BUILD_DIR}/sector2.bin

kernel: $(BUILD_DIR)/disk.bin

$(BUILD_DIR)/disk.bin: $(BUILD_DIR)/main.o $(BUILD_DIR)/interrupt.o
	ld -melf_i386 -Ttext 0x10200 -nostdlib \
		$(BUILD_DIR)/main.o \
		$(BUILD_DIR)/interrupt.o \
		-o $(BUILD_DIR)/main.bin
	objcopy -O binary $(BUILD_DIR)/main.bin $(BUILD_DIR)/disk.bin

$(BUILD_DIR)/main.o:
	gcc -c -masm=intel -m32 -ffreestanding \
		$(SRC_DIR)/kernel/main.c \
		-o $(BUILD_DIR)/main.o

$(BUILD_DIR)/interrupt.o:
	gcc -c -masm=intel -m32 -ffreestanding \
		$(SRC_DIR)/kernel/interrupt.c \
		-o $(BUILD_DIR)/interrupt.o

always:
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)/*

dump:
	mkdir -p $(DEBUG_DIR)
	xxd $(FILENAME) > debug/o.txt
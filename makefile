ASM=nasm
SRC_DIR=src
BUILD_DIR=build
FILENAME=build/boot.bin

.PHONY: floppy_image bootloader clean

run: floppy_image
	qemu-system-x86_64 -fda ${BUILD_DIR}/main_floppy.img

floppy_image: $(BUILD_DIR)/main_floppy.img

${BUILD_DIR}/main_floppy.img: bootloader
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img bs=512 count=2880

${BUILD_DIR}/bootloader.bin: always
	${ASM} ${SRC_DIR}/bootloader/boot.asm -f bin -o ${BUILD_DIR}/bootloader.bin

clean:
	rm -rf $(BUILD_DIR)/*

dump:
	xxd $(FILENAME) > debug/o.txt
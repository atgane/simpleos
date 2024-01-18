run-bootloader: boot.img
	@qemu-system-x86_64 -fda build/boot.img

boot.img:
	@nasm -f bin -o build/boot.img src/boot.asm
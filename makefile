run-bootloader: boot.img
	@dd if=build/boot.img of=build/bootsec.flp
	@qemu-system-x86_64 -fda build/bootsec.flp

boot.img:
	nasm -f bin -o build/boot.img src/boot.asm
all: h8-bb.rom h8-16450.rom

h8-bb.rom: ../asm/scelbal-bitbang.bin ../asm/monitor-bitbang.bin
	cat ../asm/trekload.bin ../asm/galaxy-bitbang.bin > galaxy-bitbang-withloader.bin
	dd if=/dev/zero of=h8-bb.rom bs=1 count=16384
	dd if=../asm/monitor-bitbang.bin of=h8-bb.rom bs=1 conv=notrunc
	dd if=../asm/scelbal-bitbang.bin of=h8-bb.rom bs=1 seek=8192 conv=notrunc
	dd if=galaxy-bitbang-withloader.bin of=h8-bb.rom bs=1 seek=16384 conv=notrunc
	rm -f galaxy-bitbang-withloader.bin


h8-16450.rom: ../asm/scelbal-16450.bin ../asm/monitor-16450.bin
	cat ../asm/trekload.bin ../asm/galaxy-16450.bin > galaxy-16450-withloader.bin
	dd if=/dev/zero of=h8-16450.rom bs=1 count=16384     
	dd if=../asm/monitor-16450.bin of=h8-16450.rom bs=1 conv=notrunc      
	dd if=../asm/scelbal-16450.bin of=h8-16450.rom bs=1 seek=8192 conv=notrunc
	dd if=galaxy-16450-withloader.bin of=h8-16450.rom bs=1 seek=16384 conv=notrunc
	rm -f galaxy-16450-withloader.bin

clean:
	rm -f jim.rom h8-bb.rom h8-16450.rom scott.rom
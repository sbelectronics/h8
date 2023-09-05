all: h8-bb.rom h8-16450.rom

h8-bb.rom: ../asm/scelbal-bitbang.bin ../asm/monitor-bitbang.bin
	dd if=/dev/zero of=h8-bb.rom bs=1 count=16384
	dd if=../asm/monitor-bitbang.bin of=h8-bb.rom bs=1 conv=notrunc
	dd if=../asm/scelbal-bitbang.bin of=h8-bb.rom bs=1 seek=8192 conv=notrunc
	cat ../asm/load-trek.bin ../asm/galaxy-bitbang.bin | dd of=h8-bb.rom bs=1 seek=16384 conv=notrunc
	cat ../asm/load-40h.bin ../asm/pi-100-digits-bitbang.bin | dd of=h8-bb.rom bs=1 seek=24576 conv=notrunc


h8-16450.rom: ../asm/scelbal-16450.bin ../asm/monitor-16450.bin
	dd if=/dev/zero of=h8-16450.rom bs=1 count=16384     
	dd if=../asm/monitor-16450.bin of=h8-16450.rom bs=1 conv=notrunc      
	dd if=../asm/scelbal-16450.bin of=h8-16450.rom bs=1 seek=8192 conv=notrunc
	cat ../asm/load-trek.bin ../asm/galaxy-16450.bin | dd of=h8-16450.rom bs=1 seek=16384 conv=notrunc
	cat ../asm/load-40h.bin ../asm/pi-100-digits-16450.bin | dd of=h8-16450.rom bs=1 seek=24576 conv=notrunc

clean:
	rm -f jim.rom h8-bb.rom h8-16450.rom scott.rom

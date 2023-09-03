all: h8-bb.rom h8-16450.rom

h8-bb.rom: ../asm/scelbal-in-eprom.bin ../asm/monitor.bin
	dd if=/dev/zero of=h8-bb.rom bs=1 count=16384
	dd if=../asm/monitor.bin of=h8-bb.rom bs=1 conv=notrunc
	dd if=../asm/scelbal-in-eprom.bin of=h8-bb.rom bs=1 seek=8192 conv=notrunc

h8-16450.rom: ../asm/scelbal-16450.bin ../asm/monitor.bin     
	dd if=/dev/zero of=h8-16450.rom bs=1 count=16384     
	dd if=../asm/monitor-16450.bin of=h8-16450.rom bs=1 conv=notrunc      
	dd if=../asm/scelbal-16450.bin of=h8-16450.rom bs=1 seek=8192 conv=notrunc     

clean:
	rm -f jim.rom h8-bb.rom h8-16450.rom scott.rom

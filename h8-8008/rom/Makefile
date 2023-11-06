all: asm h8-bb.rom h8-16450.rom h8-16450-isr.rom h8-8251.rom h8-16450-h9term.rom sbc-8251.rom sbc-8251-h9term.rom

forth:
	cd ../../../8008-forth && make

asm:
	cd ../asm && make

h8-bb.rom: ../asm/scelbal-bitbang.bin ../asm/monitor-bitbang.bin ../asm/galaxy-bitbang.bin ../asm/pi-100-digits-bitbang.bin ../../../8008-forth/out/forth-bitbang.bin 
	dd if=/dev/zero of=h8-bb.rom bs=1 count=32768
	dd if=../asm/monitor-bitbang.bin of=h8-bb.rom bs=1 conv=notrunc
	dd if=../asm/scelbal-bitbang.bin of=h8-bb.rom bs=1 seek=8192 conv=notrunc
	dd if=../../../8008-forth/out/forth-bitbang.bin of=h8-bb.rom bs=1 seek=16384 conv=notrunc
	cat ../asm/load-trek.bin ../asm/galaxy-bitbang.bin | dd of=h8-bb.rom bs=1 seek=24576 conv=notrunc
	#cat ../asm/load-40h.bin ../asm/pi-100-digits-bitbang.bin | dd of=h8-bb.rom bs=1 seek=24576 conv=notrunc

h8-16450.rom: ../asm/scelbal-16450.bin ../asm/monitor-16450.bin ../asm/galaxy-16450.bin ../asm/pi-100-digits-16450.bin ../../../8008-forth/out/forth-16450.bin
	dd if=/dev/zero of=h8-16450.rom bs=1 count=65536
	dd if=../asm/monitor-16450.bin of=h8-16450.rom bs=1 conv=notrunc      
	dd if=../asm/scelbal-16450.bin of=h8-16450.rom bs=1 seek=8192 conv=notrunc
	dd if=../../../8008-forth/out/forth-16450.bin of=h8-16450.rom bs=1 seek=16384 conv=notrunc
	cat ../asm/load-trek.bin ../asm/galaxy-16450.bin | dd of=h8-16450.rom bs=1 seek=24576 conv=notrunc
	cat ../asm/load-40h.bin ../asm/pi-100-digits-16450.bin | dd of=h8-16450.rom bs=1 seek=32768 conv=notrunc
	cat ../asm/load-40h.bin ../asm/pi-1000-digits-16450.bin | dd of=h8-16450.rom bs=1 seek=40960 conv=notrunc
	cat ../asm/load-200h.bin ../asm/hangman-16450.bin | dd of=h8-16450.rom bs=1 seek=49152 conv=notrunc	
	#cat h8-16450.rom h8-16450.rom h8-16450.rom h8-16450.rom h8-16450.rom h8-16450.rom h8-16450.rom h8-16450.rom > 39sf040/h8-16450-39sf040.rom

h8-16450-isr.rom: ../asm/scelbal-16450-isr.bin ../asm/monitor-16450-isr.bin ../asm/galaxy-16450.bin ../asm/pi-100-digits-16450.bin ../../../8008-forth/out/forth-16450.bin
	dd if=/dev/zero of=h8-16450-isr.rom bs=1 count=32768  
	dd if=../asm/monitor-16450-isr.bin of=h8-16450-isr.rom bs=1 conv=notrunc      
	dd if=../asm/scelbal-16450-isr.bin of=h8-16450-isr.rom bs=1 seek=8192 conv=notrunc
	dd if=../../../8008-forth/out/forth-16450.bin of=h8-16450-isr.rom bs=1 seek=16384 conv=notrunc
	cat ../asm/load-trek.bin ../asm/galaxy-16450.bin | dd of=h8-16450-isr.rom bs=1 seek=24576 conv=notrunc
	#cat ../asm/load-40h.bin ../asm/pi-100-digits-16450.bin | dd of=h8-16450-isr.rom bs=1 seek=24576 conv=notrunc

h8-16450-h9term.rom: ../asm/scelbal-16450-h9term.bin ../asm/monitor-16450-h9term.bin ../asm/galaxy-16450-h9term.bin ../../../8008-forth/out/forth-16450-h9term.bin
	dd if=/dev/zero of=h8-16450-h9term.rom bs=1 count=32768  
	dd if=../asm/monitor-16450-h9term.bin of=h8-16450-h9term.rom bs=1 conv=notrunc      
	dd if=../asm/scelbal-16450-h9term.bin of=h8-16450-h9term.rom bs=1 seek=8192 conv=notrunc
	dd if=../../../8008-forth/out/forth-16450-h9term.bin of=h8-16450-h9term.rom bs=1 seek=16384 conv=notrunc
	cat ../asm/load-trek.bin ../asm/galaxy-16450-h9term.bin | dd of=h8-16450-h9term.rom bs=1 seek=24576 conv=notrunc

h8-8251.rom: ../asm/scelbal-8251.bin ../asm/monitor-8251.bin ../asm/galaxy-8251.bin ../asm/pi-100-digits-8251.bin
	dd if=/dev/zero of=h8-8251.rom bs=1 count=32768   
	dd if=../asm/monitor-8251.bin of=h8-8251.rom bs=1 conv=notrunc      
	dd if=../asm/scelbal-8251.bin of=h8-8251.rom bs=1 seek=8192 conv=notrunc
	dd if=../../../8008-forth/out/forth-8251.bin of=h8-8251.rom bs=1 seek=16384 conv=notrunc
	cat ../asm/load-trek.bin ../asm/galaxy-8251.bin | dd of=h8-8251.rom bs=1 seek=24576 conv=notrunc
	#cat ../asm/load-40h.bin ../asm/pi-100-digits-8251.bin | dd of=h8-8251.rom bs=1 seek=24576 conv=notrunc

#sbc-16450.rom: ../asm/scelbal-16450.bin ../asm/monitor-16450-sbcfp.bin ../asm/galaxy-16450.bin ../../../8008-forth/out/forth-16450.bin
#	dd if=/dev/zero of=sbc-16450.rom bs=1 count=32768  
#	dd if=../asm/monitor-16450-sbcfp.bin of=sbc-16450.rom bs=1 conv=notrunc      
#	dd if=../asm/scelbal-16450.bin of=sbc-16450.rom bs=1 seek=8192 conv=notrunc
#	dd if=../../../8008-forth/out/forth-16450.bin of=sbc-16450.rom bs=1 seek=16384 conv=notrunc
#	cat ../asm/load-trek.bin ../asm/galaxy-16450.bin | dd of=sbc-16450.rom bs=1 seek=24576 conv=notrunc

sbc-8251.rom: ../asm/scelbal-8251.bin ../asm/monitor-8251-sbcfp.bin ../asm/galaxy-8251.bin ../../../8008-forth/out/forth-8251.bin
	dd if=/dev/zero of=sbc-8251.rom bs=1 count=65536
	dd if=../asm/monitor-8251-sbcfp.bin of=sbc-8251.rom bs=1 conv=notrunc      
	dd if=../asm/scelbal-8251.bin of=sbc-8251.rom bs=1 seek=8192 conv=notrunc
	dd if=../../../8008-forth/out/forth-8251.bin of=sbc-8251.rom bs=1 seek=16384 conv=notrunc
	cat ../asm/load-trek.bin ../asm/galaxy-8251.bin | dd of=sbc-8251.rom bs=1 seek=24576 conv=notrunc
	cat ../asm/load-40h.bin ../asm/pi-100-digits-8251.bin | dd of=sbc-8251.rom bs=1 seek=32768 conv=notrunc
	cat ../asm/load-40h.bin ../asm/pi-1000-digits-8251.bin | dd of=sbc-8251.rom bs=1 seek=40960 conv=notrunc
	cat ../asm/load-200h.bin ../asm/hangman-8251.bin | dd of=sbc-8251.rom bs=1 seek=49152 conv=notrunc

sbc-8251-h9term.rom: ../asm/scelbal-8251-h9term.bin ../asm/monitor-8251-sbcfp-h9term.bin ../asm/galaxy-8251-h9term.bin ../../../8008-forth/out/forth-8251-h9term.bin
	dd if=/dev/zero of=sbc-8251-h9term.rom bs=1 count=65536
	dd if=../asm/monitor-8251-sbcfp-h9term.bin of=sbc-8251-h9term.rom bs=1 conv=notrunc      
	dd if=../asm/scelbal-8251-h9term.bin of=sbc-8251-h9term.rom bs=1 seek=8192 conv=notrunc
	dd if=../../../8008-forth/out/forth-8251-h9term.bin of=sbc-8251-h9term.rom bs=1 seek=16384 conv=notrunc
	cat ../asm/load-trek.bin ../asm/galaxy-8251-h9term.bin | dd of=sbc-8251-h9term.rom bs=1 seek=24576 conv=notrunc

emusbc:
	eprom-emulator -mem 27256 sbc-8251.rom /dev/ttyUSB0

clean:
	cd ../asm && make clean
	rm -f jim.rom h8-bb.rom h8-16450.rom scott.rom

all: rd.dvd dumprd.abs
	cp rd.dvd /home/smbaker/projects/pi/h8/vdip/FILES/ASM/RD.DVD
	cp dumprd.abs /home/smbaker/projects/pi/h8/vdip/FILES/ASM/DUMPRD.ABS

rd.dvd: rd.rel rdi.rel
	rm -f ../sy0/rd.dvd
	cat rd.rel rdi.rel > rd.dvd
	cp rd.dvd ../sy0/
	vhdos dvddkgen rd:
	mv ../sy0/rd.dvd .

%.rel: %.asm
	vhdos asm dk1:$*.rel,dk1:$*=dk1:$*,sy1:/err

%.abs: %.asm
	vhdos asm dk1:$*.abs,dk1:$*=dk1:$*,sy1:/err

clean:
	rm *.rel *.dvd *.abs

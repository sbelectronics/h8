all: rd.dvd

rd.dvd: rd.rel rdi.rel
	rm -f ../sy0/rd.dvd
	cat rd.rel rdi.rel > rd.dvd
	cp rd.dvd ../sy0/
	vhdos dvddkgen rd:
	mv ../sy0/rd.dvd .
	cp rd.dvd /home/smbaker/projects/pi/h8/vdip/FILES/ASM/RD.DVD

%.rel: %.asm
	vhdos asm dk1:$*.rel,dk1:$*=dk1:$*,sy1:/err

clean:
	rm *.rel *.dvd

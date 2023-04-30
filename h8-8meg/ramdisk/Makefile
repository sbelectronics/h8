export HDOSDrive_dk1 = $(PWD)

all: rd.dvd dumprd.abs copyout

rd.dvd: rd.rel rdi.rel
	rm -f rd.dvd
	cat rd.rel rdi.rel > rd.tmp
	# Note: If you do not have python3 installed, an alternative would be
	# to copy rd.dvd to vhdosroot/sy0/ and then run "DVDKKGEN.ABS RD:" inside
	# vhdos
	python3 ./dvddkgen.py < rd.tmp > rd.dvd

%.rel: %.asm
	vhdos asm dk1:$*.rel,dk1:$*=dk1:$*,sy1:/err

%.abs: %.asm
	vhdos asm dk1:$*.abs,dk1:$*=dk1:$*,sy1:/err

# Copy files out to scott's Pinculum holding directory. Safe to omit if you
# are not me.
copyout:
	cp rd.dvd /home/smbaker/projects/pi/h8/vdip/FILES/ASM/RD.DVD
	cp dumprd.abs /home/smbaker/projects/pi/h8/vdip/FILES/ASM/DUMPRD.ABS

clean:
	rm -f *.rel *.dvd *.abs

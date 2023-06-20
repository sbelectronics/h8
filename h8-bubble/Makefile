export HDOSDrive_dk1 = $(PWD)

all: bubble.abs bd.dvd copyout

%.abs: %.asm
	vhdos asm dk1:$*.abs,dk1:$*=dk1:$*,sy1:/err

bd.dvd: bd.rel bdi.rel
	rm -f bd.dvd
	cat bd.rel bdi.rel > bd.tmp
	# Note: If you do not have python3 installed, an alternative would be
	# to copy rd.dvd to vhdosroot/sy0/ and then run "DVDKKGEN.ABS RD:" inside
	# vhdos
	python3 ./dvddkgen.py < bd.tmp > bd.dvd

%.rel: %.asm
	vhdos asm dk1:$*.rel,dk1:$*=dk1:$*,sy1:/err

# Include file for Newmon
bbl.inc: bubdef.acm bblcom.acm bblrdmin.acm bblvar.acm 
	python ./convert.py < bubdef.acm > bbl.inc
	python ./convert.py < bblcom.acm >> bbl.inc
	python ./convert.py < bblrdmin.acm >> bbl.inc
	python ./convert.py < bblvar.acm >> bbl.inc

# The Newmon boot loader
bbubble: bbl.inc
	python ./subst.py < /home/smbaker/projects/pi/h8/MmsCpm3/rom/newmon/src/bbubble.src > /home/smbaker/projects/pi/h8/MmsCpm3/rom/newmon/src/bbubble.asm

# for bubble-basic board
bblbas.asm: bbldef.acm bblcom.acm bblrdmin.acm bblvar.acm bbljump.acm bblrw.acm Makefile
	echo "SECTION        bubble_lib" > bblbas.asm
	python ./convert.py < bblpub.acm >> bblbas.asm
	python ./convert.py < bbldef.acm >> bblbas.asm
	python ./convert.py < bblcom.acm >> bblbas.asm
	python ./convert.py < bblrw.acm >> bblbas.asm
	python ./convert.py < bblchunk.acm >> bblbas.asm
	echo "SECTION        bubble_vars" >> bblbas.asm
	python ./convert.py < bblvar.acm >> bblbas.asm
	cp bblbas.asm /home/smbaker/projects/pi/basic-bubble/basic/

# Copy files out to scott's Pinculum holding directory. Safe to omit if you
# are not me.
copyout:
	cp bubble.abs /home/smbaker/projects/pi/h8/vdip/FILES/ASM/BUBBLE.ABS
	cp bd.dvd /home/smbaker/projects/pi/h8/vdip/FILES/ASM/BD.DVD

clean:
	rm -f *.rel *.dvd *.abs bbl.inc

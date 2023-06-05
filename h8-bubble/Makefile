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

bbl.inc: bubdef.acm bblcom.acm bblrdmin.acm bblvar.acm 
	python ./convert.py < bubdef.acm > bbl.inc
	python ./convert.py < bblcom.acm >> bbl.inc
	python ./convert.py < bblrdmin.acm >> bbl.inc
	python ./convert.py < bblvar.acm >> bbl.inc

bbubble: bbl.inc
	python ./subst.py < /home/smbaker/projects/pi/h8/MmsCpm3/rom/newmon/src/bbubble.src > /home/smbaker/projects/pi/h8/MmsCpm3/rom/newmon/src/bbubble.asm


# Copy files out to scott's Pinculum holding directory. Safe to omit if you
# are not me.
copyout:
	cp bubble.abs /home/smbaker/projects/pi/h8/vdip/FILES/ASM/BUBBLE.ABS
	cp bd.dvd /home/smbaker/projects/pi/h8/vdip/FILES/ASM/BD.DVD

clean:
	rm -f *.rel *.dvd *.abs bbl.inc

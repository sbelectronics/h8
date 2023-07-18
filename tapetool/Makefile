export HDOSDrive_dk1 = $(PWD)

all: tmildr.abs

%.abs: %.asm
	vhdos asm dk1:$*.abs,dk1:$*=dk1:$*,sy1:/err

# Copy files out to scott's Pinculum holding directory. Safe to omit if you
# are not me.
copyout:
	cp tmildr.abs /home/smbaker/projects/pi/h8/vdip/FILES/MEMCON/TMILDR.ABS
clean:
	rm -f *.rel *.dvd *.abs bbl.inc

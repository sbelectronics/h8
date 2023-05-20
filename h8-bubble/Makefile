export HDOSDrive_dk1 = $(PWD)

all: bubble.abs copyout

%.abs: %.asm
	vhdos asm dk1:$*.abs,dk1:$*=dk1:$*,sy1:/err

# Copy files out to scott's Pinculum holding directory. Safe to omit if you
# are not me.
copyout:
	cp bubble.abs /home/smbaker/projects/pi/h8/vdip/FILES/ASM/BUBBLE.ABS

clean:
	rm -f *.rel *.dvd *.abs

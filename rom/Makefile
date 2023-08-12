all: exbasic32k.rom exbasic32k-patched.rom h8demo.rom

exbasic32k.rom: EXBASIC2.H8T h8t-to-rom.py
	# Extended Benton Harbor Basic 2
	# Press "GO" to run EXBasic, or use primary autoboot (set SW1-7)
	python ./h8t-to-rom.py EXBASIC2-PATCHED-FIXCRC.H8T exbasic32k.rom

exbasic32k-patched.rom: EXBASIC2-PATCHED-FIXCRC.H8T h8t-to-rom.py
    # Extended Benton Harbor Basic 2 with Scott's patch for paper tape
	# Press "GO" to run EXBasic, or use primary autoboot (set SW1-7)
	python ./h8t-to-rom.py EXBASIC2-PATCHED-FIXCRC.H8T exbasic32k-patched.rom

h8demo.rom: H8DEMO.H8T h8t-to-rom.py
	# H8Demo
	# Press "GO" to run H8Demo
	# Note: autoboot doesn't seem to work with H8demo...
	python ./h8t-to-rom.py H8DEMO.H8T h8demo.rom

quad8080.rom: exbasic32k-patched.rom 2732_444-70_XCON8.ROM ../MmsCpm3/rom/newmon-80/src/h8amon2.rom h8demo.rom
	# For Scott's 8085 board, when using a 39SF010 or similar 128KB ROM
	#   ROM0 = newmon-80
	#   ROM1 = xcon8
	#   ROM2 = extended benton harbor basic
	#   ROM3 = h8demo
	dd if=/dev/zero of=quad8080.rom bs=1 count=131072
	dd if=../MmsCpm3/rom/newmon-80/src/h8amon2.rom bs=1024 seek=0 conv=notrunc of=quad8080.rom
	dd if=2732_444-70_XCON8.ROM bs=1024 seek=32 conv=notrunc of=quad8080.rom
	dd if=exbasic32k-patched.rom bs=1024 seek=64 conv=notrunc of=quad8080.rom
	dd if=h8demo.rom bs=1024 seek=96 conv=notrunc of=quad8080.rom

clean:
	rm -f exbasic32k.rom exbasic32k-patched.rom quad8080.rom h8demo.rom

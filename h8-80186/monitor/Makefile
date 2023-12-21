all: monitor.com fpon.com fpoff.com fpltm.com wreboot.com
	cp *.com /home/smbaker/projects/pi/h8/h8-80186/commands/

monitor.com: monitor.asm h8display.asm h8mon.asm h8int.asm
	nasm monitor.asm -fbin -o monitor.com -l monitor.lst -dCOMFILE

fpon.com: fpon.asm
	nasm fpon.asm -fbin -o fpon.com -l fpon.lst -dCOMFILE

fpoff.com: fpoff.asm
	nasm fpoff.asm -fbin -o fpoff.com -l fpoff.lst -dCOMFILE

fpltm.com: fpltm.asm
	nasm fpltm.asm -fbin -o fpltm.com -l fpltm.lst -dCOMFILE

wreboot.com: wreboot.asm
	nasm wreboot.asm -fbin -o wreboot.com -l wreboot.lst -dCOMFILE

copy:
	sudo umount /mnt/dos || true
	sudo umount /mnt/dos || true
	sudo mount -o uid=1026 /dev/sdc1 /mnt/dos
	cp monitor.com /mnt/dos/
	sudo umount /mnt/dos

clean:
	rm -f monitor.com fpon.com fpoff.com fpltm.com

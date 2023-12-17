monitor.com: monitor.asm
	nasm monitor.asm -fbin -o monitor.com -l monitor.lst

copy:
	sudo umount /mnt/dos || true
	sudo umount /mnt/dos || true
	sudo mount -o uid=1026 /dev/sdc1 /mnt/dos
	cp monitor.com /mnt/dos/
	sudo umount /mnt/dos

clean:
	rm -f monitor.com

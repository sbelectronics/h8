org 0xC000
di
lxi b, 0x1000
lxi h, 0x2000
mvi m, 0x00
inx h
dcx b
jnz 0xC007
jmp C00E
	
;; F3  01  00  10  21  00  20  36  00  23  0B  C2  07  C0  C3  0E  C0
;; 363 001 000 020 041 000 040 066 000 043 013 302 007 300 303 016 300

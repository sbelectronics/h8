	cpu 186

%define	SOFT_DEBUG 0
%include "macros.inc"
%include "cpuregs.inc"

DIGSEL  equ 0x4F0

	org 100h 
 
section .text 
 
start:
	mov	dx, banner
	call	writeStr

	mov	dx,DIGSEL
	mov	al,0b11100000
	out	dx,al

	int	20h

	; print the string in DX
writeStr:
	push	ax
	mov 	ah, 09h
	int 	0x21
	pop 	ax
	ret
 
section .data
 
banner	db	'frontpanel-on', 0x0d, 0x0a, '$'

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

	mov	ax,0040h
	mov	es,ax
	mov 	word [es:0072h], 1234h
	db	0eah
	dw	0000h
	dw	0ffffh

	int	20h				; this should never execute

	; print the string in DX
writeStr:
	push	ax
	mov 	ah, 09h
	int 	0x21
	pop 	ax
	ret
 
section .data
 
banner	db	'warm reboot', 0x0d, 0x0a, '$'

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

	mov	dx,PIC_I0CON	; Int 0 control register
	in	ax,dx
	and	ax,~08h		; clear the mask bit
	or	ax,10h		; set the LTM bit
	out	dx,ax

	int	20h

	; print the string in DX
writeStr:
	push	ax
	mov 	ah, 09h
	int 	0x21
	pop 	ax
	ret
 
section .data
 
banner	db	'frontpanel-ltm', 0x0d, 0x0a, '$'

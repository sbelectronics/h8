	cpu 186

%define	SOFT_DEBUG 0
%include "macros.inc"
%include "cpuregs.inc"

DIGSEL  equ 0x4F0
DIGVAL  equ 0x4F1

; on port 360,
;   D7 is speaker
;   D6 is enable monitor interrupts
;   D5 is music and refresh monitor LED
;   D4 is something to do with int20

	org 100h 
 
section .text 
 
start:
	mov	dx, banner
	call	writeStr

	call	h8_display_init
	call	mon_init

	call 	install_int
	call	h8_enable_int
	call	h8_enable_fp

	call    check_tsr

	;;jmp	test_tf

	mov	dx, exit
	call	writeStr
	call	readKey
	call	h8_disable_fp
	call	h8_disable_int
	call	restore_int
	int	20h

	; Length of command line is at 80h
	; Command line starts at 81h
	; It always ends with 0x0D
check_tsr:
	mov	bx,81h
again:	mov	al,[bx]			; skip any leading spaces
	cmp	al,' '
	jnz	notspace
	inc	bx
	jmp 	again
notspace:
	cmp	al,'/'
	jnz	not_tsr			; doesn't start with slash
	inc	bx
	mov	al,[bx]
	cmp	al,'R'
	jz	yes_tsr			; second character isn't 'R'
	cmp	al,'r'
	jz	yes_tsr
	jmp	not_tsr
yes_tsr:
	mov	dx, tsr
	call 	writeStr
	mov	ax,3100h
	mov	dx, (end_of_resident - start + 256 + 15) >> 4
	int	21h
not_tsr:
	ret

test_tf:
	mov	ax,1101h
	mov	bx,2202h
	mov	cx,3303h
	mov	dx,4404h
test_tf_loop:
	jmp	test_tf_loop

install_int:
	mov  	bl,0Ch			; vector for INT0
	call	get_vector		; get current vector to DX:AX
	mov	word [old_int_seg], dx
	mov	word [old_int_ofs], ax
	mov 	bl,0Ch			; vector for INT0
	mov	dx,cs			; segment of handler is our code seg
	mov	ax,h8_fpanint		; offset of handler
	call	set_vector		; set vector to DX:AX
	ret

restore_int:
	mov	bl,0Ch
	mov	dx, word [old_int_seg]
	mov	ax, word [old_int_ofs]
	call 	set_vector
	ret

	; read a key and return in AL. Destroys AX.
readKey:
	mov	ah,01h
	int	21h
	ret

	; print the string in DX
writeStr:
	push	ax
	mov 	ah, 09h
	int 	0x21
	pop 	ax
	ret
 
section .data
 
banner	db	'H8-80186 monitor', 0x0d, 0x0a, '$'
exit    db	'Press any key to exit', 0x0d, 0x0a, '$'
tsr	db 	'Terminating and staying resident', 0x0d, 0x0a, '$'

old_int_seg	dw	0
old_int_ofs	dw	0

%include	"h8int.asm"
%include        "h8display.asm"
%include 	"h8mon.asm"
%include	"h8data.asm"
%include	"set_vector.asm"

end_of_resident:
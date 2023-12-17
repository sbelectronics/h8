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
	call 	install_int
	call	enable_int
	call	enable_fp

	mov	al, 0o012
	call	h8_set_octal_l
	mov	al, 0o343
	call	h8_set_octal_m
	mov	al, 0o210
	call	h8_set_octal_r

	call    mon_start

	;;jmp	test_tf

	mov	dx, exit
	call	writeStr
	call	readKey
	call	disable_fp
	call	disable_int
	call	restore_int
	int	20h

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
	mov	ax,fpanint		; offset of handler
	call	set_vector		; set vector to DX:AX
	ret

restore_int:
	mov	bl,0Ch
	mov	dx, word [old_int_seg]
	mov	ax, word [old_int_ofs]
	call 	set_vector
	ret

enable_int:
	mov	dx,PIC_I0CON	; Int 1 control register
	in	ax,dx
	and	ax,~08h		; clear the mask bit
	out	dx,ax
	ret

disable_int:
	mov	dx,PIC_I0CON	; Int 1 control register
	in	ax,dx
	or	ax,08h		; set the mask bit
	out	dx,ax
	ret

enable_fp:
	mov	dx,DIGSEL
	mov	al,0b11100000
	out	dx,al
	ret

disable_fp:
	mov	DX,DIGSEL
	mov	al,0b10000000
	out	dx,al
	ret

fpanint:
        pushm   ax,bx,cx,dx,ds
	mov	ax,cs
	mov	ds,ax
	mov	ax,sp
	mov	[mon_tf_addr], ax
	call	h8_display_hook
	popm	ax,bx,cx,dx,ds
	jmp	end_of_interrupt

;------------------------------------------------------------------------------
; end_of_interrupt

end_of_interrupt:
        pushm   ax,dx
        mov     dx,PIC_EOI              ; EOI register
        mov     ax,EOI_NSPEC            ; non-specific end of interrupt
        out     dx,ax                   ; signal it
        popm    ax,dx
	iret

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

old_int_seg	dw	0
old_int_ofs	dw	0


%include        "h8display.asm"
%include 	"h8mon.asm"
%include	"h8data.asm"
%include	"set_vector.asm"
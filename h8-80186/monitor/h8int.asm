h8_install_int_forever:
	mov 	bl,0Ch			; vector for INT0
	mov	dx,cs			; segment of handler is our code seg
	mov	ax,h8_fpanint		; offset of handler
	call	set_vector		; set vector to DX:AX
	ret

h8_enable_int:
	mov	dx,PIC_I0CON	; Int 1 control register
	in	ax,dx
	and	ax,~08h		; clear the mask bit
	out	dx,ax
	ret

h8_disable_int:
	mov	dx,PIC_I0CON	; Int 1 control register
	in	ax,dx
	or	ax,08h		; set the mask bit
	out	dx,ax
	ret

h8_enable_fp:
	mov	dx,DIGSEL
	mov	al,0b11100000
	out	dx,al
	ret

h8_disable_fp:
	mov	DX,DIGSEL
	mov	al,0b10000000
	out	dx,al
	ret

h8_fpanint:
        pushm   ax,bx,cx,dx,ds
;;	mov	ax,cs
	mov	ax,h8_data_seg		; use the BDA
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

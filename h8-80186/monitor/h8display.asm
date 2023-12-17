DIGSEL  equ 0x4F0
DIGVAL  equ 0x4F1

; on port 360,
;   D7 is speaker
;   D6 is enable monitor interrupts
;   D5 is music and refresh monitor LED
;   D4 is something to do with int20
 
section .text 

;------------------------------------------------------------------------------
; h8_display_hook
;  

h8_display_hook:
	mov	ax, word [h8_count_lo]		; increment the cycle counter
	inc	ax
	mov	word [h8_count_lo], ax

	and	ax, 0x1F
	jnz	h8_not_upd
	call	mon_update
h8_not_upd:
	call	h8_multiplex_digit
	jmp	h8_scankey

;------------------------------------------------------------------------------
; h8_multiplex_digit
;  

h8_multiplex_digit:
	xor	bh, bh				; get digit index into AX so we can add it to BX
	mov	bl, [digindex]			; BL = digit index
	mov	bh, [bx + h8_digits0]		; BH = digit value
	mov	dx, DIGSEL
	or	bl, [h8_digsel_or]		; or in the speaker and other junk
	mov	al, bl				; digit number into bl
	out	dx, al				; send digit number to DIGSEL
	mov	dx, DIGVAL
	mov	al, bh				; digit value into bh
	out	dx, al				; send digit number to DIGVAL

	mov	ah, [digindex]			; get the current digit index into ah
	dec     ah
	jnz	digindex_nowrap
	mov	ah,9
digindex_nowrap:
	mov	[digindex],ah
	ret

;!------------------------------------------------------------------------------
; h8_scankey

h8_scankey:
	mov	dx, DIGSEL		; read the keyboard from DIGSEL
	in	al, dx
	cmp	al, [key_last]		; same as last key?
	jnz	h8_scankey_different	; no, different

	mov	ah, [key_same_count]	; increment same_count
	inc 	ah
	mov	[key_same_count], ah
	cmp	ah, 0AH			; do we have 10 hits on the key?
	jz	key_same_enough		; yes, process it
	ret

key_same_enough:
	mov	bx, scancodes+10H	; start with the last scancode
	mov	ah, 11H			; check 17 scancodes
next_scancode:
	cmp	al, [bx]
	jnz	not_this_scancode
	mov	al, ah
	dec	al
	jmp	mon_keydown
not_this_scancode:
	dec	bx			; next address
	dec	ah			; one less to do
	jnz	next_scancode		; keep going if nonzero
	ret

h8_scankey_different:
	mov	[key_last], al		; save the new key_last
	mov 	al, 0
	mov	[key_same_count], al	; reset same_count
	ret

;------------------------------------------------------------------------------
; h8_set_octal_l
;
; input:
;   al = value 0-255

h8_set_octal_l:
	pushm	ax,bx

	mov     ah, al				; save value into ah

	mov	al, [h8_radix]
	or	al, al
	jnz	h8_set_hex_l

	xor	bh, bh
	mov 	bl, ah
	shr	bl, 6
	and	bl, 0x07
	mov	al, [bx + digit_7seg]
	mov	[h8_digits_l], al

	xor	bh, bh
	mov 	bl, ah
	shr	bl, 3
	and	bl, 0x07
	mov	al, [bx + digit_7seg]
	mov	[h8_digits_l+1], al

	xor	bh, bh
	mov 	bl, ah
	and	bl, 0x07
	mov	al, [bx + digit_7seg]
	mov	[h8_digits_l+2], al
	jmp	h8_set_octal_l_ret

h8_set_hex_l:
	xor	bh, bh
	mov	bl, ah
	shr	bl, 4
	and     bl, 0x0F
	mov	al, [bx + digit_7seg]
	mov	[h8_digits_l], al

	xor	bh, bh
	mov	bl, ah
	and     bl, 0x0F
	mov	al, [bx + digit_7seg]
	mov	[h8_digits_l+1], al

	mov	al, 0b11111111
	mov	[h8_digits_l+2], al

h8_set_octal_l_ret:
	popm	ax,bx
	ret

;------------------------------------------------------------------------------
; h8_set_octal_m
;
; input:
;   al = value 0-255

h8_set_octal_m:
	pushm	ax,bx

	mov     ah, al				; save value into ah

	mov	al, [h8_radix]
	or	al, al
	jnz	h8_set_hex_m

	xor	bh, bh
	mov 	bl, ah
	shr	bl, 6
	and	bl, 0x07
	mov	al, [bx + digit_7seg]
	mov	[h8_digits_m], al

	xor	bh, bh
	mov 	bl, ah
	shr	bl, 3
	and	bl, 0x07
	mov	al, [bx + digit_7seg]
	mov	[h8_digits_m+1], al

	xor	bh, bh
	mov 	bl, ah
	and	bl, 0x07
	mov	al, [bx + digit_7seg]
	mov	[h8_digits_m+2], al
	jmp	h8_set_octal_m_ret

h8_set_hex_m:
	xor	bh, bh
	mov	bl, ah
	shr	bl, 4
	and     bl, 0x0F
	mov	al, [bx + digit_7seg]
	mov	[h8_digits_m], al

	xor	bh, bh
	mov	bl, ah
	and     bl, 0x0F
	mov	al, [bx + digit_7seg]
	mov	[h8_digits_m+1], al

	mov	al, 0b11111111
	mov	[h8_digits_m+2], al

h8_set_octal_m_ret:
	popm	ax,bx
	ret

;------------------------------------------------------------------------------
; h8_set_octal_r
;
; input:
;   al = value 0-255

h8_set_octal_r:
	pushm	ax,bx

	mov     ah, al				; save value into ah

	mov	al, [h8_radix]
	or	al, al
	jnz	h8_set_hex_r

	xor	bh, bh
	mov 	bl, ah
	shr	bl, 6
	and	bl, 0x07
	mov	al, [bx + digit_7seg]
	mov	[h8_digits_r], al

	xor	bh, bh
	mov 	bl, ah
	shr	bl, 3
	and	bl, 0x07
	mov	al, [bx + digit_7seg]
	mov	[h8_digits_r+1], al

	xor	bh, bh
	mov 	bl, ah
	and	bl, 0x07
	mov	al, [bx + digit_7seg]
	mov	[h8_digits_r+2], al
	jmp	h8_set_octal_r_ret

h8_set_hex_r:
	xor	bh, bh
	mov	bl, ah
	shr	bl, 4
	and     bl, 0x0F
	mov	al, [bx + digit_7seg]
	mov	[h8_digits_r], al

	xor	bh, bh
	mov	bl, ah
	and     bl, 0x0F
	mov	al, [bx + digit_7seg]
	mov	[h8_digits_r+1], al

	mov	al, 0b11111111
	mov	[h8_digits_r+2], al

h8_set_octal_r_ret:
	popm	ax,bx
	ret

;------------------------------------------------------------------------------
; h8_set_reg_r
;
; input:
;   al = register number

h8_set_reg_r:
	pushm	ax, bx

	xor 	bh, bh
	mov	bl, al
	shl	bx, 2

	mov	ah, [bx + reg_7seg]
	mov	[h8_digits_r], ah

	inc	bx
	mov	ah, [bx + reg_7seg]
	mov	[h8_digits_r+1], ah

	inc 	bx
	mov	ah, [bx + reg_7seg]
	mov	[h8_digits_r+2], ah

	popm	ax,bx
	ret

;------------------------------------------------------------------------------
; h8_set_octal_addr
;
; input:
;   ax = value 0-65535

h8_set_octal_addr:
	call	h8_set_octal_m
	xchg	al,ah
	call	h8_set_octal_l
	xchg	al,ah
	ret
 
;------------------------------------------------------------------------------
; constants that can go in the text area

digit_7seg:
	db	0b10000001	; 0
	db	0b11110011	; 1
	db	0b11001000	; 2
	db	0b11100000	; 3
	db	0b10110010	; 4
	db	0b10100100	; 5
	db	0b10000100	; 6
	db	0b11110001	; 7
	db	0b10000000	; 8
	db	0b10100000	; 9
	db   	0b10010000  	; A
	db   	0b10000110  	; B
	db   	0b10001101  	; C
	db   	0b11000010  	; D
	db   	0b10001100  	; E
	db   	0b10011100  	; F

reg_7seg:
reg_7seg_sg:
	db  0b11111111,  0b10100100, 0b10000101, 0b00000000
reg_7seg_cs:
	db  0b11111111,  0b11001110, 0b10100100, 0b00000000
reg_7seg_ip:
	db  0b11111111,  0b11110011, 0b10011000, 0b00000000
reg_7seg_ax:
	db  0b11111111,  0b11111111, 0b10010000, 0b00000000
reg_7seg_bx:
	db  0b11111111,  0b11111111, 0b10000110, 0b00000000
reg_7seg_cx:
	db  0b11111111,  0b11111111, 0b10001101, 0b00000000
reg_7seg_dx:
	db  0b11111111,  0b11111111, 0b11000010, 0b00000000


scancodes:
	db 0b11111110 ; 0
	db 0b11111100 ; 1
	db 0b11111010 ; 2
	db 0b11111000 ; 3
	db 0b11110110 ; 4
	db 0b11110100 ; 5
	db 0b11110010 ; 6
	db 0b11110000 ; 7
	db 0b11101111 ; 8
	db 0b11001111 ; 9
	db 0b10101111 ; A
	db 0b10001111 ; B
	db 0b01101111 ; C
	db 0b01001111 ; D
	db 0b00101111 ; E
	db 0b00001111 ; F
	db 0b00101110 ; 0 + E

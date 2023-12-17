	section .text 

KEY_PLUS		equ	0x0A
KEY_MINUS		equ	0x0B
KEY_STAR		equ	0x0C
KEY_SLASH		equ	0x0D
KEY_POUND		equ	0x0E
KEY_DOT			equ	0x0F

KEY_MEM			equ	KEY_POUND
KEY_ALTER		equ	KEY_SLASH
KEY_REG			equ	KEY_DOT
KEY_RADIX		equ	0x03
KEY_GO			equ	0x04
KEY_RTM			equ	0x10

STATE_IDLE		equ	0
STATE_MEM_ADDR1		equ	0x10
STATE_MEM_ADDR2		equ	0x11
STATE_MEM_ADDR3		equ	0x12
STATE_MEM_ADDR4		equ	0x13
STATE_MEM_ADDR5		equ	0x14
STATE_MEM_ADDR6		equ	0x15
STATE_MEM_DISPLAY	equ	0x16

STATE_MEM_ALTER1	equ	0x17
STATE_MEM_ALTER2	equ	0x18
STATE_MEM_ALTER3	equ	0x19

STATE_REG_ALTER1	equ	0x20
STATE_REG_ALTER2	equ	0x21
STATE_REG_ALTER3	equ	0x22
STATE_REG_ALTER4	equ	0x23
STATE_REG_ALTER5	equ	0x24
STATE_REG_ALTER6	equ	0x25
STATE_REG_DISPLAY	equ	0x26

STATE_GROUP_MEM		equ	0x10
STATE_GROUP_REG		equ	0x20
STATE_GROUP_MASK	equ	0xF0

MON_REG_MAX		equ	6

SAVED_TRAP_FRAME_SIZE	equ	46

REG_SG	equ	0
REG_CS	equ	1
REG_IP	equ	2
REG_AX	equ	3
REG_BX	equ	4
REG_CX	equ	5
REG_DX	equ	6

TF_DS	equ	8
TF_DX	equ	6
TF_CX	equ	4
TF_BX	equ	2
TF_AX	equ	0
TF_IP	equ	0Ah
TF_CS	equ	0Ch

;------------------------------------------------------------------------------
; mon_keydown
;
; input:
;   al: keypad scancode

mon_keydown:
	cmp	byte [mon_state], STATE_IDLE
	jz	mon_state_idle
	cmp	byte [mon_state], STATE_MEM_ADDR1
	jz	mon_state_addr1
	cmp	byte [mon_state], STATE_MEM_ADDR2
	jz	mon_state_addr2
	cmp	byte [mon_state], STATE_MEM_ADDR3
	jz	mon_state_addr3
	cmp	byte [mon_state], STATE_MEM_ADDR4
	jz	mon_state_addr4
	cmp	byte [mon_state], STATE_MEM_ADDR5
	jz	mon_state_addr5
	cmp	byte [mon_state], STATE_MEM_ADDR6
	jz	mon_state_addr6
	cmp	byte [mon_state], STATE_MEM_DISPLAY
	jz	mon_state_mem_display
	cmp	byte [mon_state], STATE_MEM_ALTER1
	jz	mon_state_alter1
	cmp	byte [mon_state], STATE_MEM_ALTER2
	jz	mon_state_alter2
	cmp	byte [mon_state], STATE_MEM_ALTER3
	jz	mon_state_alter3
	cmp	byte [mon_state], STATE_REG_ALTER1
	jz	mon_state_reg_alter1
	cmp	byte [mon_state], STATE_REG_ALTER2
	jz	mon_state_reg_alter2
	cmp	byte [mon_state], STATE_REG_ALTER3
	jz	mon_state_reg_alter3
	cmp	byte [mon_state], STATE_REG_ALTER4
	jz	mon_state_reg_alter4
	cmp	byte [mon_state], STATE_REG_ALTER5
	jz	mon_state_reg_alter5
	cmp	byte [mon_state], STATE_REG_ALTER6
	jz	mon_state_reg_alter6
	cmp	byte [mon_state], STATE_REG_DISPLAY
	jz	mon_state_reg_display
	ret

mon_start:
	mov	ax, ds
	mov	[mon_seg], ax
	mov	ax, h8_count
	mov	[mon_addr], ax
	jmp	go_state_mem_display

go_state_mem_display:
    	mov	byte [h8_dots], 0
	mov	byte [mon_state], STATE_MEM_DISPLAY
    	ret

go_state_mem_addr:
	mov	byte [h8_dots], 1
	mov	byte [mon_state], STATE_MEM_ADDR1
	ret

go_state_mem_alter:
	mov	byte [h8_dots], 2
	mov	byte [mon_state], STATE_MEM_ALTER1
	ret

go_state_reg_display:
	mov	byte [h8_dots], 0
	mov	byte [mon_state], STATE_REG_DISPLAY
	ret

go_state_reg_alter:
	mov	byte [h8_dots], 2
	mov	byte [mon_state], STATE_REG_ALTER1
	ret


go_rtm:
	test	byte [h8_break], 1
	jz	go_rtm1
	ret
go_rtm1:
	mov	byte [h8_break], 1
	or	byte [h8_digsel_or], 0x20	; turn on monitor led

	;; TODO: stuff with the trap frame
	ret

rtm_loop:
    	jmp	rtm_loop

go_go:
	test	byte [h8_break], 1
	jnz	go_go1
	ret
go_go1:
	mov	byte [h8_break], 0
	and	byte [h8_digsel_or], ~0x20

	;; TODO: stuff with the trap frame
	ret

go_radix:
	mov	al, [h8_radix]
    	xor	al, 1
    	mov	[h8_radix], al
    	ret

;------------------------------------------------------------------------------
; mon_state_idle

mon_state_idle:
	cmp	al, KEY_MEM
	jz	go_state_mem_addr
	cmp	al, KEY_REG
	jz	go_state_reg_display
	cmp	al, KEY_RADIX
	jz	go_radix
mon_state_idle_not_radix:
	cmp	al, KEY_RTM
	jz	go_rtm
	cmp	al, KEY_GO
	jz	go_go
	ret

;------------------------------------------------------------------------------
; mon_state_addr1

mon_state_addr1:
	test	byte [h8_radix],1
	jnz	mon_state_addr1_hex
	cmp	al, 7
	jg	mon_state_addr_not_oct
	mov	ah, [mon_addr_hi]
	shl	ah, 3
	or	ah, al
	mov	[mon_addr_hi], ah
	mov	byte [mon_state], STATE_MEM_ADDR2
	ret
mon_state_addr1_hex:
	test	al, 0xFF
	jnz	mon_state_addr_not_oct		; first digit of hex entry must be 0
	mov	byte [mon_state], STATE_MEM_ADDR2
	ret

; all the addr states go here on fail
mon_state_addr_not_oct:
	cmp	al, KEY_ALTER
	jz	go_state_mem_alter
	cmp	al, KEY_MEM
	jz	go_state_mem_display		; cancel memory address entry
	jmp	mon_state_idle			; fall through to idle keypress processing

;------------------------------------------------------------------------------
; mon_state_addr2

mon_state_addr2:
	test	byte [h8_radix],1
	jnz	mon_state_addr2_hex
	cmp	al, 7
	jg	mon_state_addr_not_oct
	mov	ah, [mon_addr_hi]
	shl	ah, 3
	or	ah, al
	mov	[mon_addr_hi], ah
	mov	byte [mon_state], STATE_MEM_ADDR3
	ret
mon_state_addr2_hex:
	mov	ah, [mon_addr_hi]
	shl	ah, 3
	or	ah, al
	mov	[mon_addr_hi], ah
	mov	byte [mon_state], STATE_MEM_ADDR3
	ret

;------------------------------------------------------------------------------
; mon_state_addr3

mon_state_addr3:
	test	byte [h8_radix],1
	jnz	mon_state_addr3_hex
	cmp	al, 7
	jg	mon_state_addr_not_oct
	mov	ah, [mon_addr_hi]
	shl	ah, 3
	or	ah, al
	mov	[mon_addr_hi], ah
	mov	byte [mon_state], STATE_MEM_ADDR4
	ret
mon_state_addr3_hex:
	mov	ah, [mon_addr_hi]
	shl	ah, 3
	or	ah, al
	mov	[mon_addr_hi], ah
	mov	byte [mon_state], STATE_MEM_ADDR4
	ret

;------------------------------------------------------------------------------
; mon_state_addr4

mon_state_addr4:
	test	byte [h8_radix],1
	jnz	mon_state_addr4_hex
	cmp	al, 7
	jg	mon_state_addr_not_oct
	mov	ah, [mon_addr_lo]
	shl	ah, 3
	or	ah, al
	mov	[mon_addr_lo], ah
	mov	byte [mon_state], STATE_MEM_ADDR5
	ret
mon_state_addr4_hex:
	mov	ah, [mon_addr_lo]
	shl	ah, 3
	or	ah, al
	mov	[mon_addr_lo], ah
	mov	byte [mon_state], STATE_MEM_ADDR5
	ret

;------------------------------------------------------------------------------
; mon_state_addr5

mon_state_addr5:
	test	byte [h8_radix],1
	jnz	mon_state_addr5_hex
	cmp	al, 7
	jg	mon_state_addr_not_oct
	mov	ah, [mon_addr_lo]
	shl	ah, 3
	or	ah, al
	mov	[mon_addr_lo], ah
	mov	byte [mon_state], STATE_MEM_ADDR6
	ret
mon_state_addr5_hex:
	mov	ah, [mon_addr_lo]
	shl	ah, 3
	or	ah, al
	mov	[mon_addr_lo], ah
	jmp	go_state_mem_display
	ret

;------------------------------------------------------------------------------
; mon_state_addr6

mon_state_addr6:
	cmp	al, 7
	jg	mon_state_addr_not_oct
	mov	ah, [mon_addr_lo]
	shl	ah, 3
	or	ah, al
	mov	[mon_addr_lo], ah
	jmp	go_state_mem_display
	ret

;------------------------------------------------------------------------------
; mon_state_mem_display

mon_state_mem_display:
	cmp	al, KEY_PLUS
	jnz	mon_state_mem_display_not_plus
	inc	word [mon_addr]
	ret
mon_state_mem_display_not_plus:
	cmp	al, KEY_MINUS
	jnz	mon_state_mem_display_not_minus
	dec	word [mon_addr]
	ret
mon_state_mem_display_not_minus:
	cmp	al, KEY_ALTER
	jnz	mon_state_mem_display_not_alter
	jmp	go_state_mem_alter
mon_state_mem_display_not_alter:
	jmp	mon_state_idle

;------------------------------------------------------------------------------
; mon_state_alter1

mon_state_alter1:
	test	byte [h8_radix],1
	jnz	mon_state_alter1_hex
	cmp	al, 7
	jg	mon_state_alter_not_oct
	call	mon_alter
	mov	byte [mon_state], STATE_MEM_ALTER2
	ret
mon_state_alter1_hex:
	test	al, 0xFF
	jnz	mon_state_alter_not_oct		; first digit of hex entry must be 0
	mov	byte [mon_state], STATE_MEM_ALTER2
	ret

; all the alter states go here on fail
mon_state_alter_not_oct:
	cmp	al, KEY_ALTER
	jz	go_state_mem_display
	jmp	mon_state_idle			; fall through to idle keypress processing

;------------------------------------------------------------------------------
; mon_state_alter2

mon_state_alter2:
	test	byte [h8_radix],1
	jnz	mon_state_alter2_hex
	cmp	al, 7
	jg	mon_state_alter_not_oct
	call	mon_alter
	mov	byte [mon_state], STATE_MEM_ALTER3
	ret
mon_state_alter2_hex:
	call	mon_alter
	mov	byte [mon_state], STATE_MEM_ALTER3
	ret

;------------------------------------------------------------------------------
; mon_state_alter3

mon_state_alter3:
	test	byte [h8_radix],1
	jnz	mon_state_alter3_hex
	cmp	al, 7
	jg	mon_state_alter_not_oct
	call	mon_alter
	inc	word [mon_addr]
	mov	byte [mon_state], STATE_MEM_ALTER1
	ret
mon_state_alter3_hex:
	call	mon_alter
	inc	word [mon_addr]
	mov	byte [mon_state], STATE_MEM_ALTER1
	ret

;------------------------------------------------------------------------------
; mon_alter

mon_alter:
	push	ds
	mov	dx, word [mon_seg]
	mov	bx, word [mon_addr]
	mov	ds, dx
	mov	ah, [bx]
	pop	ds
	test	byte [h8_radix], 1
	jz	mon_state_alter_oct
	shl	ah,1			; hex needs one more shift than octal
mon_state_alter_oct:
	shl	ah,3
	or	ah,al
	push	ds
	mov	ds,dx
	mov	[bx],ah
	pop	ds
	ret

;------------------------------------------------------------------------------
; mon_alter_reg_lo

mon_alter_reg_lo:
	call	mon_get_reg_addr
	mov	ah, [bx]
	test	byte [h8_radix], 1
	jz	mon_state_alter_reg_lo_oct
	shl	ah,1			; hex needs one more shift than octal
mon_state_alter_reg_lo_oct:
	shl	ah,3
	or	ah,al
	mov	[bx],ah
	ret

;------------------------------------------------------------------------------
; mon_alter_reg_hi

mon_alter_reg_hi:
	call	mon_get_reg_addr
	inc	bx
	mov	ah, [bx]
	test	byte [h8_radix], 1
	jz	mon_state_alter_reg_hi_oct
	shl	ah,1			; hex needs one more shift than octal
mon_state_alter_reg_hi_oct:
	shl	ah,3
	or	ah,al
	mov	[bx],ah
	ret

;------------------------------------------------------------------------------
; mon_state_reg_alter1

mon_state_reg_alter1:
	test	byte [h8_radix],1
	jnz	mon_state_reg_alter1_hex
	cmp	al, 7
	jg	mon_state_reg_alter_not_oct
	call	mon_alter_reg_hi
	mov	byte [mon_state], STATE_REG_ALTER2
	ret
mon_state_reg_alter1_hex:
	test	al, 0xFF
	jnz	mon_state_reg_alter_not_oct		; first digit of hex entry must be 0
	mov	byte [mon_state], STATE_REG_ALTER2
	ret

; all the addr states go here on fail
mon_state_reg_alter_not_oct:
	cmp	al, KEY_ALTER
	jz	go_state_reg_display
	jmp	mon_state_idle			; fall through to idle keypress processing

;------------------------------------------------------------------------------
; mon_state_reg_alter2

mon_state_reg_alter2:
	test	byte [h8_radix],1
	jnz	mon_state_reg_alter2_hex
	cmp	al, 7
	jg	mon_state_reg_alter_not_oct
	call	mon_alter_reg_hi
	mov	byte [mon_state], STATE_REG_ALTER3
	ret
mon_state_reg_alter2_hex:
	call	mon_alter_reg_hi
	mov	byte [mon_state], STATE_REG_ALTER3
	ret

;------------------------------------------------------------------------------
; mon_state_reg_alter3

mon_state_reg_alter3:
	test	byte [h8_radix],1
	jnz	mon_state_reg_alter3_hex
	cmp	al, 7
	jg	mon_state_reg_alter_not_oct
	call	mon_alter_reg_hi
	mov	byte [mon_state], STATE_REG_ALTER4
	ret
mon_state_reg_alter3_hex:
	call	mon_alter_reg_hi
	mov	byte [mon_state], STATE_REG_ALTER4
	ret

;------------------------------------------------------------------------------
; mon_state_reg_alter4

mon_state_reg_alter4:
	test	byte [h8_radix],1
	jnz	mon_state_reg_alter4_hex
	cmp	al, 7
	jg	mon_state_reg_alter_not_oct
	call	mon_alter_reg_lo
	mov	byte [mon_state], STATE_REG_ALTER5
	ret
mon_state_reg_alter4_hex:
	call	mon_alter_reg_lo
	mov	byte [mon_state], STATE_REG_ALTER5
	ret

;------------------------------------------------------------------------------
; mon_state_reg_alter5

mon_state_reg_alter5:
	test	byte [h8_radix],1
	jnz	mon_state_reg_alter5_hex
	cmp	al, 7
	jg	mon_state_reg_alter_not_oct
	call	mon_alter_reg_lo
	mov	byte [mon_state], STATE_REG_ALTER6
	ret
mon_state_reg_alter5_hex:
	call	mon_alter_reg_lo
	jmp	go_state_reg_display
	ret

;------------------------------------------------------------------------------
; mon_state_reg_alter6

mon_state_reg_alter6:
	cmp	al, 7
	jg	mon_state_reg_alter_not_oct
	call	mon_alter_reg_lo
	jmp	go_state_reg_display
	ret

;------------------------------------------------------------------------------
; mon_state_reg_display

mon_state_reg_display:
	cmp	al, KEY_PLUS
	jnz	mon_state_reg_display_not_plus
	cmp	byte [mon_reg_index], MON_REG_MAX
	jnz	not_overflow
	ret
not_overflow:
	inc	byte [mon_reg_index]
	ret
mon_state_reg_display_not_plus:
	cmp	al, KEY_MINUS
	jnz	mon_state_reg_display_not_minus
	test	byte [mon_reg_index], 0xFF
	jnz	not_underflow
	ret
not_underflow:
	dec	byte [mon_reg_index]
	ret
mon_state_reg_display_not_minus:
	cmp	al, KEY_ALTER
	jnz	mon_state_reg_display_not_alter
	jmp	go_state_reg_alter
mon_state_reg_display_not_alter:
	jmp	mon_state_idle

;------------------------------------------------------------------------------
; mon_get_reg_addr
;
; output
;    BX: address of register in frame

mon_get_reg_addr:
	cmp	word [mon_reg_index], 0
	jnz	not_sg
	mov	bx, mon_regs			; point to where the pseudo-regs are
	add	bx, [mon_reg_index]		; add index*2 to the address
	add	bx, [mon_reg_index]
	ret
not_sg:
	mov	bx, [mon_tf_addr]
	mov	dl, byte [mon_reg_index]
	cmp	dl, REG_AX
	jnz	not_ax
	add	bx, TF_AX
	ret
not_ax:
	cmp	dl, REG_BX
	jnz	not_bx
	add	bx, TF_BX
	ret
not_bx:
	cmp	dl, REG_CX
	jnz	not_cx
	add	bx, TF_CX
	ret
not_cx:
	cmp	dl, REG_DX
	jnz	not_dx
	add	bx, TF_DX
	ret
not_dx:
	cmp	dl, REG_CS
	jnz	not_cs
	add	bx, TF_CS
	ret
not_cs:
	cmp	dl, REG_IP
	jnz	not_ip
	add	bx, TF_IP
	ret
not_ip:
	mov	bx, 0				; Uh oh
	ret

;------------------------------------------------------------------------------
; mon_update

mon_update:
	mov	al, byte [mon_state]
	and	al, STATE_GROUP_MASK
	cmp	al, STATE_GROUP_MEM
	jz	mon_update_mem_display
	cmp	al, STATE_GROUP_REG
	jz	mon_update_reg_display
	jmp	mon_update_dots

mon_update_mem_display:
	mov	ax, word [mon_addr]
	call	h8_set_octal_addr

	mov	dx, word [mon_seg]
	mov	bx, word [mon_addr]
	push    ds
	mov	ds, dx
	mov	al, [bx]
	pop	ds
	call	h8_set_octal_r
	jmp	mon_update_dots

mon_update_reg_display:
	call	mon_get_reg_addr
	mov	ax, [bx]
	call	h8_set_octal_addr
	mov	al, [mon_reg_index]
	call	h8_set_reg_r
	jmp	mon_update_dots

mon_update_dots:
	mov	bx, h8_digits		; BX holds pointer to digits
	mov	ah, 9			; AH is number of digits to update
	mov	al, byte [h8_dots]	; AL is h8_dots
	test	al, 0xFF
	jnz	mon_update_dots0
	ret				; no dots to light
mon_update_dots0:
	cmp	al,1			; 1 is to rotate the dots
	jnz	mon_update_dots_check2
mon_update_dots1:
	and	byte [bx], 0x7F		; set the dot on each digit
	inc	bx
	dec	ah
	jnz	mon_update_dots1	; all 9 of them
	ret
mon_update_dots_check2:
	mov	al, byte [h8_dotpos]	; AL is h8_dotpos
	dec	al			; move left one
	jnz	mon_dotpos_nowrap
	mov	al, 9			; we wrapped
mon_dotpos_nowrap:
	mov	byte [h8_dotpos], al	; save AL to h8_dotpos
mon_update_dots2:
	cmp	ah, al			; is this the dot we're lighting?
	jz	mon_update_dots_at_pos	; yes
	inc	bx
	dec	ah
	jnz	mon_update_dots2	; keep going
	ret
mon_update_dots_at_pos:
	and	byte [bx], 0x7F		; set the dot on the digit
	ret

;------------------------------------------------------------------------------
	section .data

mon_regs:            ; place to hold pseudo-registers
mon_seg:
mon_seg_l:
	db 	0x00
mon_seg_h:
	db	0x00


mon_reg_index:
	db	0x00, 0x00

mon_state:
	db	STATE_MEM_DISPLAY

mon_addr:
mon_addr_lo:
	db 	0o321
mon_addr_hi:
	db 	0o123

mon_tf_addr:
	dw	0x00

	section .bss

;;mon_saved_trap_frame:
;;	resb	46  ;  SAVED_TRAP_FRAME_SIZE
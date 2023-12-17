	section .data

h8_count:
h8_count_lo:	dw	0
h8_count_hi:	dw	0

digindex:
	db 	1
h8_digits0:
	db 	0x00           		; dummy placeholder since first digit starts at 1
h8_digits:                           	; some non-random gibberish pattern for now
h8_digits_l:
	db 	0x1
	db 	0x2
	db 	0x4
h8_digits_m:
	db 	0x8
	db 	0x10
	db 	0x20
h8_digits_r:
	db 	0x40
	db 	0x80
	db 	0x1F

h8_break:
	db	0x00

h8_radix:
	db	0x00

h8_dots:
	db	0x00

h8_dotpos:
	db	0x01

h8_digsel_or:
	db	0b11010000		; refresh and speaker bits on, int 20 single step off, monitor off

key_last:
    	db	0xFF
key_same_count:
	db	0x00

mon_regs:            			; place to hold pseudo-registers
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
	

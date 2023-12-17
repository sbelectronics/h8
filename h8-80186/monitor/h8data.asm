;;	section .bss
	absolute 0xD0

h8_data_seg	equ	0x40	; put it in the BIOS Data Area (BDA)

h8_count:	
	resb	2

digindex:	
	resb	1
h8_digits0:
	resb	1      		; dummy placeholder since first digit starts at 1
h8_digits:
h8_digits_l:
	resb	1
	resb	1
	resb	1
h8_digits_m:
	resb	1
	resb	1
	resb	1
h8_digits_r:
	resb	1
	resb	1
	resb	1

h8_break:
	resb	1

h8_radix:
	resb	1

h8_dots:
	resb	1

h8_dotpos:
	resb	1

h8_digsel_or:
	resb	1		; refresh and speaker bits on, int 20 single step off, monitor off

key_last:
    	resb	1
key_same_count:
	resb	1

mon_regs:            			; place to hold pseudo-registers
mon_seg:
mon_seg_l:
	resb	1
mon_seg_h:
	resb	1


mon_reg_index:
	resb	1

mon_state:
	resb	1

mon_addr:
mon_addr_lo:
	resb	1
mon_addr_hi:
	resb	1

mon_tf_addr:
	resb	2



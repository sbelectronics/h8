sndport equ 11H

SNDINIT:
	jmp SND_QUIET

SND_QUIET:
	mvi a, 09FH
	out sndport
	mvi a, 0BFH
	out sndport
	mvi a, 0DFH
	out sndport
	mvi a, 0FFH
	out sndport
	ret

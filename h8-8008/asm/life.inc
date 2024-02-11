CONWAY_HI  equ PAGE1

;; coldec and colinc destroy C

coldec     macro
           mov a,l
           ani 0C0H
           mov c,a                              ; C has bits 7,6 of L

           mov a,l
           sui 1
           ani 03FH
           ora c
           mov l,a
           endm

colinc     macro
           mov a,l
           ani 0C0H
           mov c,a                              ; C has bits 7,6 of L

           mov a,l
           adi 1
           ani 03FH
           ora c
           mov l,a
           endm

rowdec     macro
           mov a,l
           sui 040H
           mov l,a
           mov a,h
           sbi 0H
           cpi CONWAY_HI-1
           jnz nowrap
           mvi a,CONWAY_HI+5
nowrap:
           mov h,a
           endm

rowinc     macro
           mov a,l
           adi 040H
           mov l,a
           mov a,h
           aci 0H
           cpi CONWAY_HI+6
           jnz nowrap
           mvi a,CONWAY_HI
nowrap:
           mov h,a
           endm

; -----------------------------------------------------------
; conway_reset - clear the grid
; -----------------------------------------------------------

conway_reset:
          mvi h,CONWAY_HI
          mvi l,0
          mvi c,00EH                           ; Clear 8 blocks on the first page and 6 on the second
conway_reset_loop:
          mvi m,0
          inr l
          jnz conway_reset_loop
          inr h
conway_reset_nowrap:
          dcr c
          jnz conway_reset_loop

          ;; load a glider

          mvi h,(CONWAY_HI | 08H)               ; put the glider in the new screen
          mvi l,001H
          mvi m,1
          mvi l,042H
          mvi m,1
          mvi l,080H
          mvi m,1
          mvi l,081H
          mvi m,1
          mvi l,082H
          mvi m,1
          ret

; -----------------------------------------------------------
; conway_copy - copy new to old, and output to screen
; -----------------------------------------------------------

conway_copy:
        mvi h, (CONWAY_HI | 008H)
        mvi l,0
        call conway_copy_block
        call conway_copy_block
        call conway_copy_block
        call conway_copy_block
        call conway_copy_block
        call conway_copy_block
        ret

conway_copy_block:
        mvi d,04H                               ; 4 rows
conway_copy_loopr:
        mvi c,040H                              ; 64 columns
conway_copy_loopc:
        mov a,m
        ora a
        jnz conway_copy_alive
        mvi a,' '
        call CPRINT
        mvi b,0
        jmp conway_copy_set
conway_copy_alive:
        mvi a,'*'
        call CPRINT
        mvi b,1
conway_copy_set:
        mov a,h
        ani 0F7H                                 ; copy to old
        mov h,a
        mov m,b
        ori 08H                                 ; set H back to new
        mov h,a
        inr l
        jnz conway_copy_nowrap
        inr h
conway_copy_nowrap:
        dcr c
        jnz conway_copy_loopc
        mvi a,'\r'
        call CPRINT
        mvi a,'\n'
        call CPRINT
        dcr d
        jnz conway_copy_loopr
        ret

; -----------------------------------------------------------
; conway_fcopy - copy new to old, but no screen output
; -----------------------------------------------------------

conway_fcopy:
        mvi h, (CONWAY_HI | 008H)
        mvi l,0
        call conway_fcopy_block
        call conway_fcopy_block
        call conway_fcopy_block
        call conway_fcopy_block
        call conway_fcopy_block
        call conway_fcopy_block
        ret

conway_fcopy_block:
        mov d,h                                 ; D holds src page (new)
        mov a,h
        ani 0F7H
        mov e,a                                 ; E holds dest page (old)
conway_fcopy_loop:
        mov h,d
        mov b,m
        mov h,e
        mov m,b
        inr l
        jnz conway_fcopy_loop
        mov h,d
        inr h
        ret

; -----------------------------------------------------------
; conway_print - just the screen output
; -----------------------------------------------------------

conway_print:
        mvi h, CONWAY_HI
        mvi l, 0
        call conway_print_block
        call conway_print_block
        call conway_print_block
        call conway_print_block
        call conway_print_block
        call conway_print_block
        ret

; -----------------------------------------------------------
; conway_print_block - just the screen output
; -----------------------------------------------------------

conway_print_Block:
        mvi d,04H                               ; 4 rows
conway_print_loopr:
        mvi c,040H                              ; 64 columns
conway_print_loopc:
        mov a,m
        ora a
        jnz conway_print_alive
        mvi a,' '
        call CPRINT
        mvi b,0
        jmp conway_print_next
conway_print_alive:
        mvi a,'*'
        call CPRINT
        mvi b,1
conway_print_next:
        inr l
        jnz conway_print_nowrap
        inr h
conway_print_nowrap:
        dcr c
        jnz conway_print_loopc
        mvi a,'\r'
        call CPRINT
        mvi a,'\n'
        call CPRINT
        dcr d
        jnz conway_print_loopr
        ret

; -----------------------------------------------------------
; conway_full - update the full conway grid
; -----------------------------------------------------------

conway_full:
           mvi d, CONWAY_HI
           mvi e, 0
           call conway_block
           call conway_block
           call conway_block
           call conway_block
           call conway_block
           call conway_block
           ret

; -----------------------------------------------------------
; conway_block - compute 4 rows by 64 columns
;
; input: DE = address of start of first row
; output: DE = address of start of next block
; destroys: A,B,C,H,L
; -----------------------------------------------------------

conway_block:                                   ; D,E = conway address
conway_loop:
           mov a,e
           out LEDPORT                          ; for debugging

           mov h,d
           mov l,e
           mov a,m

           ora a
           jz dead
alive:
           call conway_cell
           mov a,b
           cpi 2                                ; exactly 2 neighbors?
           jz stayalive
           cpi 3                                ; exactly 2 neighbors?
           jz stayalive
           mvi b,0
           jmp update
stayalive: mvi b,1
           jmp update
dead:
           call conway_cell
           mov a,b
           cpi 3                                ; are there exactly 3 neighbors
           jnz staydead
           mvi b,1
           jmp update
staydead:  mvi b,0
update:                                         ; b==0 if dead, b==1 if alive
           mov a,d
           ori 08H                              ; go forward 2K
           mov h,a
           mov l,e
           mov m,b                              ; store the new cell

           inr e
           jnz conway_loop                      ; do all 256 entries in the block

           inr d                                ; at the end of the loop, we wrapped so increment d

           ret
           
; -----------------------------------------------------------
; conway_cell - compute one conway cell
;
; input: HL = address of cell
; output: B = number of neighbors
; destroys: A,B,H,L
; -----------------------------------------------------------

           ;; destroys a,b,h,l

conway_cell:  
           coldec                               ; (R-1, C-1)
           rowdec
           mov a,m
           mov b,a

           colinc                               ; (R-1, C)
           mov a,m
           add b
           mov b,a

           colinc                               ; (R-1, C+1)
           mov a,m
           add b
           mov b,a

           rowinc                               ; (R, C+1)
           mov a,m
           add b
           mov b,a

           coldec                               ; (R, C-1)
           coldec
           mov a,m
           add b
           mov b,a

           rowinc                               ; (R+1,C-1)
           mov a,m
           add b
           mov b,a

           colinc                               ; (R+1, C)
           mov a,m
           add b
           mov b,a

           colinc                               ; (R+1, C+1)
           mov a,m
           add b
           mov b,a
           ret

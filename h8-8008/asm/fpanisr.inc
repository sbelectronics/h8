;--------------------------------------------------------------------------------
;
;--------------------------------------------------------------------------------

int_ie     equ 0AH
int_di     equ 0BH

;--------------------------------------------------------------------------------
; STARTINT - install interrupt handler and enable interrupts
;--------------------------------------------------------------------------------

STARTINT:  mvi h,0
           mvi l,08H

           mvi m,044H
           inr l
           mvi m,lo(FPANISR)
           inr l
           mvi m,hi(FPANISR)

           out int_ie
           ret

;--------------------------------------------------------------------------------
; FPANISR - real front panel interrupt. Just increments the LEDs on port 09H
;--------------------------------------------------------------------------------

           ifndef binisr

FPANISR:   out stack_push       ; push A
           mov a,b
           out stack_push       ; push B
           ;mov a,c             ; we don't modify C/D/E, so don't push them
           ;out stack_push
           ;mov a,d
           ;out stack_push
           ;mov a,e
           ;out stack_push
           mov a,h
           out stack_push       ; push H
           mov a,l
           out stack_push       ; push L
           mvi a,0
           rar
           jz gsave3
           mvi b,078H
           jm gsave1
           mvi b,018H
gsave1:    jpe gsave2
           ori 04H
gsave2:    ora b
gsave3:    out stack_push       ; push flags

           mvi h,hi(mcounter)   ; this is our H for the whole of FPANISR

           mvi l,lo(mcounter)   ; increment a counter and output it to ledport
           mov a,m              ; ... this will be a good indicator the ISR works
           adi 1
           mov m,a
           out LEDPORT

           ;; now do our front panel digit refresh. This is copied from
           ;; fpanel.inc

           mvi l,lo(mdigindex)
           mov a,m
           mov b,a              ; save a copy of mdigindex in b

           ; bit7 0 should turn on speaker
           ; bit6 1 should turn on int10 refresh
           ; bit5 1 should turn on monitor led
           ; bit4 0 will turn on single-step
           ori 0F0H
           out fp_digsel

           mov a,b                ; b still holds mdigindex; m is still pointing at mdigindex
           sui 1H                 ; subtract for next digit
           jnz fpinowrap
           mvi a,9H               ; wrap back up to 9
fpinowrap:
           mov m,a                ; store it back

           mvi a,lo(m_dig)        ; now we need to index m_dig[a] and read it
           add b
           mov l,a                ; hl has address of value
           mov a,m                ; a now has value
           out fp_digval

           ;; We don't have time left to really do much else. We could refresh the digits
           ;; but we don't have enough cycle budget to do the binary-to-octal conversion,
           ;; or the memory lookup, or the keyboard handling.

FPANRET:   in stack_pop           ; pop flags
           add a                  ; adding A to itself sets all the flag bits
           in stack_pop           ; pop L
           mov l,a
           in stack_pop           ; pop H
           mov h,a
           ;in stack_pop
           ;mov e,a
           ;in stack_pop
           ;mov d,a
           ;in stack_pop
           ;mov c,a
           in stack_pop           ; pop B
           mov b,a
           in stack_pop           ; pop A
           out int_ie             ; enable interrupts
           ret

           endif



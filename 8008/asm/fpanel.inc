             ifndef   fpanelinc    ; avoid multiple inclusion
fpanelinc    equ      1

FPANINIT:
           mvi h,hi(maddr)      ; Put the address of mcounter into maddr
           mvi l,lo(maddr)
           mvi a,lo(mcounter)
           mov m,a
           inr l
           mvi a,hi(mcounter)
           mov m,a

           mvi h,hi(mdigindex)  ; Set digit index to 9
           mvi l,lo(mdigindex)
           mvi a,9H
           mov m,a

           mvi h,hi(m_dig_l)     ; Put a test pattern into m_digits
           mvi l,lo(m_dig_l)     ; 123, 456, 701
           mvi a,081H            ; 0
           mov m,a
           inr l
           mvi a,0F3H            ; 1
           mov m,a
           inr l
           mvi a,0C8H            ; 2
           mov m,a
           inr l
           mvi a,0E0H            ; 3
           mov m,a
           inr l
           mvi a,0B2H            ; 4
           mov m,a
           inr l
           mvi a,0A4H            ; 5
           mov m,a
           inr l
           mvi a,084H            ; 6
           mov m,a
           inr l
           mvi a,0F1H            ; 7
           mov m,a
           inr l
           mvi a,080H            ; 8
           mov m,a

           mvi a,0f0H             ; turn on fp interrupt
           out fp_digsel
           ret

           ; destroys A and B

FPANPOLL:
           mov a,h
           mov b,l
           mvi h,hi(msave_H)      ; and set H to storage area page           
           mvi l,lo(msave_H)      ; now set L to temporary storage locations
           mov m,a                ; save A (entry value of H) in memory
           inr l                  ; advance pointer
           mov m,b                ; save B (entry value of L) in memory
           inr l
           ;mov m,b               ; no need to store b since we've destroyed it already
           inr l
           mov m,c
           inr l
           mov m,d
           inr l
           mov m,e

           mvi h,hi(mdigindex)  ; get the digit index into a
           mvi l,lo(mdigindex)
           mov a,m
           mov d,a              ; save a copy of mdigindex in d

           ; bit7 0 should turn on speaker
           ; bit6 1 should turn on int10 refresh
           ; bit5 1 should turn on monitor led
           ; bit4 0 will turn on single-step
           ori 0F0H
           out fp_digsel

           mov a,d              ; d still holds mdigindex; m is still pointing at mdigindex
           sui 1H               ; subtract for next digit
           jnz nowrap
           mvi a,9H             ; wrap back up to 9
nowrap:
           mov m,a              ; store it back

           mvi h,hi(m_dig)
           mvi l,lo(m_dig)
           mov a,l
           add d
           mov l,a                ; hl has address of value
           mov a,m                ; a now has value
           out fp_digval

FPANOUT:
           mvi h,hi(msave_H)      ; and set H to storage area page           
           mvi l,lo(msave_H)      ; now set L to temporary storage locations
           mov a,m
           inr l
           mov b,m
           inr l
           ;mov b,m                ; don't restore b as we're using it to hold e
           inr l
           mov c,m
           inr l
           mov d,m
           mov h,a
           mov l,b
           ret

digit_7seg:
           db 081H  ;  0b10000001  ! 0
           db 0F3H  ;  0b11110011  ! 1
           db 0C8H  ;  0b11001000  ! 2
           db 0E0H  ;  0b11100000  ! 3
           db 0B2H  ;  0b10110010  ! 4
           db 0A4H  ;  0b10100100  ! 5
           db 084H  ;  0b10000100  ! 6
           db 0F1H  ;  0b11110001  ! 7
           db 080H  ;  0b10000000  ! 8
           db 0A0H  ;  0b11001111  ! 9
           db 090H  ;  0b10010000  ! A
           db 086H  ;  0b10000110  ! B
           db 08DH  ;  0b10001101  ! C
           db 0C2H  ;  0b11000010  ! D
           db 08CH  ;  0b10001100  ! E
           db 09CH  ;  0b10011100  ! F

            endif                ; fpanelinc
;-----------------------------------------------
; fpanel.inc - front panel for H8
;
; Scott Baker, http://www.smbaker.com/
;
; Implements front panel for H8 panel monitor.
; No interrupts are used. This is all implemented
; from inside FPCINP450, the routine that reads
; from the 16450 serial port.
;
; Not one call is present in this file.
; Not even one.
; This is so we don't have to take stack budget
; away from the caller of FPCINP450.
;-----------------------------------------------

             ifndef   fpanelinc    ; avoid multiple inclusion
fpanelinc    equ      1

dig01      equ 018H
dig23      equ 019H
dig45      equ 01AH
dig67      equ 01BH
dig89      equ 01CH
fpdot0     equ 01DH
fpblank0   equ 01EH
fpdotblk8  equ 01FH

_sc0       equ 0FEH ; 11111110 ! 0
sc1        equ 0FCH ; 11111100 ! 1
sc2        equ 0FAH ; 11111010 ! 2
sc3        equ 0F8H ; 11111000 ! 3
sc4        equ 0F6H ; 11110110 ! 4
sc5        equ 0F4H ; 11110100 ! 5
sc6        equ 0F2H ; 11110010 ! 6
sc7        equ 0F0H ; 11110000 ! 7
sc8        equ 0EFH ; 11101111 ! 8
sc9        equ 0CFH ; 11001111 ! 9
scA        equ 0AFH ; 10101111 ! A, minus
scB        equ 08FH ; 10001111 ! B, plus
scC        equ 06FH ; 01101111 ! C
_scD       equ 04FH ; 01001111 ! D
_scE       equ 02FH ; 00101111 ! E
_scF       equ 00FH ; 00001111 ! F
scG        equ 02EH ; 00101110 ! 0 + E

; I messed up the placement on the frontpanel boards
sc0        equ _scD
scD        equ _scE
scE        equ _scF
scF        equ _sc0

scPlus     equ scA
scMinus    equ scB
scMem      equ scE
scAlter    equ scD
scCancel   equ scC
scIn       equ sc5
scOut      equ sc6

stateDisp  equ 000H

stateAddr1 equ 010H
stateAddr2 equ 011H
stateAddr3 equ 012H
stateAddr4 equ 013H
stateAddr5 equ 014H
stateAddr6 equ 015H
stateAddrO equ 016H
maskAddr   equ 010H

stateAlt1  equ 020H
stateAlt2  equ 021H
stateAlt3  equ 022H
stateAltO  equ 023H
maskAlt    equ 020H

bitDig8Enable equ 010H
bitDig9Enable equ 020H
bitFpEnable equ 080H

                ifndef TIL311

BL0_DISABLE     equ 000H
DOT0_DISABLE    equ 000H
DOTBL8_DISABLE  equ 000H

BL0_ENABLE      equ 0F7H
DOT0_ALLOFF     equ 000H
DOTBL8_ENABLE   equ bitDig8Enable | bitDig9Enable | bitFpEnable

                else

                ;; the TIL blanking and dot logic is inverted from the DM9368
                ;; blanking and dot logic. Bah!

BL0_DISABLE     equ 0FFH
DOT0_DISABLE    equ 0FFH
DOTBL8_DISABLE  equ 0FFH

BL0_ENABLE      equ lo(~0F7H)
DOT0_ALLOFF     equ 0FFH
DOTBL8_ENABLE   equ lo(~(bitDig8Enable | bitDig9Enable)) | bitFpEnable

                endif

FPANINIT:
           mvi h,hi(maddr)      ; Put the address of mcounter into maddr
           mvi l,lo(maddr)
           mvi a,lo(mcounter)+1
           mov m,a
           inr l
           mvi a,hi(mcounter)
           mov m,a

           mvi l,lo(mcounter)    ; zero the counter
           mvi m,0
           inr l
           mvi m,0
           inr l
           mvi m,0
           inr l
           mvi m,0

           mvi l,lo(m_lastkey)
           mvi m,0H

           mvi l,lo(m_lastcnt)
           mvi m,0H

           mvi l,lo(m_state)
           mvi m,stateDisp

           jmp FPENABLE

FPDISABLE: mvi a, BL0_DISABLE
           out fpblank0
           mvi a, DOT0_DISABLE
           out fpdot0
           mvi a, DOTBL8_DISABLE
           out fpdotblk8
           ret

FPENABLE:  mvi a, BL0_ENABLE
           out fpblank0 
           mvi a, DOT0_ALLOFF
           out fpdot0
           mvi a, DOTBL8_ENABLE
           out fpdotblk8
           ret

;--------------------------------------------------------------------------------
; FPANSVC service the front panel
;
; We fall through from the serial input function above.
;--------------------------------------------------------------------------------
        
FPANSVC:   in fp_kbd              ; this will reset the interrupt

           ;; update mcounter and do heavy lifting at the tail
           ;; this may cause us to take longer than refresh interval
           ;; ... and would cause display artifacts if done earlier
  
           mvi l,lo(mcounter)     ; get the address of the counter B0
           mov a,m
           adi 1                  ; increment low byte
           mov m,a                ; and store it
           jnz nocarry
           inr l                  ; point to B1
           mov a,m
           adi 1
           mov m,a
           jnz nocarry
           inr l                  ; point to B2
           mov a,m
           adi 1
           mov m,a
           jnz nocarry
           inr l                  ; point to B3
           mov a,m
           adi 1
           mov m,a
nocarry:
           mvi l,lo(mcounter)
           mov a,m
           ani 01FH
           jz FPANUPL             ; update left ... there is no middle anymore
           cpi 010H
           jz FPANUPR             ; update right
           cpi 018H
           jz FPUPDOTS

           jmp FPANRET           ; Nothing more to do -- go back to polling

FPANUPL:   ;; update the address octal group

           mvi l,lo(maddr)+1      ; load high byte of maddr into b
           mov b,m

           mov a,b
           rrc
           rrc
           ani 030H
           mov c,a                ; C has bits 7,6 shifted into upper nibble

           mov a,b                ; value into a
           rrc
           rrc
           rrc
           ani 07H                ; A has bits 5,4,3 shifted into lower nibble
           ora c
           out dig89              ; output 0 0 m7 m6 0 m5 m4 m3

           mov a,b
           rlc
           rlc
           rlc
           rlc
           ani 070H
           mov c,a                ; C has bits 2,1,0 shifted into upper nibble

           mvi l,lo(maddr)        ; load high byte of maddr into b
           mov b,m

           mov a,b
           rlc                    ; rotate around circular
           rlc
           ani 003H               ; A has bits 7,6 shifted into lower nibble
           ora c
           out dig67              ; output 0 m2 m1 m0 0 0 l7 l6

           mov a,b
           rlc
           ani 070H
           mov c,a               ; C has bits 5,4,3 shifted into upper nibble

           mov a,b
           ani 07H               ; A has bits 2,1,0 in lower nibble
           ora c
           out dig45             ; output 0 l5 l4 l3 0 l2 l1 l0

           jmp FPANRET

FPANUPR:   ;; update the value octal group

           mvi l,lo(maddr)        ; put the value in (maddr) into b
           mov a,m
           inr l
           mov h,m
           mov l,a
           mov b,m                ; B now has the data value

           mvi h,hi(maddr)        ; put h back to our work space

           mov a,b
           rlc                    ; rotate around circular
           rlc
           ani 003H               ; A has bits 7,6 shifted into lower nibble
           out dig23              ; output 0 0 0 0 0 0 l7 l6

           mov a,b
           rlc
           ani 070H
           mov c,a               ; C has bits 5,4,3 shifted into upper nibble

           mov a,b
           ani 07H               ; A has bits 2,1,0 in lower nibble
           ora c
           out dig01             ; output 0 l5 l4 l3 0 l2 l1 l0

           jmp FPANRET

;--------------------------------------------------------------
; FPUPDOTS - update the dots then fall through to keyboard scan
;--------------------------------------------------------------

FPUPDOTS:
           ;; fall through to FPSCANK

;--------------------------------------------------------------
; FPSCANK - keyboard scan
;--------------------------------------------------------------

FPSCANK:   in fp_kbd
           cpi 0FFH
           jz nokey                 ; Nothing to see here. Move along.
           mvi l,lo(m_lastkey)
           mov b,m
           mov m,a
           cmp b
           jnz diffkey              ; different key - handle it
           mvi l,lo(m_lastcnt)
           mov a,m
           cpi 05H                  ; have we seen it five times in a row
           jz enough                ; yeah
           adi 1
           mov m,a
           jmp FPANRET
enough:
           mvi l,lo(m_lastkey)      ; reset lastkey so we can repeat
           mvi m,0
           jmp FPANRET
nokey:
           mvi l,lo(m_lastkey)      ; make sure we're primed for the next key
           mvi m,0
           jmp FPANRET
diffkey:
           mvi l,lo(m_lastcnt)
           mvi m,0

;           mvi l,lo(m_lastkey)
;           mov b,m
;           in fp_kbd
;           cmp b
;           jz samekey              ; Is it the same key?
;           mov m,a                 ; Nope. Store it in lastkey
;           jmp FPANRET
;           mvi l,lo(m_lastcnt)     ; ... and reset lastcnt
;           mvi l,0
;           jmp FPANRET            ; Different key
;samekey:   mov b,a                 ; Save scancode in b
;           mvi l,lo(m_lastcnt)     ; Check how many times we've seen it
;           mov a,m
;           cpi 03H                 ; three is a good number
;           jz enough               ; we have enough?
;           adi 1                   ; inrement the count
;           mov m,a
;           jmp FPANRET            ; Wait until we see more
;enough:    mvi m,0                 ; reset lastcnt, to bound our repeat rate
;           mov a,b                 ; restore the scancode to b

           mov b,a                  ; save key in B
           mvi l,lo(m_state)        ; load the current state
           mov a,m

           ;; the addr states

           cpi stateAddr1
           jnz notAddr1
           mvi l,lo(maddr)+1
           jmp doEnter
notAddr1:
           cpi stateAddr2
           jnz notAddr2
           mvi l,lo(maddr)+1
           jmp doEnter
notAddr2:
           cpi stateAddr3
           jnz notAddr3
           mvi l,lo(maddr)+1
           jmp doEnter
notAddr3:
           cpi stateAddr4
           jnz notAddr4
           mvi l,lo(maddr)
           jmp doEnter
notAddr4:
           cpi stateAddr5
           jnz notAddr5
           mvi l,lo(maddr)
           jmp doEnter
notAddr5:
           cpi stateAddr6
           jnz notAddr6
           mvi l,lo(maddr)
           jmp doEnter
notAddr6:
           cpi stateAlt1
           jnz notAlter1
           jmp doAlter
notAlter1:
           cpi stateAlt2
           jnz notAlter2
           jmp doAlter
notAlter2:
           cpi stateAlt3
           jnz notAlter3
           jmp doAlter
notAlter3:
           ; default in state machine
           jmp doIdle

;--------------------------------------------------------------
; doCommon - process common keys like plus and minus
;--------------------------------------------------------------
doIdle:    mov a,b
           cpi scIn
           jz doIn
           cpi scOut
           jz doOut

           ;; fall through to doCommon

;--------------------------------------------------------------
; doCommon - process common keys like plus and minus
;--------------------------------------------------------------

doCommon:
           mov a,b            ; get key from b
           cpi scPlus
           jnz notplus
doPlus:
           mvi l,lo(m_state)  ; if we're part way through an alter or addr, reset to the beginning
           mov a,m
           ani 0F0H
           mov m,a

           mvi l,lo(maddr)
           mov a,m
           adi 1
           mov m,a
           jnz nowrapup
           inr l
           mov a,m
           adi 1
           mov a,m
nowrapup:
           jmp FPANRET

notplus:   cpi scMinus
           jnz notminus
doMinus:
           mvi l,lo(m_state)  ; if we're part way through an alter or addr, reset to the beginning
           mov a,m
           ani 0F0H
           mov m,a

           mvi l,lo(maddr)
           mov a,m
           sui 1
           mov m,a
           cpi 0FFH          ; use a jump carry instead?
           jnz nowrapdn
           inr l
           mov a,m
           sui 1
           mov a,m
nowrapdn:
           jmp FPANRET

notminus:  cpi scMem
           jnz notMem
           mvi l,lo(m_state)
           mvi m,stateAddr1
           jmp changeMode    ; change to Addr

notMem:    cpi scAlter
           jnz notAlter
           mvi l,lo(m_state)
           mvi m,stateAlt1
           jmp changeMode    ; change to Alter

notAlter:  cpi scCancel
           jnz notCancel
           mvi l,lo(m_state)
           mvi m,stateDisp   
           jmp changeMode    ; change to Display

notCancel:
           jmp FPANRET

;--------------------------------------------------------------
; doEnter - process entry of numbers to cell pointed by maddr
;--------------------------------------------------------------

doAlter:
           mvi l,lo(maddr)    ; deference maddr
           mov a,m
           inr l
           mov h,m
           mov l,a 

           jmp doEnter

;--------------------------------------------------------------
; doEnter - process entry of numbers to maddr
;--------------------------------------------------------------

doEnter:
           mov a,b            ; get key from b
           cpi sc0
           jnz notZero
           mvi b,0
           jmp gotNum
notZero:   cpi sc1
           jnz notOne
           mvi b,1
           jmp gotNum
notOne:    cpi sc2
           jnz notTwo
           mvi b,2
           jmp gotNum
notTwo:    cpi sc3
           jnz notThree
           mvi b,3
           jmp gotNum
notThree:  cpi sc4
           jnz notFour
           mvi b,4
           jmp gotNum
notFour:   cpi sc5
           jnz notFive
           mvi b,5
           jmp gotNum
notFive:   cpi sc6
           jnz notSix
           mvi b,6
           jmp gotNum
notSix:    cpi sc7
           jnz notSeven
           mvi b,7
           jmp gotNum
notSeven:
           mvi h,hi(m_state)   ; H might have been modified by doAlter. Restore it
           jmp doCommon        ; Give up
gotNum:    mov a,m
           rlc
           rlc
           rlc
           ani 0F8H
           ora b
           mov m,a

           ;; Now it's time to transition to the next state

           mvi h,hi(m_state)   ; H might have been modified by doAlter. Restore it
           mvi l,lo(m_state)   ; Load the state
           mov a,m
           adi 1               ; increment by 1
           mov m,a

           cpi stateAddrO      ; are we exiting Addr state?
           jnz notAddrO        ; Nope.
           mvi m,stateDisp     ; yes, enter display state
           jmp changeMode      ; change to display state
notAddrO:
           cpi stateAltO
           jnz notAltO
           mvi m,stateAlt1
           jmp doPlus          ; move to next memory cell
notAltO:
changeMode:
           jmp FPANRET

;--------------------------------------------------------------
; doOut - output to port. Uses the (val, addr) in maddr
;--------------------------------------------------------------

doOut:
           mvi l,lo(maddr)
           mov a,m                     ; port
           inr l
           mov b,m                     ; value

           mvi l,lo(m_codebuf)
           ani 00011111B               ; construct the "OUT" instruction
           rlc
           ori 01000001B
           mov m,a                     ; OUT<port>
           inr l
           mvi m,44H                   ; JMP
           inr l
           mvi m,lo(afterOut)          ; ... afterOut
           inr l
           mvi m,hi(afterOut)
           mov a,b                     ; put value back in a
           jmp m_codebuf
afterOut:
           jmp FPANRET

;--------------------------------------------------------------
; doInt - input port. Uses the (val, addr) in maddr
;--------------------------------------------------------------

doIn:
           mvi l,lo(maddr)
           mov a,m                    ; port

           mvi l,lo(m_codebuf)
           ani 00000111B
           rlc
           ori 01000001B
           mov m,a                    ; IN<port>
           inr l
           mvi m,44H                  ; JMP
           inr l
           mvi m,lo(afterIn)          ; ... afterOut
           inr l
           mvi m,hi(afterIn)
           jmp m_codebuf
afterIn:
           mvi l,lo(maddr)+1
           mov m,a
           jmp FPANRET

;dig_7seg_rom:
;           db 081H  ;  0b10000001  ! 0
;           db 0F3H  ;  0b11110011  ! 1
;           db 0C8H  ;  0b11001000  ! 2
;           db 0E0H  ;  0b11100000  ! 3
;           db 0B2H  ;  0b10110010  ! 4
;           db 0A4H  ;  0b10100100  ! 5
;           db 084H  ;  0b10000100  ! 6
;           db 0F1H  ;  0b11110001  ! 7
;           db 080H  ;  0b10000000  ! 8
;           db 0A0H  ;  0b11001111  ! 9
;           db 090H  ;  0b10010000  ! A
;           db 086H  ;  0b10000110  ! B
;           db 08DH  ;  0b10001101  ! C
;           db 0C2H  ;  0b11000010  ! D
;           db 08CH  ;  0b10001100  ! E
;           db 09CH  ;  0b10011100  ! F

            endif                ; fpanelinc
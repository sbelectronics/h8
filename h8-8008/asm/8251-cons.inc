             ifndef   inccons    ; avoid multiple inclusion
inccons      equ      1

;-----------------------------------------------------------------------------------------       
; I/O routines for Console UART in Heathkit H8
;
; Scott Baker, https://www.smbaker.com
;-----------------------------------------------------------------------------------------

h8_cons_d: equ 0FAH
h8_cons_c: equ 0FBH

cons_thr:  equ h8_out2
cons_mode: equ h8_out3
cons_cmd:  equ cons_mode

cons_rhr:  equ h8_in2
cons_stat: equ h8_in3

rts_on      macro
            ifndef no_rts_flow
            mvi a,035H              ; RX enable, TX enable, error reset, RTS-on
            out cons_cmd           
            endif
            endm

rts_off     macro
            ifndef no_rts_flow
            mvi a,015H              ; RX enable, TX enable, error reset, RTS-off
            out cons_cmd     
            endif
            endm

do_forceupper macro
            ifdef forceupper
            cpi 61H
            jm notupper
            cpi 7CH
            jp notupper
            ani 0DFH                ; remove uppercase bit
notupper:
            endif
            endm

;-----------------------------------------------------------------------------------------       
; INITTAPE: initialize tape
;-----------------------------------------------------------------------------------------

SINIT8251:  ifndef noiomap
            mvi a,h8_cons_d         ; configure IO mapper
            out mm_io2
            mvi a,h8_cons_c
            out mm_io3
            endif

            mvi a,000H              ; worst case initialization
            out cons_cmd            ; configure sync more
            nop
            out cons_cmd            ; write sync
            nop
            out cons_cmd            ; write sync
            nop
            mvi a,040H
            out cons_cmd            ; reset
            nop

            mvi a,04EH              ; 8 bit, no parity, 1 stop, 16X baud
            out cons_mode

            mvi a,035H              ; RX enable, TX enable, error reset, RTS
            out cons_cmd

            mvi b,00H               ; reset will sometimes cause framing errors and gibberish
sinit8251w: dcr b                   ; on my ftdi cable. Wait a while before we send out 
            jnz sinit8251w          ; data, to ensure a re-frame.
            ret

;-----------------------------------------------------------------------------------------       
; CPRINT8251: Write Console
;-----------------------------------------------------------------------------------------

CPRINT8251: ani 7fh                 ; mask off the most significant bit of the character

            ifdef nocr
            cpi 00DH
            rz
            endif

            do_forceupper

            mov b,a                 ; save character to write
TXWCONS:    in cons_stat
            ani 1
            jz TXWCONS              ; loop while tx busy

            mov a,b                 ; restore character
            out cons_thr
            ret

;-----------------------------------------------------------------------------------------       
; CINP8251: Read Console and Echo
;-----------------------------------------------------------------------------------------

CINP8251:  
TXWCONS0:   in cons_stat
            ani 1
            jz TXWCONS0             ; don't receive while the TXH is busy
            ani 2
            jnz CPIN8251_HAVE_CHAR
            rts_on
RXWCONS:    in cons_stat
            ani 2
            jz RXWCONS              ; loop while rx empty
CPIN8251_HAVE_CHAR:
            rts_off
            in cons_rhr             ; read character
       
            ; ----- most of this is for the H9
            
            ifndef nostriphigh
            ani 07FH                ; strip high bit, for H9, otherwise we'll echo it
            endif

            ifdef nocr
            cpi 00DH
            jz CINP8251SO
            endif

            do_forceupper

            ; ------ end of H9 stuff

            out cons_thr            ; echo it
CINP8251SO:
            ifndef nocinp80
            ori 80h                 ; SCELBAL needs to have the most significant bit set
            endif
            ret

;-----------------------------------------------------------------------------------------       
; CINP8251: Read Console but do not echo
;-----------------------------------------------------------------------------------------
        
CINP8251NE:
TXWCONS2:   in cons_stat
            ani 1
            jz TXWCONS2             ; don't receive while the TXH is busy
            ani 2
            jnz CPIN8251NE_HAVE_CHAR
            rts_on
RXWCONS1:   in cons_stat
            ani 2
            jz RXWCONS1             ; loop while rx empty
CPIN8251NE_HAVE_CHAR:
            rts_off
            in cons_rhr             ; read character     
            do_forceupper
            ifndef nocinp80
            ori 80h                 ; SCELBAL needs to have the most significant bit set
            endif
            ret

;-----------------------------------------------------------------------------------------       
; CRDY8251: Return nonzero if character waiting
;-----------------------------------------------------------------------------------------

CRDY8251:   in cons_stat
            ani 2
            ret

            endif                ; inccons
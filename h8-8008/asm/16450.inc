             ifndef   inc16450    ; avoid multiple inclusion
inc16450     equ      1

;-----------------------------------------------------------------------------------------       
; I/O routines for 16450/16550 UART in Heathkit H8
;
; Scott Baker, https://www.smbaker.com
;-----------------------------------------------------------------------------------------


h8_thr:    equ 0E8H
h8_rhr:    equ 0E8H
h8_ier:    equ 0E9H
h8_lcr:    equ 0EBH
h8_lsr:    equ 0EDH

ser_thr:   equ h8_out2
ser_lcr:   equ h8_out4
ser_ier:   equ h8_out5

ser_dll:   equ ser_thr
ser_dlm:   equ ser_ier

ser_rhr:   equ h8_in2
ser_lsr:   equ h8_in3

;-----------------------------------------------------------------------------------------       
; SINIT450: initialize serial port
;-----------------------------------------------------------------------------------------

SINIT450:   mvi a,h8_thr            ; configure IO mapper
            out mm_io2
            mvi a,h8_lsr
            out mm_io3
            mvi a,h8_lcr
            out mm_io4
            mvi a,h8_ier
            out mm_io5

            mvi a,083H              ; enable the baud rate regs
            out ser_lcr
            mvi a,000H
            out ser_dlm             ; set baud msb
            mvi a,030H
            out ser_dll             ; set baud lsb
            mvi a,003H
            out ser_lcr             ; set no parity, 1 stop bit

            ; at this point we don't need LCR (io4) or IER/DLM (io5) any more and 
            ; we can reuse them.

            mvi a,h8_digsel
            out mm_io4
            mvi a,h8_digval
            out mm_io5
            ret

;-----------------------------------------------------------------------------------------       
; CINP450: wait for and read character, with echo
;-----------------------------------------------------------------------------------------

CINP450:    in ser_lsr              ; normal entrypoint
            ani 01H
            jz  CINP450             ; loop while waiting for character. Check fpanel if idle
            in ser_rhr
            mov b,a                 ; save received character in B
TXWAIT450:  in ser_lsr
            ani 20H
            jz TXWAIT450            ; loop while waiting for TX free for echo.
            mov a,b                 ; restore received character back to A
            out ser_thr             ; echo it.
            ifndef nocinp80
            ori 80h                 ; SCELBAL needs to have the most significant bit set
            endif
            ret

;-----------------------------------------------------------------------------------------       
; CINP450NE: wait for and read character, without echo
;-----------------------------------------------------------------------------------------

CINP450NE:  in ser_lsr              ; normal entrypoint
            ani 01H
            jz CINP450NE            ; loop while waiting for character
            in ser_rhr
            ifndef nocinp80
            ori 80h                 ; SCELBAL needs to have the most significant bit set
            endif
            ret

;-----------------------------------------------------------------------------------------       
; CRDY450: return Zero if no character ready, NonZero if character ready
;-----------------------------------------------------------------------------------------

CRDY450:    in ser_lsr
            ani 01H
            ret

;-----------------------------------------------------------------------------------------       
; CPRINT450: print character
;-----------------------------------------------------------------------------------------

CPRINT450:  ani 7fh                 ; mask off the most significant bit of the character
            mov b,a                 ; save the character from A to B
TXWAIT451:  in ser_lsr
            ani 20H
            jz  TXWAIT451
            mov a,b
            out ser_thr
            ret

            endif                ; inc16450
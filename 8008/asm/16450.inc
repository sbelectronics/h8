             ifndef   inc16450    ; avoid multiple inclusion
inc16450     equ      1

;-----------------------------------------------------------------------------------------       
; I/O routines for 16450/16550 UART in Heathkit H8
;
; Scott Baker, https://www.smbaker.com
;-----------------------------------------------------------------------------------------

h8_in2:     equ 02H
h8_in3:     equ 03H
h8_in4:     equ 04H
h8_in5:     equ 05H
h8_in6:     equ 06H
h8_in7:     equ 07H

h8_out0:    equ 10H
h8_out1:    equ 11H
h8_out2:    equ 12H
h8_out3:    equ 13H
h8_out4:    equ 14H
h8_out5:    equ 15H
h8_out6:    equ 16H
h8_out7:    equ 17H

mm_io0:    equ 18H
mm_io1:    equ 19H
mm_io2:    equ 1AH
mm_io3:    equ 1BH
mm_io4:    equ 1CH
mm_io5:    equ 1DH
mm_io6:    equ 1EH
mm_io7:    equ 1FH

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
            ret

;-----------------------------------------------------------------------------------------       
; CINP450: wait for and read character
;-----------------------------------------------------------------------------------------

CINP450:    in ser_lsr
            ani 01H
            jz  CINP450             ; loop while waiting for character
            in ser_rhr
            mov b,a                 ; save received character in B
TXWAIT450:  in ser_lsr
            ani 20H
            jz TXWAIT450            ; loop while waiting for TX free for echo.
            mov a,b                 ; restore received character bak to A
            out ser_thr             ; echo it.
            ori 80h                 ; SCELBAL needs to have the most significant bit set
            ret

;-----------------------------------------------------------------------------------------       
; CINP450NE: wait for and read character, without echo
;            also, does not set bit 7.
;            used for binary inputs, for example monitor.asm
;-----------------------------------------------------------------------------------------


CINP450NE:  in ser_lsr
            ani 01H
            jz CINP450NE            ; loop while waiting for character
            in ser_rhr
            ori 80h                 ; SCELBAL needs to have the most significant bit set
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
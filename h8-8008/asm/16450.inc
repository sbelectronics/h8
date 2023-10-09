             ifndef   inc16450    ; avoid multiple inclusion
inc16450     equ      1

;-----------------------------------------------------------------------------------------       
; I/O routines for 16450/16550 UART in Heathkit H8
;
; Scott Baker, https://www.smbaker.com
;-----------------------------------------------------------------------------------------

; Port usage 
;    port 1 - output only, used for MCR
;    port 2 - input/output, used for thr and tcr
;    port 3 - input only, used for lsr
;
; during initialization, ports 4 and 5 are used for lcr and ier

h8_thr:    equ 0E8H
h8_rhr:    equ 0E8H
h8_ier:    equ 0E9H
h8_lcr:    equ 0EBH
h8_mcr:    equ 0ECH
h8_lsr:    equ 0EDH

ser_mcr:   equ h8_out1
ser_thr:   equ h8_out2
ser_lcr:   equ h8_out4
ser_ier:   equ h8_out5

ser_dll:   equ ser_thr
ser_dlm:   equ ser_ier

ser_rhr:   equ h8_in2
ser_lsr:   equ h8_in3

        ifdef baud300
baud_msb:  equ 001H
baud_lsb:  equ 080H
        else
        ifdef baud600
baud_msb:  equ 000H
baud_lsb:  equ 0C0H
        else            ; default - 2400 baud
baud_msb:  equ 000H
baud_lsb:  equ 030H
        endif
        endif

;-----------------------------------------------------------------------------------------       
; Macros for RTS
;-----------------------------------------------------------------------------------------

rts_on     macro
           ifndef no_rts_flow
           mvi a,2
           out ser_mcr
           endif
           endm

rts_off    macro
           ifndef no_rts_flow
           mvi a,0
           out ser_mcr
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

            ifndef no_rts_flow
            mvi a,h8_mcr
            out mm_io1
            endif

            mvi a,083H              ; enable the baud rate regs
            out ser_lcr
            mvi a,baud_msb
            out ser_dlm             ; set baud msb
            mvi a,baud_lsb
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

CINP450_RTS: 
            rts_on
CINP450:    in ser_lsr              ; normal entrypoint
            ani 01H
            jz  CINP450_RTS         ; loop while waiting for character.
            rts_off
            in ser_rhr

            ; ----- most of this is for the H9
            
            ifndef nostriphigh
            ani 07FH                ; strip high bit, for H9, otherwise we'll echo it
            endif

            ifdef nocr
            cpi 00DH
            jz CINP450SO
            endif

            do_forceupper

            ; ------ end of H9 stuff

            mov b,a                 ; save received character in B
TXWAIT450:  in ser_lsr
            ani 20H
            jz TXWAIT450            ; loop while waiting for TX free for echo.
            mov a,b                 ; restore received character back to A
            out ser_thr             ; echo it.
CINP450SO:
            ifndef nocinp80
            ori 80h                 ; SCELBAL needs to have the most significant bit set
            endif
            ret

;-----------------------------------------------------------------------------------------       
; CINP450NE: wait for and read character, without echo
;-----------------------------------------------------------------------------------------

CINP450NE_RTS: 
            rts_on
CINP450NE:  in ser_lsr              ; normal entrypoint
            ani 01H
            jz CINP450NE_RTS        ; loop while waiting for character
            rts_off
            in ser_rhr
            do_forceupper
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

            ifdef nocr
            cpi 00DH
            rz
            endif

            do_forceupper

CP450_NL:   mov b,a                 ; save the character from A to B
TXWAIT451:  in ser_lsr
            ani 20H
            jz  TXWAIT451
            mov a,b
            out ser_thr
            ret

            endif                ; inc16450
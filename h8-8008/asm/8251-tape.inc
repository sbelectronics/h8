             ifndef   inctape    ; avoid multiple inclusion
inctape      equ      1

;-----------------------------------------------------------------------------------------       
; I/O routines for TAPE UART in Heathkit H8
;
; Scott Baker, https://www.smbaker.com
;-----------------------------------------------------------------------------------------

h8_tape_d: equ 0F8H
h8_tape_c: equ 0F9H

tape_thr:  equ h8_out6
tape_mode: equ h8_out7
tape_cmd:  equ tape_mode

tape_rhr:  equ h8_in6
tape_stat: equ h8_in7

;-----------------------------------------------------------------------------------------       
; INITTAPE: initialize tape
;-----------------------------------------------------------------------------------------

INITTAPE:   mvi a,h8_tape_d         ; configure IO mapper
            out mm_io6
            mvi a,h8_tape_c
            out mm_io7

            mvi a,000H              ; worst case initialization
            out tape_cmd            ; configure sync more
            nop
            out tape_cmd            ; write sync
            nop
            out tape_cmd            ; write sync
            nop
            mvi a,040H
            out tape_cmd            ; reset
            nop

            mvi a,04EH              ; 8 bit, no parity, 1 stop, 16X baud
            out tape_mode
            ret

;-----------------------------------------------------------------------------------------       
; STOPTAPE: Turn off the tape motor
;-----------------------------------------------------------------------------------------

STOPTAPE:   mvi a,0H
            out tape_cmd            ; disable TX, disable RX
            ret

;-----------------------------------------------------------------------------------------       
; WSTARTAPE: Start tape write sequence
;-----------------------------------------------------------------------------------------

WSTARTAPE:  mvi a,01H               ; H8 does this before calling any WTAPEs
            out tape_cmd

;-----------------------------------------------------------------------------------------       
; WTAPE: Write Tape
;-----------------------------------------------------------------------------------------

WTAPE:      mov b,a                 ; save character to write
TXWTAPE:    in tape_stat
            ani 1
            jz TXWTAPE              ; loop while tx busy

            mvi a,11H               ; TX enable, error reset
            out tape_cmd

            mov a,b                 ; restore character
            out tape_thr
            ret

;-----------------------------------------------------------------------------------------       
; RTAPE: Read Tape
;-----------------------------------------------------------------------------------------

RTAPE:      mvi a,034H              ; RX enable, error reset, RTS
            out tape_cmd
RXWTAPE:    in tape_stat
            ani 2
            jz RXWTAPE              ; loop while rx empty
            in tape_rhr             ; read character
            ret

            endif                ; inctape
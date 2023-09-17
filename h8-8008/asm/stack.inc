             ifndef   incstack    ; avoid multiple inclusion
incstack     equ      1

;-----------------------------------------------------------------------------------------       
; I/O routines for Console UART in Heathkit H8
;
; Scott Baker, https://www.smbaker.com
;-----------------------------------------------------------------------------------------

h8_stack: equ 18H
h8_sprel: equ 19H
h8_spreh: equ 1AH

stack_push: equ h8_out7
stack_pop:  equ h8_in7

;-----------------------------------------------------------------------------------------       
; INITTAPE: initialize tape
;-----------------------------------------------------------------------------------------

STACKINIT:  mvi a,h8_stack          ; configure IO mapper
            out mm_io7
            ret

            endif                ; incstack
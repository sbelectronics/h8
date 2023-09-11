             ifndef   inch8    ; avoid multiple inclusion
inch8     equ      1

;; constants for H8 port mapping
;; Scott Baker, https://www.smbaker.com/

ipoll:      equ 01H
ledport:    equ 09H

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

h8_digsel: equ 0F0H
h8_digval: equ 0F1H

fp_digsel: equ h8_out4
fp_digval: equ h8_out5
fp_kbd:    equ h8_in4

            endif                ; inch8
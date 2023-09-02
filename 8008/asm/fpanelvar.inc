m_codebuf:  equ 1FB0H                  ; buffer for constructing code for in,out,jump

m_dig:      equ 1FC0H                  ; since digits are 1-based, one empty slot
m_dig_l:    equ 1FC1H
m_dig_m:    equ 1FC4H
m_dig_r:    equ 1FC7H

m_lastkey:  equ 1FCAH
m_lastcnt:  equ 1FCBH
m_state:    equ 1FCCH
m_temp:     equ 1FCDH

msave_H:    equ 1FD0H
msave_L:    equ 1FD1H
msave_C:    equ 1FD2H
msave_D:    equ 1FD3H
msave_B:    equ 1FD4H    ; unused/placeholder
msave_E:    equ 1FD5H    ; unused/placeholder
maddr:      equ 1FD8H
mcounter:   equ 1FDAH    ; bytes, MSB-first
mdigindex:  equ 1FDEH

m_dig_7seg: equ 1FE0H    ; holds copy of digit_7seg

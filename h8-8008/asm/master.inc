MAS_STAT_PORT: equ 04H

MAS_TAKE_PORT: equ 14H
MAS_INT_PORT:  equ 15H
MAS_REQ_PORT:  equ 16H
MAS_RST_PORT:  equ 17H

mas_menu:   mvi h,hi(mas_menutxt)           ; display the menu
            mvi l,lo(mas_menutxt) 
            call puts
            
mas_prompt: mvi h,hi(mas_prompttxt)         ; prompt for input
            mvi l,lo(mas_prompttxt) 
            call puts
mas_prompt0:
            call getch                  ; get input command from user
 
mas_prompt1:
            cpi '?'                     ; is the input '?'
            jnz mas_prompt2             ; nope 
            jmp mas_menu                ; nope, display the menu

mas_prompt2:
            cpi 'a'                     ; is the input character below 'a'?
            jc $+5                      ; skip the next instruction if the character is already upper case
            sui 20H                     ; else, convert to the character to upper case
            call putch                  ; echo the character

            cpi 'I'
            jz mas_interrupt

            cpi 'J'
            jz mas_int_release

            cpi 'R'
            jz mas_reset

            cpi 'S'
            jz mas_status               ; print status

            cpi 'Q'
            jz menu                     ; back to main menu

            cpi 0DH
            jz mas_menu                 ; display the menu
            mvi a,'?'
            call putch                  ; whaaat??
            jmp mas_prompt

mas_status:
           mvi h,hi(mas_statustxt)
           mvi l,lo(mas_statustxt)
           call puts
           in MAS_STAT_PORT
           call prn_bin
           call crlf
           jmp mas_prompt

mas_reset:
           mvi h,hi(mas_resettxt)
           mvi l,lo(mas_resettxt)
           call puts
           mvi a, 0FFH
           out MAS_REQ_PORT
           out MAS_TAKE_PORT
           mvi a, 00H
           out MAS_INT_PORT             ; set all interrupts low
           out MAS_RST_PORT             ; toggle the reset
           jmp mas_prompt

mas_interrupt:
           mvi h,hi(mas_inttxt)
           mvi l,lo(mas_inttxt)
           call puts
           mvi a, 0FFH
           out MAS_INT_PORT
           jmp mas_prompt

mas_int_release:
           mvi h,hi(mas_intreltxt)
           mvi l,lo(mas_intreltxt)
           call puts
           mvi a, 00H
           out MAS_INT_PORT
           jmp mas_prompt

prn_bin:   mvi b,8
prn_binl:  rlc
           jc prn_bin1
           mov d,a
           mvi a,'0'
           call putch
           mov a,d
           jmp prn_bin_next
prn_bin1:  mov d,a
           mvi a,'1'
           call putch
           mov a,d
prn_bin_next:
           dcr b
           jnz prn_binl
           ret
            
mas_menutxt:
            db  "\r\n"
            db  "I - Interrupt\r\n"
            db  "J - Interrupt Release\r\n"
            db  "R - Reset\r\n"
            db  "S - Status\r\n"
            db  "Q - Quit\r\n"
            db 0

mas_prompttxt:
            db  "\r\n>>",0

mas_statustxt:
            db "tatus:",0

mas_resettxt:
            db "eset\r\n",0

mas_inttxt:
            db "nterrupt\r\n",0

mas_intreltxt:
            db "-Interrupt Release\r\n",0


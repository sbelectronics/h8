MAS_STAT_PORT: equ 04H

MAS_TAKE_PORT: equ 14H
MAS_INT_PORT:  equ 15H
MAS_REQ_PORT:  equ 16H
MAS_RST_PORT:  equ 17H

MAS_CMD_FREERUN equ 001H
MAS_CMD_SINGLE equ 002H
MAS_CMD_LIFE equ 003H

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

            cpi 'C'
            jz mas_conway_super

            cpi 'D'
            jz mas_conway_update_super

            cpi 'X'
            jz mas_conway

            cpi 'Y'
            jz mas_conway_update

            cpi 'I'
            jz mas_interrupt

            cpi 'L'
            jz mas_load_program

            cpi 'R'
            jz mas_reset

            cpi 'S'
            jz mas_status               ; print status

            cpi 'T'
            jz mas_take

            cpi 'U'
            jz mas_untake

            cpi 'W'
            jz mas_takew

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
           mvi a, 000H
           out MAS_TAKE_PORT            ; if it's running, this will make it halt
           mvi a, 0FFH
           out MAS_REQ_PORT             ; realease any REQs
           out MAS_INT_PORT             ; set all interrupts inactive 
           out MAS_TAKE_PORT            ; release any TAKEs
           mvi a, 00H         
           out MAS_RST_PORT             ; toggle the reset
           jmp mas_prompt

mas_interrupt:
           mvi h,hi(mas_inttxt)
           mvi l,lo(mas_inttxt)
           call puts
           mvi a, 000H
           out MAS_INT_PORT
           jmp mas_prompt

mas_load_program:
           mvi h,hi(mas_loadtxt)
           mvi l,lo(mas_loadtxt)
           call puts
           call mas_copy_rom
           call mas_set_id
           mvi h,hi(mas_pgmtxt)
           mvi l,lo(mas_pgmtxt)
           call puts
           call get_two
           call mas_set_cmd
           call crlf
           jmp mas_prompt

mas_take:
           mvi h,hi(mas_taketxt)
           mvi l,lo(mas_taketxt)
           call puts
           call get_hex
           jc mas_take_exit
           mov c,a

           mvi h,hi(mas_takebanktxt)
           mvi l,lo(mas_takebanktxt)
           call puts
           call get_hex
           jc mas_take_exit

           adi EXTRAM0
           out MMAP0

           inr c
           mvi a,0FEH
mas_take0:
           dcr c
           jz mas_take1
           rlc
           jmp mas_take0
mas_take1:
           out MAS_TAKE_PORT
mas_take_exit:
           call crlf
           jmp mas_prompt

mas_takew:
           mvi h,hi(mas_taketxt)
           mvi l,lo(mas_taketxt)
           call puts
           mvi h,hi(mas_takebanktxt)
           mvi l,lo(mas_takebanktxt)
           call puts
           call get_hex
           jc mas_takew_exit
           adi EXTRAM0
           out MMAP0
           mvi a,07FH
           out MAS_TAKE_PORT
mas_takew_exit:
           call crlf
           jmp mas_prompt           


mas_untake:
           mvi h,hi(mas_untaketxt)
           mvi l,lo(mas_untaketxt)
           call puts
           mvi a,RAM0
           out MMAP0
           mvi a,0FFH
           out MAS_TAKE_PORT
           jmp mas_prompt

mas_conway:
           call crlf
           call conway_reset
           call conway_copy
           jmp mas_prompt

mas_conway_update:
           call crlf
           call conway_full
           call conway_copy
           jmp mas_prompt

mas_conway_super:
           call crlf
           mvi a,EXTRAM1
           out MMAP1
           mvi a,080H                           ; take everyone
           out MAS_TAKE_PORT
           call conway_reset
           mvi a,0FFH                           ; take nobody
           out MAS_TAKE_PORT
           mvi a,RAM1
           out MMAP1
           call mas_conway_copy
           jmp mas_prompt

mas_conway_update_super:
           call crlf

           mvi a,000H
           out MAS_INT_PORT
           nop
conway_wait:
           in MAS_STAT_PORT
           ani 01H
           jz conway_wait

           call mas_conway_copy
           jmp mas_prompt

mas_conway_copy:
           mvi h, (PAGE1  | 008H)               ; beginning of conway_new
           mvi l, 0
           mvi a,EXTRAM1
           out MMAP1
           mvi a,07EH                           ; take D7,D0 low -- read from 0 write to all
           out MAS_TAKE_PORT
           call conway_copy_block
           mvi a,07DH                           ; take D7,D1 low -- read from 1 write to all
           out MAS_TAKE_PORT
           call conway_copy_block
           mvi a,07BH                           ; take D7,D2 low -- read from 2 write to all
           out MAS_TAKE_PORT
           call conway_copy_block
           mvi a,077H                           ; take D7,D3 low -- read from 3 write to all
           out MAS_TAKE_PORT
           call conway_copy_block
           mvi a,06FH                           ; take D7,D4 low -- read from 4 write to all
           out MAS_TAKE_PORT
           call conway_copy_block
           mvi a,05FH                           ; take D7,D5 low -- read from 5 write to all
           out MAS_TAKE_PORT
           call conway_copy_block

           ;; XXX TEMPORARY - clear the first line of unused blaster block, until we have 6 blasters
           mvi h,(PAGE1 | 02H)
           mvi l, 40H
ctmplp:    dcr l
           mvi m,0
           jnz ctmplp

           ;; XXX TEMPORARY - clear the last line of unused blaster block, until we have 6 blasters
           mvi h,(PAGE1 | 05H)
           mvi l, 0C0H
ctmplp2:   mvi m,0
           inr l
           jnz ctmplp2

           mvi a,0FFH                           ; take nobody
           out MAS_TAKE_PORT
           mvi a,RAM1
           out MMAP1
           ret

; --------------------------------------------
; mas_copy_rom
;   copy rom to ram on blaster
; --------------------------------------------

mas_copy_rom:
           mvi a,080H                           ; TAKE D0-D6 Low -- take all cpus ;; 07FH                           ; TAKE d7 low
           out MAS_TAKE_PORT

           mvi a,EXTRAM2                        ; PAGE2 to EXTRAM2
           out MMAP0

           mvi a,EXTRAM3                        ; PAGE3 to EXTRAM3
           out MMAP1

           mvi d,PAGE2                          ; copy from PAGE2 to PAGE0
           mvi e,PAGE0
mas_copy1:
           mvi l,0
mas_copy2:
           mov h,d
           mov a,m
           mov h,e
           mov m,a
           inr l
           jnz mas_copy2
           inr d
           inr e
           mov a,e
           cpi 20H                              ; at 2000H we are done
           jnz mas_copy1

           mvi a,EXTRAM0
           out MMAP0
           mvi h,0
           mvi l,0
           mvi m, 00DH                          ; RST 01
           mvi l,8
           mvi m, 044H                          ; JMP
           inr l
           mvi m, lo(mas_exec)
           inr l
           mvi m, hi(mas_exec)

           mvi a,RAM0                           ; restore PAGE2/PAGE3 to RAM
           out MMAP0

           mvi a,RAM1
           out MMAP1

           mvi a, 0FFH
           out MAS_TAKE_PORT                    ; TAKE all high
           ret

; --------------------------------------------
; mas_set_id
;   set board ids on blaster
; --------------------------------------------

mas_set_id:
           mvi a,EXTRAM2
           out MMAP0

           mvi h,PAGE0
           mvi l,lo(mas_board)

           mvi d,0                              ; d is blaster index
           mvi e,0FEH                           ; start with d0 low, all else high

mas_set_id_loop:
           mov a,e
           out MAS_TAKE_PORT
           rlc
           mov e,a

           mov m,d                              ; store the id
           inr d
           mov a,d
           cpi 7H                               ; stop at board7 - that is the all-write addr
           jnz mas_set_id_loop

           mvi a,RAM0                           ; restore PAGE2 to RAM0
           out MMAP0

           mvi a,0FFH                           ; restore TAKE to all high
           out MAS_TAKE_PORT

           ret

; --------------------------------------------
; mas_set_cmd
;   set cmd on blaster
; --------------------------------------------

mas_set_cmd:
           mov c,a                              ; save command in c
           mvi a,EXTRAM2
           out MMAP0

           mvi h,PAGE0
           mvi l,lo(mas_cmd)

           mvi d,0                              ; d is blaster index
           mvi e,0FEH                           ; start with d0 low, all else high

mas_set_cmd_loop:
           mov a,e
           out MAS_TAKE_PORT
           rlc
           mov e,a

           mov m,c                              ; store the command
           inr d
           mov a,d
           cpi 7H                               ; stop at board7 - that is the all-write addr
           jnz mas_set_cmd_loop

           mvi a,RAM0                           ; restore PAGE2 to RAM0
           out MMAP0

           mvi a,0FFH                           ; restore TAKE to all high
           out MAS_TAKE_PORT

           ret

; --------------------------------------------
; mas_exec
;   blaster's entrypoint
; --------------------------------------------

mas_exec:
           mvi h,PAGE2
           mvi l,lo(mas_cmd)
           mov a,m

           cpi MAS_CMD_FREERUN
           jz mas_go_freerun

           cpi MAS_CMD_SINGLE
           jz mas_go_single

           cpi MAS_CMD_LIFE
           jz mas_go_conway

           jmp mas_go_id

mas_go_id:
           mvi h,PAGE2
           mvi l,lo(mas_board)
           mov a,m
           out LEDPORT
           hlt
           nop
           nop
           nop
           jmp mas_go_id

mas_go_single:
           mvi h,PAGE2
           mvi l,lo(mas_arg)
           mov a,m
           adi 1
           mov m,a
           out LEDPORT
           hlt
           nop
           nop
           nop
           jmp mas_go_single

mas_go_freerun:
           xra a
mas_freerun_l:
           adi 1
           out LEDPORT
           mvi b,0                              ; wait a while
mas_freerun_l1:
           inr b
           jnz mas_freerun_l1
           jmp mas_freerun_l

mas_go_conway:
           mvi h,PAGE2
           mvi l,lo(mas_board)
           mov a,m                              ; compute our conway_page from the blaster id
           adi PAGE1                            ; ... starting at PAGE1
           mov d,a
           mvi e,0
           call conway_block
           hlt
           nop
           nop
           nop
           jmp mas_go_conway

           include "life.inc" 


; --------------------------------------------
; prn_bin
;   print 8 bit binary number
; --------------------------------------------


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
            db  "C - Conway Reset\r\n"
            db  "D - Conway Iteration\r\n"            
            db  "X - Master Conway Reset\r\n"
            db  "Y - Master Conway Iteration\r\n"
            db  "I - Interrupt\r\n"
            db  "L - Load program\r\n"
            db  "R - Reset\r\n"
            db  "S - Status\r\n"
            db  "T - Take\r\n"
            db  "U - Untake\r\n"
            db  "W - TakeW\r\n"
            db  "Q - Quit\r\n"
            db  0

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

mas_loadtxt:
            db "oad\r\n",0

mas_pgmtxt:
            db "program (2 digits): ",0

mas_taketxt:
            db "ake blaster (1 digit): ",0

mas_takebanktxt:
            db "\r\nBank (1 digit): ",0

mas_takewtxt:
            db "ake write\r\n",0

mas_untaketxt:
            db "ntake\r\n",0


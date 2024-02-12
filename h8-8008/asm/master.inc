MAS_STAT_PORT: equ 01H

MAS_TAKE_PORT: equ 14H
MAS_INT_PORT:  equ 15H
MAS_REQ_PORT:  equ 16H
MAS_RST_PORT:  equ 17H

MAS_CMD_ID     equ 000H
MAS_CMD_FREERUN equ 001H
MAS_CMD_SINGLE equ 002H
MAS_CMD_LIFE   equ 003H

; ----------------------------------------------------------------------------
; mas_init - process the dipswitch and autostart as necessary
;            jump back to mas_init_return if no autostart
; ----------------------------------------------------------------------------

mas_init:   in DIPPORT
            ani 0F0H
            cpi 070H                         ; off off off on -> autostart id
            jz mas_auto_id
            cpi 0B0H                         ; off off on off  -> autostart freerun
            jz mas_auto_freerun
            cpi 030H
            jz mas_auto_conway               ; off off on on   -> autostart conway
            jmp mas_init_return              ; no autostart - go back to main menu
mas_auto_id:
            mvi h,hi(mas_auto_id_txt)
            mvi l,lo(mas_auto_id_txt)
            call puts
            call mas_copy_rom
            call mas_set_id
            mvi a, MAS_CMD_ID
            call mas_set_cmd
            call mas_reset
            jmp mas_prompt
mas_auto_freerun:
            mvi h,hi(mas_auto_free_txt)
            mvi l,lo(mas_auto_free_txt)
            call puts
            call mas_copy_rom
            call mas_set_id
            mvi a, MAS_CMD_FREERUN
            call mas_set_cmd
            call mas_reset
            jmp mas_prompt
mas_auto_conway:
            mvi h,hi(mas_auto_conway_txt)
            mvi l,lo(mas_auto_conway_txt)
            call puts
            call mas_copy_rom
            call mas_set_id
            mvi a, MAS_CMD_LIFE
            call mas_set_cmd
            call mas_reset
            call mas_conway_reset_super
            jmp mas_conway_run_super

; ----------------------------------------------------------------------------
; mas_menu - display master's menu
; ----------------------------------------------------------------------------

mas_menu:   mvi h,hi(mas_menutxt)           ; display the menu
            mvi l,lo(mas_menutxt) 
            call puts
            ; fall through to mas_prompt

; ----------------------------------------------------------------------------
; mas_prompt - display master's prompt
; ----------------------------------------------------------------------------
            
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

            cpi 'E'
            jz mas_conway_run_super

            cpi 'X'
            jz mas_conway

            cpi 'Y'
            jz mas_conway_update

            cpi 'Z'
            jz mas_conway_run

            cpi 'I'
            jz mas_interrupt_cmd

            cpi 'J'
            jz mas_interrupt_cmd2

            cpi 'L'
            jz mas_load_program_cmd

            cpi 'P'
            jz mas_set_program_cmd

            cpi 'R'
            jz mas_reset_cmd

            cpi 'S'
            jz mas_status_cmd               ; print status

            cpi 'T'
            jz mas_take_cmd

            cpi 'U'
            jz mas_untake_cmd

            cpi 'W'
            jz mas_takew_cmd

            cpi 'Q'
            jz menu                     ; back to main menu

            cpi 0DH
            jz mas_menu                 ; display the menu
            mvi a,'?'
            call putch                  ; whaaat??
            jmp mas_prompt

; ----------------------------------------------------------------------------
; mas_status_cmd - show status byte
; ----------------------------------------------------------------------------

mas_status_cmd:
           mvi h,hi(mas_statustxt)
           mvi l,lo(mas_statustxt)
           call puts
           in MAS_STAT_PORT
           call prn_bin
           call crlf
           jmp mas_prompt

; ----------------------------------------------------------------------------
; mas_reset_cmd - reset all blasters
; ----------------------------------------------------------------------------

mas_reset_cmd:
           mvi h,hi(mas_resettxt)
           mvi l,lo(mas_resettxt)
           call puts
mas_reset_inner:
           call mas_reset
           jmp mas_prompt

mas_reset:
           mvi a, 000H
           out MAS_TAKE_PORT            ; if it's running, this will make it halt
           mvi a, 0FFH
           out MAS_REQ_PORT             ; realease any REQs
           out MAS_INT_PORT             ; set all interrupts inactive 
           out MAS_TAKE_PORT            ; release any TAKEs
           mvi a, 00H         
           out MAS_RST_PORT             ; toggle the reset
           ret

; ----------------------------------------------------------------------------
; mas_interrupt_cmd - send interrupt
; ----------------------------------------------------------------------------

mas_interrupt_cmd:
           mvi h,hi(mas_inttxt)
           mvi l,lo(mas_inttxt)
           call puts
           mvi a, 000H
           out MAS_INT_PORT     

           jmp mas_prompt

; ----------------------------------------------------------------------------
; mas_interrupt_cmd2 - this was one of my test cases for testing interrupts
; ----------------------------------------------------------------------------

mas_interrupt_cmd2:
           mvi h,hi(mas_inttxt)
           mvi l,lo(mas_inttxt)
           call puts
mas_interrupt_cmd2l:
           in MAS_STAT_PORT
           ani 07FH
           cpi 07FH
           jnz mas_interrupt_cmd2l

           mvi a, 000H
           out MAS_INT_PORT

           nop
           nop

           in MAS_STAT_PORT
           ani 040H
           jz mas_interrupt_cmd2l
           mvi h,hi(mas_stucktxt)
           mvi l,lo(mas_stucktxt)
           call puts
           jmp mas_prompt

; ----------------------------------------------------------------------------
; mas_load_program_cmd - load a program
; ----------------------------------------------------------------------------

mas_load_program_cmd:
           mvi h,hi(mas_loadtxt)
           mvi l,lo(mas_loadtxt)
           call puts
           call mas_copy_rom
           call mas_set_id
           jmp mas_set_program_inner                    ; Now go set the program

; ----------------------------------------------------------------------------
; mas_set_program_cmd - set program number
; ----------------------------------------------------------------------------

mas_set_program_cmd:
           mvi h,hi(mas_setpgmtxt)
           mvi l,lo(mas_setpgmtxt)
           call puts
mas_set_program_inner:
           mvi h,hi(mas_pgmtxt)
           mvi l,lo(mas_pgmtxt)
           call puts
           call get_one
           jc mas_set_program_exit
           call mas_set_cmd
mas_set_program_exit:
           call crlf
           jmp mas_reset_inner                          ; Now reset it

; ----------------------------------------------------------------------------
; mas_take_cmd - take control of blaster
; ----------------------------------------------------------------------------

mas_take_cmd:
           mvi h,hi(mas_taketxt)
           mvi l,lo(mas_taketxt)
           call puts
           call get_one
           jc mas_take_exit
           mov c,a

           mvi h,hi(mas_takebanktxt)
           mvi l,lo(mas_takebanktxt)
           call puts
           call get_one
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

; ----------------------------------------------------------------------------
; mas_takew_cmd - take control of blaster for write only
; ----------------------------------------------------------------------------

mas_takew_cmd:
           mvi h,hi(mas_taketxt)
           mvi l,lo(mas_taketxt)
           call puts
           mvi h,hi(mas_takebanktxt)
           mvi l,lo(mas_takebanktxt)
           call puts
           call get_one
           jc mas_takew_exit
           adi EXTRAM0
           out MMAP0
           mvi a,07FH
           out MAS_TAKE_PORT
mas_takew_exit:
           call crlf
           jmp mas_prompt

; ----------------------------------------------------------------------------
; mas_untake_cmd - go back to main ram
; ----------------------------------------------------------------------------

mas_untake_cmd:
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
           call mas_conway_init_iter
           call conway_reset
           call conway_copy
           jmp mas_prompt

mas_conway_update:
           call crlf
           call conway_full
           call conway_copy
           jmp mas_prompt

mas_conway_run:
           call cls
mas_conway_run_loop:
           call conway_full
           call home
           call conway_copy
           call mas_conway_show_iter
           jmp mas_conway_run_loop

; ----------------------------------------------------------------------------
; mas_conway_super - setup conway
; ----------------------------------------------------------------------------

mas_conway_super:
           call crlf
           call mas_conway_reset_super
           jmp mas_prompt

mas_conway_reset_super:
           call mas_conway_init_iter
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
           ret

; ----------------------------------------------------------------------------
; mas_conway_update_super - do one update and print cycle
; ----------------------------------------------------------------------------

mas_conway_update_super:
           call crlf
           call mas_conway_trigger
           call conway_print
           call mas_conway_wait
           call mas_conway_copy
           jmp mas_prompt

mas_conway_wait:
           in MAS_STAT_PORT
           ani 01H                              ; just wait on the first one.
           jz mas_conway_wait                   ; all the others will be similar.
           ret

mas_conway_trigger:
           ; Original idea was to use an interrupt to wake the CPU from
           ; halt, but this didn't work reliably. Instead just reset it.
           ;mvi a,000H
           ;out MAS_INT_PORT
           out MAS_rst_PORT                     ; reset 
           ret

; ----------------------------------------------------------------------------
; mas_conway_run_super - continuous conway run
; ----------------------------------------------------------------------------

mas_conway_run_super:
           call cls
mas_conway_run_super_loop:
           call mas_conway_trigger
           call home
           call conway_print
           call mas_conway_show_iter
           call mas_conway_wait
           call mas_conway_copy
           jmp mas_conway_run_super_loop

cls:       mvi a, 01BH          ; ESC [2J
           call CPRINT
           mvi a, '['
           call CPRINT
           mvi a, '2'
           call CPRINT
           mvi a,'J'
           call CPRINT
           ret

home:      mvi a, 01BH          ; ESC [1;1H
           call CPRINT
           mvi a,'['
           call CPRINT
           mvi a,'1'
           call CPRINT
           mvi a,';'
           call CPRINT
           mvi a,'1'
           call CPRINT
           mvi a,'H'
           call CPRINT
           ret

side:      mvi a, 01BH          ; ESC [1;70H
           call CPRINT
           mvi a,'['
           call CPRINT
           mvi a,'1'
           call CPRINT
           mvi a,';'
           call CPRINT
           mvi a,'7'
           call CPRINT
           mvi a,'0'
           call CPRINT
           mvi a,'H'
           call CPRINT
           ret

mas_conway_init_iter:
           mvi h,0
           mvi l,0
           jmp save_hl

mas_conway_show_iter:
           call side                            ; move to where we want to print the iter count
           call restore_hl                      ; get the counter
           inr l                                ; increment it
           jnz mas_conway_show_iter_nowrap
           inr h
mas_conway_show_iter_nowrap:
           call save_hl                         ; save the counter
           mov h,d                              ; DE to HL
           mov l,e
           jmp prndec16                         ; print the counter

; --------------------------------------------
; mas_conway_copy
;   copy new to old
; --------------------------------------------

mas_conway_copy:
           mvi h, (PAGE1  | 008H)               ; beginning of conway_new
           mvi l, 0
           mvi a,EXTRAM1
           out MMAP1
           mvi a,07EH                           ; take D7,D0 low -- read from 0 write to all
           out MAS_TAKE_PORT
           call conway_fcopy_block
           mvi a,07DH                           ; take D7,D1 low -- read from 1 write to all
           out MAS_TAKE_PORT
           call conway_fcopy_block
           mvi a,07BH                           ; take D7,D2 low -- read from 2 write to all
           out MAS_TAKE_PORT
           call conway_fcopy_block
           mvi a,077H                           ; take D7,D3 low -- read from 3 write to all
           out MAS_TAKE_PORT
           call conway_fcopy_block
           mvi a,06FH                           ; take D7,D4 low -- read from 4 write to all
           out MAS_TAKE_PORT
           call conway_fcopy_block
           mvi a,05FH                           ; take D7,D5 low -- read from 5 write to all
           out MAS_TAKE_PORT
           call conway_fcopy_block

;           ;; XXX TEMPORARY - clear the first line of unused blaster block, until we have 6 blasters
;           mvi h,(PAGE1 | 04H)
;           mvi l, 40H
;ctmplp:    dcr l
;           mvi m,0
;           jnz ctmplp

;           ;; XXX TEMPORARY - clear the last line of unused blaster block, until we have 6 blasters
;           mvi h,(PAGE1 | 05H)
;           mvi l, 0C0H
;ctmplp2:   mvi m,0
;           inr l
;           jnz ctmplp2

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
           cpi 06H                              ; board 6 has nothing to do
           jz mas_go_conway_nope
           adi PAGE1                            ; ... starting at PAGE1
           mov d,a
           mvi e,0
           call conway_block
           hlt
           nop
           nop
           nop
           jmp mas_go_conway
mas_go_conway_nope:
           mvi a,000H                           ; blank the LEDS
           out LEDPORT                          ; We're not using this board.
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
            db  "C - Conway Reset/Setup\r\n"
            db  "D - Conway Iteration\r\n"
            db  "E - Conway Continuous Run\r\n"
            db  "X - Master Conway Reset\r\n"
            db  "Y - Master Conway Iteration\r\n"
            db  "Z - Master Conway Continuous Run\r\n"
            db  "I - Interrupt\r\n"
            db  "L - Load Program\r\n"
            db  "P - Set Program\r\n"
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

mas_setpgmtxt:
            db "rogram Set\r\n",0

mas_pgmtxt:
            db "0 - ID\r\n"
            db "1 - Free Run Counter\r\n"
            db "2 - Count and Halt\r\n"
            db "3 - Conway\r\n"
            db ">> program (1 digit): ",0

mas_taketxt:
            db "ake blaster (1 digit): ",0

mas_takebanktxt:
            db "\r\nBank (1 digit): ",0

mas_takewtxt:
            db "ake write\r\n",0

mas_untaketxt:
            db "ntake\r\n",0

mas_stucktxt:
            db "stuck\r\n",0

mas_auto_id_txt:
            db "autostart id\r\n",0

mas_auto_free_txt:
            db "autostart freerun\r\n",0

mas_auto_conway_txt:
            db "autostart conway\r\n",0


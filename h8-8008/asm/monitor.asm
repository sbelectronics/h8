            PAGE 0             ; suppress page headings in ASW listing file
            
;------------------------------------------------------------------------
; 2400bps Serial Monitor for 8008 SBC
;
; Downloaded from https://github.com/jim11662418/8008-SBC by Jim Loos
; Modified by smbaker for H8-8008 project
; 
; this version assumes the following memory map:
; 0000H - 1FFFH:  RAM
; 2000H - 3FFFH:  EPROM
;------------------------------------------------------------------------            

            include "bitfuncs.inc" 

            cpu 8008new             ; use "new" 8008 mnemonics

; front panel vars from 1FB0 to 1FEF
            
; temporary storage for registers;            
save_H:     equ 1FF0H
save_L:     equ 1FF1H
save_B:     equ 1FF2H
save_C:     equ 1FF3H
save_D:     equ 1FF4H
save_E:     equ 1FF5H
esccount    equ 1FF6H
jmp_addr:   equ 1FFCH

ESCAPE      equ 1BH
RETURN      equ 0DH

LEDPORT     equ 08H                     ; Port where the 8 LEDs are at
DIPPORT     equ 00H

; when the reset pushbutton is pressed, the flip-flop is set which generates an interrupt
; and clears the address latches thus, the first instruction is thus always fetched from 
; address 0. the instruction at address 0 must be a single byte transfer instruction in 
; order to set the program counter. i.e., it must be one of the RST opcodes.
            org 2000H                   ; start of EPROM
            rst 1

            org 2008H                   ; rst 1 jumps here
            jmp go_rom0

            include "go-rom.inc"

; some variables for MasterBlaster so we put them at a consistent place
; see master.inc

mas_board:  db 0FFH
mas_cmd:    db 00H
mas_arg:    db 00H
mas_arg2w:  db 00H, 00H
mas_arg3w:  db 00H, 00H
mas_resw:   db 00H, 00H

; The entrypoint for the monitor. go-rom jumps here after setting the
; bank.
            
rom_start:  
            ifdef debugled
            mvi  a,1H
            out  LEDPORT
            else
            xra  a
            out  LEDPORT                ; turn off LEDs
            endif

            ifdef SOUND
            call SNDINIT
            endif

            call SINIT
            call FPANINIT
            call STACKINIT

            ifdef debugled
            mvi  a,3H
            out  08H
            endif
            
;;            xra a                       ; XXX smbaker - last tested H8-8008 had this code
;;            out 09H                     ; turn off orange LEDs
            
            mvi h,hi(esccount)          ; clear the escape key counter
            mvi l,lo(esccount) 
            mvi m,0
            
            mvi h,hi(titletxt)          ; display the title
            mvi l,lo(titletxt) 
            call puts

            ifdef debugled
            mvi  a,7H
            out  LEDPORT
            endif

            ifdef master
            jmp mas_init
mas_init_return:
            endif
            
menu:       mvi h,hi(menutxt)           ; display the menu
            mvi l,lo(menutxt) 
            call puts
            
prompt:     mvi h,hi(prompttxt)         ; prompt for input
            mvi l,lo(prompttxt) 
            call puts
prompt0:    call getch                  ; get input command from user

            ifdef debugled
            mov  l,a
            mvi  a,0FH
            out  LEDPORT
            mov  a,l
            endif

            cpi ':'
            jz hexdl1a                  ; hex file download started
            cpi ESCAPE                  ; is the input the escape key?
            jnz prompt1                 ; nope
            mvi h,hi(esccount)  
            mvi l,lo(esccount) 
            mov b,m
            inr b                       ; yes, increment the escape key count
            mov m,b
            jmp prompt0                 ; go back for more imput     
prompt1:    cpi '?'                     ; is the input '?'
            jnz prompt2                 ; nope 
            mvi h,hi(esccount)  
            mvi l,lo(esccount) 
            mov a,m
            mvi m,0            
            cpi 2                       ; was the escape key pressed twice in succession?
            jnz menu                    ; nope, display the menu
            mvi h,hi(copytxt)           ; escape, escape followed by '?' displays the copyright notice
            mvi l,lo(copytxt) 
            call puts
            jmp prompt

prompt2:    mvi h,hi(esccount)  
            mvi l,lo(esccount) 
            mvi m,0
            cpi 'a'                     ; is the input character below 'a'?
            jc $+5                      ; skip the next instruction if the character is already upper case
            sui 20H                     ; else, convert to the character to upper case
            call putch                  ; echo the character
            cpi 'B'
            jz rombasic                 ; call subroutine
            cpi 'C'
            jz callsub                  ; call subroutine
            cpi 'D'
            jz dump                     ; dump memory
            cpi 'E'
            jz examine                  ; examine/modify memory
            cpi 'F'
            jz fill                     ; fill memory
            cpi 'G'
            jz goto                     ; goto address
            cpi 'H'
            jz hexdl                    ; Intel hex file download
            cpi 'I'
            jz input                    ; input from port
            cpi 'O'
            jz output                   ; output to port
            cpi 'P'
            jz pop                      ; output to port
            cpi 'R'
            jz bindl                    ; binary file download
            cpi 'S'
            jz switch                   ; switch to rom bank and jump
            cpi 'U'
            jz push                     ; push to stack

            ifdef master
            cpi 'M'
            jz mas_menu
            endif

            ifdef frontpanel_isr
            cpi 'Y'
            jz enableint               ; disable interrupts
            cpi 'Z'
            jz disableint               ; disable interrupts
            endif ; frontpanel_isr

            cpi 0DH
            jz menu                     ; display the menu
            mvi a,'?'
            call putch                  ; whaaat??
            jmp prompt

pop:       mvi h,hi(poptxt)
           mvi l,lo(poptxt)
           call puts                   ; prompt for the value
           in stack_pop
           call write_hex
           jmp prompt

push:      mvi h,hi(pushtxt)
           mvi l,lo(pushtxt)
           call puts                   ; prompt for the value
           call get_two                ; get the value used to fill in A
           out stack_push
           jmp prompt

           ifdef frontpanel_isr

disableint: mvi h,hi(disabletxt)
           mvi l,lo(disabletxt)
           call puts                   ; prompt for the value
           out int_di
           jmp prompt

enableint: mvi h,hi(enabletxt)
           mvi l,lo(enabletxt)
           call puts                   ; prompt for the value
           call STARTINT
           jmp prompt

           endif ; frontpanel_isr
            
;------------------------------------------------------------------------
; dump a page of memory in hex and ascii
; space key aborts display.
;------------------------------------------------------------------------
dump:       mvi h,hi(dumptxt)
            mvi l,lo(dumptxt)
            call puts     
            call get_addr               ; get the four digit address
            jc prompt                   ; exit prematurely if space, enter or escape
            mvi h,hi(columntxt)
            mvi l,lo(columntxt)
            call puts     
            mvi h,hi(save_H)
            mvi l,lo(save_H)            
            mov b,m                     ; move the high byte of the address into B
            inr l
            mov a,m                     ; move the high byte of the address into A
            ani 0F0H                    ; start on a 16 byte boundry            
            mov l,a                     ; move it to L
            mov h,b
dump2:      call crlf                   ; start on a new line
            mov a,h
            call write_hex              ; write the high byte of the address
            mov a,l
            call write_hex              ; write the low byte of the address
            call space
            
            ; write one line of 16 bytes in hex and then in ascii
dump3:      in 0                        ; XXX SMBAKER - FIX THIS
            rar
            jnc prompt                  ; abort if start bit detected
            mov a,m                     ; retrieve the byte from memory
            call write_hex              ; write it as two hex digits
            call space
            inr l
            mov a,l
            ani 0FH                     ; 16 bytes?
            jz dump4                    ; move on to print ascii characters
            jmp dump3                   ; otherwise, next address
            
            ; ascii characters
dump4:      call space
            in 0
            rar
            jnc prompt                  ; abort if start bit detected
            mov a,l                     
            sui 16
            mov l,a                     ; back to the starting address for this line
dump5:      mov a,m                     ; retrieve the byte from memory
            cpi 32                      ; control character?
            jc dump6                    ; jump if the byte from memory is < 32
            cpi 128                     ; extended ascii?
            jc dump7                    ; jump if the byte from memory is < 128
dump6:      mvi a,'.'                   ; print '.' for non-printable sacii
dump7:      call putch
            in 0
            rar
            jnc prompt
            inr l                       ; next address
            jz prompt                   ; exit if finished with this page
            mov a,l                     ; next address
            ani 0FH                     ; 16 bytes?
            jz dump2                    ; jump if end of line
            jmp dump5                   ; otherwise, next memory address
            
;------------------------------------------------------------------------
; fill a block of memory with a value
;------------------------------------------------------------------------
fill:       mvi h,hi(filltxt)
            mvi l,lo(filltxt)
            call puts
            call get_addr               ; get the four digit address
            jc prompt                   ; exit prematurely if space, enter or escape            
            call get_count              ; get the four digit count
            jc prompt                   ; exit prematurely if space, enter or escape            
            mvi h,hi(valuetxt)
            mvi l,lo(valuetxt)
            call puts                   ; prompt for the value
            call get_two                ; get the value used to fill in A
            mvi h,hi(save_B)
            mvi l,lo(save_B)
            mov b,m                     ; retrieve the count high byte from memory
            inr l
            mov c,m                     ; retrieve the count low byte from memory
            mvi h,hi(save_H)
            mvi l,lo(save_H)
            mov d,m                     ; retrieve the address high byte from memory
            inr l
            mov e,m                     ; retrieve the address low byte from memory
            mov h,d                     ; get the address high byte from D
            mov l,e                     ; get the address low byte from E
fillloop:   mov m,a                     ; save the value in memory
            inr l                       ; increment L
            jnz fillloop1
            inr h                       ; increment H
fillloop1:  call decBC
            mov d,a                     ; save the fill byte in D
            mov a,c                     ; get the count low byte 
            ora b                       ; OR with the count high byte
            mov a,d                     ; restore the fill byte from D
            jnz fillloop
            jmp prompt

;------------------------------------------------------------------------
; examine/modify memory.
; space increments memory pointer without affecting value.
; enter or escape exits.
;------------------------------------------------------------------------        
examine:    mvi h,hi(examinetxt)  
            mvi l,lo(examinetxt) 
            call puts 
            call get_addr               ; get the four digit address
            jc prompt                   ; exit prematurely if space, enter or escape            
            call crlf
            mvi h,hi(save_H)
            mvi l,lo(save_H)
            mov d,m                     ; retrieve the address high byte from memory
            inr l
            mov e,m                     ; retrieve the address low byte from memory
            mov h,d                     ; get the address high byte from D
            mov l,e                     ; get the address low byte from E
examine1:   call crlf
            mov a,h
            call write_hex              ; high byte of the address
            mov a,l
            call write_hex              ; low byte of the address
            call save_HL
            mvi h,hi(arrowtxt)
            mvi l,lo(arrowtxt)
            call puts    
            call restore_HL
            mov a,m
            call write_hex              ; value stored at memory
            call save_HL
            mvi h,hi(newvaluetxt)
            mvi l,lo(newvaluetxt)
            call puts    
            call restore_HL
examine3:   call get_two                ; two hex digits
            jc examine4                 ; jump if space, enter or escape
            mov m,a                     ; else save the new value in memory at this address
            inr l                       ; next address
            jnz examine1
            inr h
            jmp examine1
examine4:   cpi ' '                     ; space?
            jnz examine5
            inr l                       ; next address
            jnz examine1
            inr h
            jmp examine1
examine5:   cpi 0DH                     ; enter?
            jz  prompt
            cpi 1BH                     ; escape?
            jz  prompt
            jmp examine3
            
;------------------------------------------------------------------------
; load a binary file into memory using the Tera Term "Send file" function.
; when using the Tera Term "Send file" function, make sure that:
;   1. the serial port transmit delay is set to at least 2 msec/char
;   2. the "Binary" option check box on the Send File dialog box is checked.
; the download is assumed to be finished when no characters have been received
; from Teraterm for 3 seconds.
; uses BC as the "idle" counter.
;------------------------------------------------------------------------            
bindl:      mvi h,hi(binloadtxt)  
            mvi l,lo(binloadtxt) 
            call puts 
            
            call get_addr               ; get the four digit hex load address
            jc prompt                   ; exit prematurely if space, enter or escape            

            mvi h,hi(dnldtxt)
            mvi l,lo(dnldtxt)
            call puts                   ; prompt for download

            call FPDISABLE
           
            mvi h,hi(save_H)
            mvi l,lo(save_H)
            mov d,m                     ; retrieve the start address high byte from memory into D
            inr l
            mov e,m                     ; retrieve the start address low byte from memory into E
            mov h,d                     ; get the start address high byte into H
            mov l,e                     ; get the start address low byte into L

            call getch_bin              ; get the first byte of the file from the serial port
            mov m,a                     ; write the first byte to memory
            inr l                       ; increment the low byte of the address pointer
            jnz bindl0                  ; go get next byte
            inr h                       ; increment the high byte of the address pointer

bindl0:     mvi b,40H                   ; initialize "idle" counter (BC) to 16284
            mvi c,0
bindl1:     call CRDY                   ; wait for character
            jnz bindl2                  ; jump if start bit has been detected
            dcr c                       ; else decrement the low byte of the "idle" counter
            jnz bindl1
            dcr b                       ; secrement the high byte of the "idle" counter
            jnz bindl1
            jmp bfinished               ; the "idle" counter has reached zero (no characters for 3 seconds)

bindl2:     call getch_bin              ; start bit has been detected, get the byte from the serial port
            mov m,a                     ; write the byte to memory
            inr l                       ; increment the low byte of the address pointer
            jnz bindl0                  ; go back for the next byte
            inr h                       ; increment the high byte of the address pointer 
            jmp bindl0                  ; go back for the next byte

bfinished:  call FPENABLE
            mvi h,hi(loadedtxt)
            mvi l,lo(loadedtxt)
            call puts                   ; print "File loaded."
            call restore_HL
            jmp prompt
            
;------------------------------------------------------------------------
; load an Intel HEX file into memory using the Tera Term "Send file" function.
; uses D for the record's byte count. uses B to hold the record's checksum.
; when the download is finished, jump to the address contained in the last record.
; when using the Tera Term "Send file" function, make sure that:
;   1. the serial port transmit delay is set to at least 1 mSec/char
;   2. the "Binary" option check box on the Send File dialog box is NOT checked.
;------------------------------------------------------------------------            
hexdl:      mvi h,hi(hexloadtxt)  
            mvi l,lo(hexloadtxt) 
            call puts 

            mvi h,hi(waittxt)
            mvi l,lo(waittxt)
            call puts                   ; prompt for download

            call FPDISABLE
            
hexdl1:     call getche                 ; get the first character of the record and echo it
            cpi ':'                     ; start of record character?
            jnz hexdl1                  ; loop until start of record found
            
hexdl1a:    call hexbyte                ; get byte count
            cpi 0                       ; zero byte count?
            jz waitend                  ; zero means last record             
            mov d,a                     ; save the byte count in D
            mov b,a                     ; save as the checksum in B
            
            call hexbyte                ; get address hi byte
            mov h,a                     ; save hi byte in H
            add b                       ; add to the checksum
            mov b,a                     ; save the checksum in B
            call hexbyte                ; get address lo byte
            mov l,a                     ; save lo byte in L
            add b                       ; add to the checksum
            mov b,a                     ; save the checksum in B
            
            call hexbyte                ; get record type
            cpi 1                       ; end of file?
            jz waitend                  ; record type 1 means end of file
            mov c,a                     ; save record type in C
            add b                       ; add record type to checksum
            mov b,a                     ; save the checksum
            mov a,c                     ; restore the record type from C
            
hexdl2:     call hexbyte                ; get the next data byte
            mov m,a                     ; store it in memory
            add b                       ; add to the checksum
            mov b,a                     ; save the checksum
            inr l                       ; increment lo byte of address pointer
            jnz hexdl3
            inr h                       ; increment hi byte of address pointer
hexdl3:     dcr d
            jz hexdl4                   ; all bytes in this record downloaded
            jmp hexdl2                  ; go back for next data byte
            
hexdl4:     call hexbyte                ; get the checksum byte
            add b                       ; add to the checksum
; Since the record's checksum byte is the two's complement and therefore the additive inverse
; of the data checksum, the verification process can be reduced to summing all decoded byte 
; values, including the record's checksum, and verifying that the LSB of the sum is zero.             
            jnz cksumerr                ; non zero means checksum error
            jmp hexdl1                  ; else, go back for the next record
            
; get the last record
waitend:    call hexbyte                ; get the last address hi byte
            mov h,a                     ; save hi byte in H
            call hexbyte                ; get the last address lo byte
            mov l,a                     ; save lo byte in L
            call save_HL                ; save HL for later
            
            call hexbyte                ; get the last record type
            call hexbyte                ; get the last checksum

finished:   call FPENABLE
            mvi h,hi(loadedtxt)
            mvi l,lo(loadedtxt)
            call puts                   ; print "File loaded."
            call restore_HL
            jmp jump1                   ; jump to the address in the last record

cksumerr:   call FPENABLE
            mvi h,hi(errortxt)
            mvi l,lo(errortxt)
            call puts                   ; print "Checksum error."
            jmp prompt

;------------------------------------------------------------------------
; get two hex digits from the serial port during the hex download and 
; convert them into a byte returned in A. 
; uses A, C and E
;------------------------------------------------------------------------
hexbyte:    call getche             ; get the first character and echo it
            call ascii2hex          ; convert to hex nibble
            rlc                     ; rotate into the most significant nibble
            rlc
            rlc
            rlc
            ani 0F0H                ; mast out least signifficant nibble
            mov c,a                 ; save the first digit in C as the most significant nibble
            
            call getche             ; get the second character and echo it
            call ascii2hex          ; convert to hex nibble
            ani 0FH                 ; mask out the most significant bits
            ora c                   ; combine the two nibbles
            ret

;------------------------------------------------------------------------
; switch banks and load rom basic
;------------------------------------------------------------------------      

rombasic:   mvi h,hi(rombastxt)
            mvi l,lo(rombastxt)
            call puts
            call FPDISABLE
            mvi a, 1H
            jmp go_rom

;------------------------------------------------------------------------
; switch banks to arbitrary bank number and jump to rom
;------------------------------------------------------------------------      

switch:     mvi h,hi(switchtxt)
            mvi l,lo(switchtxt)
            call puts
            call get_hex                ; XXX smbaker confusion on get_one vs get_hex
            jc prompt                   ; exit if escape  
            mov b,a                     ; save character in B
            mvi h,hi(loadingtxt)
            mvi l,lo(loadingtxt)
            call puts
            call FPDISABLE
            mov a,b                     ; restore character
            call ascii2hex              ; convert character to number
            jmp go_rom
            
;------------------------------------------------------------------------
; go to a memory address
;------------------------------------------------------------------------           
goto:       mvi h,hi(gototxt)
            mvi l,lo(gototxt)
            call puts
            call get_four               ; get the four digit address into HL
            jc prompt                   ; exit if escape            
            jmp jump1
            
;------------------------------------------------------------------------
; jump to a memory address
;------------------------------------------------------------------------           

jump1:      mov d,h                     ; save the high byte of the address in D
            mov e,l                     ; save the low byte of the address in E
            mvi h,hi(jmp_addr)
            mvi l,lo(jmp_addr)
            mvi m,44H                   ; store the "jmp" instruction at jmp_addr
            inr l                       ; next memory location
            mov m,e                     ; store the low byte of jump address at jmp_addr+1
            inr l                       ; next memory location
            mov m,d                     ; store the high byte of jump address at jmp_addr+2
            call crlf                   ; start of a new line
            jmp jmp_addr                ; go jump!
          
;------------------------------------------------------------------------            
; call a subroutine
;------------------------------------------------------------------------                   
callsub:    mvi h,hi(calltxt)
            mvi l,lo(calltxt)
            call puts
            call get_four               ; get the four digit address into HL
            jc prompt                   ; exit if escape
            mov d,h                     ; save the high byte of the address in D
            mov e,l                     ; save the low byte of the address in E
            mvi h,hi(jmp_addr)
            mvi l,lo(jmp_addr)
            mvi m,46H                   ; store "CALL" instruction at jmp+addr
            inr l
            mov m,e                     ; store the low byte of the subroutine address at jmp_addr+1
            inr l                       ; next memory location
            mov m,d                     ; store the high byte of the subroutine address at jmp_addr+2
            inr l
            mvi m,07H                   ; store "RET" instruction at jmp_addr+3
            call crlf                   ; start of a new line
            call jmp_addr               ; call the subroutine
            jmp prompt
            
;------------------------------------------------------------------------            
; get a byte from an input port
;------------------------------------------------------------------------            
input:      mvi h,hi(inputtxt)
            mvi l,lo(inputtxt)
            call puts
            mvi h,hi(porttxt)
            mvi l,lo(porttxt)
            call puts    
            call get_two
            jc prompt                   ; exit if escape            
            ani 00000111B
            rlc
            ori 01000001B
            mvi h,hi(jmp_addr)
            mvi l,lo(jmp_addr)
            mov m,a                   ; store the "IN" instruction at jmp_addr
            inr l
            mvi m,07H                 ; store the "RET" instruction at jmp_addr+1
            call jmp_addr             ; execute the "IN" instruction
            mov d,a                   ; save the input data in E
            mvi h,hi(arrowtxt)
            mvi l,lo(arrowtxt)
            call puts
            mov a,d
            call write_hex
            call crlf
            
            jmp prompt

;------------------------------------------------------------------------            
; send a byte to an output port
;------------------------------------------------------------------------            
output:     mvi h,hi(outputtxt)
            mvi l,lo(outputtxt)
            call puts
            mvi h,hi(porttxt)
            mvi l,lo(porttxt)
            call puts    
            call get_two
            jc prompt                   ; exit if escape            
            mov d,a                     ; save the port address in D
            mvi h,hi(bytetxt)
            mvi l,lo(bytetxt)
            call puts   
            call get_two
            jc prompt                   ; exit if escape            
            mov e,a                     ; save the date byte in E
            mov a,d                     ; recall the address from D
            ani 00011111B               ; construct the "OUT" instruction
            rlc
            ori 01000001B
            mvi h,hi(jmp_addr)
            mvi l,lo(jmp_addr)
            mov m,a                   ; store the "OUT" instruction at jmp_addr
            inr l
            mvi m,07H                 ; store the "RET" instruction at jmp_addr+1
            mov a,e                   ; recall the data byte from E
            call jmp_addr             ; execute the "OUT" instruction
            call crlf                 ; start of a new line            
            jmp prompt            

;------------------------------------------------------------------------            
; subroutine to decrement double-byte value in BC
;------------------------------------------------------------------------
decBC:     dcr c                        ; decrement contents of C
           inr c                        ; now increment C to set/reset flags
           jnz decbc1                   ; if C not presently zero, skip decrementing B
           dcr b                        ; else decrement B
decbc1:    dcr c                        ; do the actual decrement of C
           ret
           
;------------------------------------------------------------------------            
; get a four digit address (in hex) and store it the high byte at "save_H" and 
; the low byte at "save_L". 
; on return BC contains the address and HL points to "save_H".
; uses A, BC, DE and HL.
;------------------------------------------------------------------------           
get_addr:   mvi h,hi(addresstxt)
            mvi l,lo(addresstxt)
            call puts                   ; prompt for the address
            call get_four               ; get the address
            rc                          ; return prematurely if escape key
            mov b,h
            mov c,l
            mvi h,hi(save_H)
            mvi l,lo(save_H)
            mov m,b                     ; save the address high byte in memory
            inr l                       ; next memory location
            mov m,c                     ; save the address low byte in memory
            dcr l
            ret
            
;------------------------------------------------------------------------            
; get a four digit count (in hex) and store it the high byte at "save_B" 
; and the low byte at "save_C"
; on return BC contains the count and HL points to "save_B".
; uses A, BC, DE and HL.
;------------------------------------------------------------------------                      
get_count:  mvi h,hi(hcounttxt)
            mvi l,lo(hcounttxt)
            call puts                   ; prompt for the count
            call get_four               ; get the count
            rc                          ; return prematurely if space, enter or escape
            mov b,h
            mov c,l
            mvi h,hi(save_B)
            mvi l,lo(save_B)
            mov m,b                     ; save the high byte of the count in memory
            inr l
            mov m,c                     ; save the low byte of the count in memory
            dcr l
            ret

;------------------------------------------------------------------------      
; save the contents of H and L in a temporary storage area in memory.
; uses H and L, D and E.
;------------------------------------------------------------------------
save_HL:   mov d,h                ; transfer value in H to A
           mov e,l                ; and value in L to E
           mvi h,hi(save_H)       ; and set H to storage area page           
           mvi l,lo(save_H)       ; now set L to temporary storage locations
           mov m,d                ; save A (entry value of H) in memory
           inr l                  ; advance pointer
           mov m,e                ; save E (entry value of L) in memory
           ret

;------------------------------------------------------------------------
; restore the contents H and L from temporary storage in memory.
; uses H and L, D and E.
;------------------------------------------------------------------------
restore_HL:mvi h,hi(save_H)       ; and set L to storage area page
           mvi l,lo(save_H)       ; now set L to start of temporary storage locations
           mov d,m                ; fetch stored value for H into A
           inr l                  ; advance pointer
           mov e,m                ; fetch stored value for L into E
           inr l                  ; advance pointer
           mov h,d                ; restore  saved value for H
           mov l,e                ; restore saved value for L
           ret

;------------------------------------------------------------------------      
; save the contents of B and C in a temporary storage area in memory.
; uses H and L
;------------------------------------------------------------------------
save_BC:   mvi h,hi(save_B)       ; and set H to storage area page           
           mvi l,lo(save_B)       ; now set L to temporary storage locations
           mov m,b                ; save B in memory
           inr l                  ; advance pointer
           mov m,c                ; save C in memory
           ret

;------------------------------------------------------------------------
; restore the contents B and C from temporary storage in memory.
; uses H and L
;------------------------------------------------------------------------
restore_BC:mvi h,hi(save_B)       ; and set L to storage area page
           mvi l,lo(save_B)       ; now set L to start of temporary storage locations
           mov b,m                ; fetch stored value for B
           inr l                  ; advance pointer
           mov c,m                ; fetch stored value for C
           inr l                  ; advance pointer
           ret
           
;------------------------------------------------------------------------      
; save the contents of D and E in a temporary storage area in memory.
; uses H and L
;------------------------------------------------------------------------
save_DE:   mvi h,hi(save_D)       ; and set H to storage area page           
           mvi l,lo(save_D)       ; now set L to temporary storage locations
           mov m,d                ; save D in memory
           inr l                  ; advance pointer
           mov m,e                ; save E in memory
           ret

;------------------------------------------------------------------------
; restore the contents D and E from temporary storage in memory.
; uses DE and HL
;------------------------------------------------------------------------
restore_DE:mvi h,hi(save_D)       ; and set L to storage area page
           mvi l,lo(save_D)       ; now set L to start of temporary storage locations
           mov d,m                ; fetch stored value for D
           inr l                  ; advance pointer
           mov e,m                ; fetch stored value for E
           inr l                  ; advance pointer
           ret
           
;------------------------------------------------------------------------        
; enter decimal digits until terminated with carriage return or escape. 
; returns with carry set if escape, otherwise returns with the binary 
; value in HL and carry clear.
; uses A, B, DE and HL
;------------------------------------------------------------------------        
get_dec:    mvi h,0
            mvi l,0
get_dec1:   call getch      ; get input from serial
            cpi RETURN      ; carriage return?
            jnz get_dec2
            ana a           ; clear carry
            ret
            
get_dec2:   cpi ESCAPE      ; escape?
            jnz get_dec3 
            mvi a,1
            rrc             ; set carry flag
            ret
            
get_dec3:   cpi '0'
            jc get_dec1     ; go back for another digit if the digit in A is less than 0
            cpi '9'+1
            jnc get_dec1    ; go back for another digit if the digit in A is greater than 9
            call putch      ; since it's legit, echo the digit
            sui 30H         ; convert the ASCII decimal digit in A to binary
            mov b,a         ; save the decimal digit in B
        
            mov d,h
            mov e,l         ; copy HL into DE
        
            ; double HL (effectively multiplying HL by 2)
            mov a,l
            add l
            mov l,a
            mov a,h
            adc h
            mov h,a

            ; double HL again (effectively multiplying HL by 4)
            mov a,l
            add l
            mov l,a
            mov a,h
            adc h
            mov h,a
        
            ; add DE (containing the original value of HL) to HL (effectively multiplying HL by 5)
            mov a,l
            add e
            mov l,a
            mov a,h
            adc d
            mov h,a
        
            ; double HL again (effectively multiplying HL by 10)
            mov a,l
            add l
            mov l,a
            mov a,h
            adc h
            mov h,a
        
            ; add the new digit (saved in B) to HL
            mov a,l
            add b
            mov l,a
            mov a,h
            mvi d,0
            adc d
            mov h,a         
        
            jmp get_dec1      ; go back for the next decimal digit
            
;------------------------------------------------------------------------        
; print the 8 bit binary number in A as three decimal digits.
; leading zeros are suppressed.
; uses A, BC and DE.
;------------------------------------------------------------------------        
prndec8:    mvi e,0         ; clear the leading zero flag (suppress zeros)
            mvi d,100       ; power of 10, starts as 100
prndec8a:   mvi c,'0'-1     ; C serves as the counter (starts at 1 less than ascii zero)
prndec8b:   inr c
            sub d           ; subtract power of 10
            jnc prndec8b    ; go back for another subtraction if the difference is still positive
            add d           ; else , add back the power of 10
            mov b,a         ; save the difference in B
            mov a,c         ; get the counter from C
            cpi '1'         ; is it zero?
            jnc prndec8c    ; jump if the counter is greater than ascii zero
            mov a,e         ; recall the leading zero flag from E
            ora a           ; set flags according to the leading zero flag
            mov a,c         ; restore the counter from C
            jz prndec8d     ; skip printing the digit if the leading zero flag is zero
prndec8c:   call putch      ; else, print the digit
            mvi e,0FFH      ; set the leading zero flag
prndec8d:   mov a,d
            sui 90          ; reduce power of ten from 100 to 10
            mov d,a
            mov a,b         ; recall the difference from B
            jnc prndec8a    ; go back for the tens digit
            adi '0'         ; else, convert the ones digit to ascii
            call putch      ; print the last digit
            ret
        
;------------------------------------------------------------------------                
; print the 16 bit binary number in HL as five decimal digits.
; leading zeros are suppressed.
; uses A, HL, BC and DE.
;------------------------------------------------------------------------        
prndec16:   mvi b,0         ; clear the leading zero flag
            mvi d,027H
            mvi e,010H      ; DE now contains 10000
            call subtr      ; count and print the ten thousands digit
            mvi d,003H
            mvi e,0E8H      ; DE now contains 1000
            call subtr      ; count and print the thousands digit
            mvi d,000H
            mvi e,064H      ; DE now contains 100
            call subtr      ; count and print the hundreds digit
            mvi d,000H
            mvi e,00AH      ; DE now contains 10
            call subtr      ; count and print the tens digit
            mov a,l         ; get the units digit
            adi '0'         ; convert the units digit to ascii
            jmp putch       ; print the units digit
        
; count and print the number of times the power of ten in DE can be subtracted from HL
subtr:      mvi c,'0'-1     ; initialize the counter in C
subtr1:     inr c           ; increment the counter
            mov a,l
            sub e           ; subtract E from L
            mov l,a
            mov a,h
            sbb d           ; subtract D from H
            mov h,a
            jnc subtr1      ; continue subtracting until underflow
        
            ; underflow occured, add the power of ten back to HL
            mov a,l
            add e           ; add E back to L
            mov l,a
            mov a,h
            adc d           ; add D back to H
            mov h,a
            mov a,c
        
            ; check for zero
            cpi '1'
            jnc subtr2      ; jump if the count in C is greater than zero
            mov a,b         ; else, recall the leading zero flag
            ora a           ; set flags
            mov a,c         ; recall the count
            rz              ; return if the leading zero is zero
            jmp putch       ; else, print the digit
        
subtr2:     mvi b,0FFH      ; set the leading zero flag
            jmp putch       ; print the digit
           
;------------------------------------------------------------------------
; reads four hex digits from the serial port and converts them into two
; bytes returned in H and L.  enter key exits with fewer than four digits.
; returns with carry flag set if escape key is pressed.
; in addition to H and L, uses A, BC and E.
;------------------------------------------------------------------------
get_four:   call get_hex            ; get the first character
            jnc get_four2           ; not space, enter nor escape
            cpi 1BH                 ; escape key?
            jnz get_four            ; go back for another try
get_four1:  mvi a,1
            rrc                     ; set the carry flag
            mvi a,1BH
            mvi h,0
            mvi l,0
            ret                     ; return with escape in A and carry set
; the first digit is a valid hex digit 0-F
get_four2:  call ascii2hex          ; convert to hex nibble
            rlc                     ; rotate into the most significant nibble
            rlc
            rlc
            rlc
            ani 0F0H                ; mast out least signifficant nibble
            mov l,a                 ; save the first nibble in L
            
; get the second character            
get_four3:  call get_hex            ; get the second character
            jnc get_four5
            cpi 1BH                 ; escape key?
            jz get_four1
            cpi 0DH                 ; enter key?
            jnz get_four3
            mov a,l                 ; recall the first nibble from L
            rrc                     ; rotate back to least significant nibble
            rrc
            rrc
            rrc
            ani 0FH                 ; mask out most significant nibble
            mov l,a                 ; put the first digit in L
get_four4:  mvi h,0                 ; clear H
            sub a                   ; clear the carry flag
            ret
            
; the second character is a valid hex digit 0-F            
get_four5:  call ascii2hex          ; convert to hex nibble
            ani 0FH                 ; mask out the most significant bits
            ora l                   ; combine the two nibbles
            mov l,a                 ; save the first two digits in L

; the first two digits are in L. get the third character
get_four6:  call get_hex            ; get the third character
            jnc get_four7           ; not space, escape nor enter
            cpi 1BH                 ; escape key?
            jz get_four1
            cpi 0DH                 ; enter key?
            jnz get_four6           ; go back for another try
            jmp get_four4           ; exit with carry set
            
; the third character is a valid hex digit 0-F            
get_four7:  call ascii2hex          ; convert to hex nibble
            rlc                     ; rotate into the most significant nibble
            rlc
            rlc
            rlc
            ani 0F0H                ; mast out least signifficant nibble
            mov h,a                 ; save the nibble in H

; the first two digits are in L. the third digit is in H. get the fourth character
get_four8:  call get_hex            ; get the fourth character
            jnc get_four9
            cpi 1BH                 ; escape key?
            jz get_four1
            cpi 0DH                 ; enter key?
            jnz get_four8           ; go back for another try

; enter key pressed...            
            mov a,h                 ; retrieve the third digit from H
            rrc                     ; rotate the third digit back to least significant nibble
            rrc
            rrc
            rrc
            ani 0FH                 ; mask out most significant nibble
            mov h,a
; the first two digits are in L, the third digit is in H
            mov b,h                 ; save the third digit in B
            mov c,l                 ; save the first two digits in C
            
            mov a,l
            rlc                     ; rotate the second digit to the most sifnificant nibble
            rlc
            rlc
            rlc
            ani 0F0H                ; mask bits
            ora h                   ; combine the second and third digits
            mov l,a                 ; second and third digits now in L
            
            mov a,c                 ; get the first two digits from C
            rrc                     ; rotate the first digit to the least significant nibble
            rrc
            rrc
            rrc
            ani 0FH                 ; mask out the most significant bits
            mov h,a                 ; first digit now in H
            sub a                   ; clear the carry flag
            ret
            
; the fourth character is a valid hex digit 0-F            
get_four9:  call ascii2hex          ; convert to hex nibble
            ani 0FH                 ; mask out the most significant bits
            ora h                   ; combine the two nibbles
            mov c,l                 ; save the first two digits in C
            mov l,a                 ; save the last two digits in L
            mov h,c                 ; save the first two digits in H
            sub a                   ; clear the carry flag
            ret

;------------------------------------------------------------------------
; get two hex digits from the serial port and convert them into a
; byte returned in A.  enter key exits if fewer than two digits.
; returns with carry flag set if escape key is pressed.
; uses A, BC and E
;------------------------------------------------------------------------
get_two:    call get_hex            ; get the first character
            jc get_two5             ; jump if space, enter or escape

; the first character is a valid hex digit 0-F
            call ascii2hex          ; convert to hex nibble
            rlc                     ; rotate into the most significant nibble
            rlc
            rlc
            rlc
            ani 0F0H                ; mast out least signifficant nibble
            mov c,a                 ; save the first digit in C as the most significant nibble
            
            call get_hex            ; get the second character
            jnc get_two2
            cpi 0DH                 ; enter key?
            jnz get_two5            ; jump if space or escape
            mov a,c                 ; retrieve the first digit
            rrc                     ; rotate the first digit back the the least significant nibble
            rrc
            rrc
            rrc
            ani 0FH                 ; mask out the most significant nibble
            mov b,a                 ; save the first digit in B
            jmp get_two3
            
; the second character is a valid hex digit 0-F            
get_two2:   call ascii2hex          ; convert to hex nibble
            ani 0FH                 ; mask out the most significant bits
            ora c                   ; combine the two nibbles
            mov b,a
get_two3:   sub a                   ; clear the carry flag
            mov a,b
            ret

; return with carry flag set
get_two5:   mov b,a
            mvi a,1
            rrc                     ; set the carry flag
            mov a,b
            ret

get_one:    call get_hex
            jc get_one_err
            call ascii2hex
            mov b,a
            sub a                   ; clear the carry flag
            mov a,b
            ret
get_one_err: 
            mov b,a
            mvi a,1
            rrc                     ; set the carry flag
            mov a,b
            ret
            
            
;------------------------------------------------------------------
; get an ASCII hex character 0-F in A from the serial port.
; echo the character if it's a valid hex digit.
; return with the carry flag set if ENTER, ESCAPE, or SPACE
; uses A, B, and E
;------------------------------------------------------------------
get_hex:    call getch          
            ani 01111111B           ; mask out most significant bit
            cpi 0DH
            jz get_hex3             ; jump if enter key
            cpi 1BH
            jz get_hex3             ; jump if escape key
            cpi 20H
            jz get_hex3             ; jump if space
            cpi '0'
            jc get_hex              ; try again if less than '0'
            cpi 'a'
            jc get_hex1             ; jump if already upper case...
            sui 20H                 ; else convert to upper case
get_hex1:   cpi 'G'
            jnc get_hex             ; try again if greater than 'F'
            cpi ':'
            jc get_hex2             ; continue if '0'-'9'
            cpi 'A'
            jc get_hex              ; try again if less than 'A'
            
get_hex2:   mov b,a                 ; save the character in B
            call putch              ; echo the character
            sub a                   ; clear the carry flag
            mov a,b                 ; restore the character
            ret                     ; return with carry cleared and character in a

get_hex3:   mov b,a
            mvi a,1
            rrc                     ; set carry flag
            mov a,b
            ret                     ; return with carry set and character in a  
            
;-------------------------------------------------------------------------
; write the byte in A to the serial port as two ASCII hex characters.
; uses A, D and E.
;-------------------------------------------------------------------------
write_hex:  mov d,a                 ; save the byte in D
            rrc                     ; rotate most significant nibble into lower 4 bits
            rrc
            rrc
            rrc
            call hex2ascii          ; convert the most significand digit to ascii
            call putch              ; print the most significant digit
            mov a,d                 ; restore
            call hex2ascii
            call putch
            ret

;------------------------------------------------------------------------
; convert the lower nibble in A to an ASCII hex character returned in A.
; uses A and E.
;------------------------------------------------------------------------
hex2ascii:  ani 0FH                 ; mask all but the lower nibble
            mov e,a                 ; save the nibble in E
            sui 10
            mov a,e
            jc hex2ascii1           ; jump if the nibble is less than 10
            adi 7                   ; add 7 to convert to A-F
hex2ascii1: adi 30H
            ret
            
;------------------------------------------------------------------------
; convert an ascii character in A to its hex equivalent.
; return value in lower nibble, upper nibble zeros
; uses A and E.
;------------------------------------------------------------------------
ascii2hex:  cpi 'a'
            jc ascii2hex1           ; jump if already upper case...
            sui 20H                 ; else convert to upper case
ascii2hex1: sui 30H
            mov e,a                 ; save the result in b
            sui 0AH                 ; subtract 10 decimal
            jc  ascii2hex2
            mov a,e                 ; restore the value
            sui 7
            mov e,a
ascii2hex2: mov a,e
            ret            
            
;------------------------------------------------------------------------        
; serially print carrage return and line feed
; uses A and E.
;------------------------------------------------------------------------
crlf:       mvi a,0DH
            call putch
            mvi a,0AH
            jmp putch
            
;------------------------------------------------------------------------        
; serially print a space
; uses A and E.
;------------------------------------------------------------------------
space:      mvi a,' '
            jmp putch            

;------------------------------------------------------------------------        
; serially print the null terminated string whose address is in HL.
; uses A and E and HL      
;------------------------------------------------------------------------
puts:       mov a,m
            ana a
            rz                      ; end of string
            call putch
            inr l                   ; next character
            jnz puts
            inr h
            jmp puts

;------------------------------------------------------------------------        
; Includes the right serial library, depending on defines
;------------------------------------------------------------------------

            include "serial.inc"
            include "stack.inc"

;------------------------------------------------------------------------        
; For MasterBlaster, include the master menu
;------------------------------------------------------------------------

            ifdef master
            include "master.inc"
            endif

;------------------------------------------------------------------------        
; For SBC, include the sound library
;------------------------------------------------------------------------

            ifdef sound
            include "sound.inc"
            endif

;------------------------------------------------------------------------        
; sends the character in A out from the serial port at 2400 bps.
; uses A and E.
; for 2400 bps, each bit should be 104 cycles
;------------------------------------------------------------------------
putch:      mov e,b                 ; save B
            call CPRINT
            mov b,e
            ret
            
;-----------------------------------------------------------------------------------------
; wait for a character from the serial port. 
; echo each bit as it is received. return the received character in A.
; uses A and E.
;-----------------------------------------------------------------------------------------

getche:     mov e,b            ; save B
            ifdef bitbang
            CALL CINP          ; bitbang does not take kindly to calling CPRINT separately
            else
            call CINPNE
            ani 07FH           ; strip high bit, for H9, otherwise we'll echo it

            ifdef nocr
            cpi 00DH
            jz getche_so
            endif

            call CPRINT
            endif
getche_so:  mov b,e
            ret

;-----------------------------------------------------------------------------------------
; wait for a character from the serial port. 
; do not echo. return the character in A.
; uses A and E.
; for 2400 bps, each bit should be 104 cycles
;-----------------------------------------------------------------------------------------

getch:      mov e,b            ; save B
            call CINPNE
            ani 07FH           ; strip high bit, for H9, otherwise we'll echo it
            mov b,e
            ret

getch_bin:  mov e,b            ; save B
            call CINPNE        ; do not strip the high bit here
            mov b,e
            ret
            
titletxt:   db  "\r\n\r\n"
            db  "Serial Monitor for Intel 8008 H8 CPU Board V2.0\r\n"
            db  "Original by Jim Loos\r\n"
            db  "Modified by Scott Baker, https://www.smbaker.com/ for h8 project\r\n"
            db  "Assembled on ",DATE," at ",TIME,"\r\n",0
menutxt:    db  "\r\n"
            db  "B - Basic\r\n"
            db  "C - Call subroutine\r\n"
            db  "D - Dump RAM\r\n"
            db  "E - Examine/Modify RAM\r\n"            
            db  "F - Fill RAM\r\n"
            db  "H - Hex file download\r\n"
            db  "G - Go to address\r\n"
            db  "I - Input byte from port\r\n"

            ifdef master
            db  "M - Master\r\n"
            endif

            db  "O - Output byte to port\r\n"
            db  "R - Raw binary file download\r\n"
            db  "S - Switch bank and load rom\r\n"

            ifdef frontpanel_isr
            db  "Y - Enable/Start interrupts\r\n"
            db  "Z - Disable interrupts\r\n"
            endif ; frontpanel_isr

            db 0

prompttxt:  db  "\r\n>>",0
dumptxt:    db  "ump memory\r\n",0
examinetxt: db  "xamine memory\r\n",0
filltxt:    db  "ill memory\r\n",0
jumptxt:    db  "ump to address: (in hex) ",0 
calltxt:    db  "all subroutine at address: ",0 
gototxt:    db  "o to address: (in hex) ",0
inputtxt    db  "nput byte from port",0
outputtxt   db  "utput byte to port",0 
binloadtxt: db  "aw binary file download\r\n",0 
hexloadtxt: db  "ex file download\r\n",0
addresstxt: db  "\r\nAddress: (in hex) ",0 
hcounttxt:  db  "  Count: (in hex) ",0
valuetxt:   db  "  Value: (in hex) ",0   
columntxt:  db  "\r\n     00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F",0
dnldtxt:    db  "\r\nWaiting for the binary file download.\r\n",0   
waittxt:    db  "\r\nWaiting for the Intel hex file download.\r\n",0
loadedtxt:  db  "\r\nFile loaded.\r\n",0  
errortxt:   db  "\r\nChecksum error!\r\n",0
arrowtxt:   db  " --> ",0
newvaluetxt:db  "  New: ",0
porttxt     db  "\r\nPort address: (in hex) ",0
bytetxt     db  "\r\nOutput byte:  (in hex) ",0
copytxt     db  "\r\nIntel 8008 SBC Monitor � Copyright 2022 by Jim Loos\r\n",0
rombastxt   db  "asic\r\n",0
switchtxt   db  "witch and load bank (one digit): ",0
badbanktxt  db  "Invalid bank number\r\n",0
progtxt     db  "rogram to RAM from bank (one digit): ",0
loadingtxt  db  "\r\nSwitching banks and jumping...\r\n",0
poptxt:     db  "op stack\r\n",0
pushtxt:    db  "-pUsh stack: (in hex) ",0
disabletxt: db  "-disable iterrupts\r\n",0
enabletxt:  db  "-enable iterrupts\r\n",0
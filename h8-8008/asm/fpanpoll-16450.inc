;--------------------------------------------------------------------------------
; FCINP450
;
; CINP from 16450 with no echo and front panel service
;
; Destroys A, B
;
; Variables
;    H - always points to the monitor variable section MSB
;    A - temporary
;    B - temporary
;    C - dot mask for address octal group
;    D - dot mask for alter octal group
;
; We're enormously tight on cycles when servicing the front panel. Every cycle
; saved is less artifacting on the display. So we combined the serial ipoll and
; the front panel poll together.
;--------------------------------------------------------------------------------

FCINP450:   
           mov a,h                ; save registers
           mov b,l
           mvi h,hi(msave_H)      ; Point HL at register storage location        
           mvi l,lo(msave_H)      
           mov m,a                ; save A (entry value of H) in memory
           inr l                  ; advance pointer
           mov m,b                ; save B (entry value of L) in memory
           inr l
           mov m,c                ; save C
           inr l
           mov m,d                ; save D

           mvi c,0FFH             ; Intialize all dots off
           mvi d,0FFH

RXPOLL:    in ser_lsr             ; poll for serial ready
           ani 01H
           jz FPANPOLL            ; no character pending -- jump to next check

           mvi h,hi(msave_H)      ; Point HL at register storage location      
           mvi l,lo(msave_H) 
           mov a,m
           inr l
           mov b,m
           inr l
           mov c,m                ; restore C
           inr l
           mov d,m                ; restore D
           mov h,a                ; restore H
           mov l,b                ; restore L

           in ser_rhr             ; read the character from the 16450
           ifndef nocinp80
           ori 80h                ; SCELBAL needs to have the most significant bit set
           endif
           ret                    ; finally, we can return

FPANRET:
FPANPOLL:
           in ipoll               ; check if interrupt pending
           ani 02H                ; int1 == 0x02 is the front panel asking for service
           jnz FPANSVC            ; front panel interrupt pending -- service it
           jmp RXPOLL             ; no display interrupt, go back to polling

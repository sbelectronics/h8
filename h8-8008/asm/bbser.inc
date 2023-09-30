             ifndef   bbser    ; avoid multiple inclusion
bbser     equ      1

; Downloaded from https://github.com/jim11662418/8008-SBC by Jim Loos
; Modified by smbaker for H8-8008 project

INPORT      equ 0                   ; serial input port address
OUTPORT     equ 08h                 ; serial output port address

;-----------------------------------------------------------------------------------------       
; I/O routines for 16450/16550 UART in Heathkit H8
;
; Scott Baker, https://www.smbaker.com
;-----------------------------------------------------------------------------------------


;-----------------------------------------------------------------------------------------       
; SINITBB: initialize serial port
;-----------------------------------------------------------------------------------------

SINITBB:    mvi a,1
            out 08h                 ; set serial output high (mark)
            ret

;-----------------------------------------------------------------------------------------       
; CINPBB: wait for and read character
;-----------------------------------------------------------------------------------------



;-----------------------------------------------------------------------------------------
; 2400 bps character input subroutine for SCELBAL
; wait for a character from the serial port. 
; echo the character. return the character in A.
; uses A and B.
;-----------------------------------------------------------------------------------------
            ifndef nocinp
CINPBB:     in INPORT               ; get input from serial port
            rar                     ; rotate the received serial bit right into carry
            jc CINPBB               ; jump back if start bit was not detected (input was high)

            ; start bit detected. 1/2 bit time then send start bit
            mvi b,0                 ; initialize B
            mvi b,0                 ; timing adjustment
            xra a                   ; clear the accumulator
            out OUTPORT             ; send the start bit
            call delay1             ; timing adjustment
            mvi b,0                 ; timing adjustment            
            
            ; receive and echo bits 0 through 7
            call getbitecho         ; receive/echo bit 0
            call getbitecho         ; receive/echo bit 1
            call getbitecho         ; receive/echo bit 2
            call getbitecho         ; receive/echo bit 3
            call getbitecho         ; receive/echo bit 4
            call getbitecho         ; receive/echo bit 5
            call getbitecho         ; receive/echo bit 6
            call getbitecho         ; receive/echo bit 7
            
            ; wait 1 bit time, then send the stop bit
            mov a,b                 ; save the character from B to A
            mvi b,0feh              ; timing adjustment
            call delay              ; timing adjustment
            mov b,a                 ; restore the chararacter from A to B
            mvi a,1                 ; '1' for stop bit
            out OUTPORT             ; send the stop bit
            ; wait 1 bit time
            mov a,b                 ; restore the character from B to A
            mvi b,0feh              ; timing adjustment
            call delay              ; timing adjustment
            ifndef nocinp80
            ori 80h                 ; SCELBAL needs to have the most significant bit set
            endif
            ret                     ; return to caller

getbitecho: mov a,b                 ; save the received bits from B to A
            mvi b,0ffh              ; timing adjustment
            call delay              ; timing adjustment
            mov b,a                 ; restore the received bits from A to B
            ana a                   ; timing adjustment
            in INPORT               ; get input from the serial port
            out OUTPORT             ; echo the received bit
            rar                     ; rotate the received bit right into carry
            mov a,b                 ; restore the previously received bits from B to A
            rar                     ; rotate the newly received bit in carry right into the MSB of A
            mov b,a                 ; save the received bits in B
            ret
            endif

;-----------------------------------------------------------------------------------------
; 2400 bps character input subroutine for SCELBAL. Without echo.
; wait for a character from the serial port. 
; echo the character. return the character in A.
; uses A and B.
;-----------------------------------------------------------------------------------------
            ifndef nocinpne
CINPNEBB:   in INPORT               ; get input from serial port
            rar                     ; rotate the received serial bit right into carry
            jc CINPNEBB             ; jump back if start bit was not detected (input was high)

            ; start bit detected. 1/2 bit time then send start bit
            mvi b,0                 ; initialize B
            mvi b,0                 ; timing adjustment
            xra a                   ; clear the accumulator
            mvi a,0                 ; timing
            call delay1             ; timing
            mvi b,0                 ; timing
            
            ; receive and echo bits 0 through 7
            call getbit         ; receive bit 0
            call getbit         ; receive bit 1
            call getbit         ; receive bit 2
            call getbit         ; receive bit 3
            call getbit         ; receive bit 4
            call getbit         ; receive bit 5
            call getbit         ; receive bit 6
            call getbit         ; receive bit 7
            
            ; wait 1 bit time, then send the stop bit
            mov a,b                 ; save the character from B to A
            mvi b,0feh              ; timing adjustment
            call delay              ; timing adjustment
            mov b,a                 ; restore the chararacter from A to B
            mvi a,1                 ; '1' for stop bit
            mvi a,1                 ; timing
            ; wait 1 bit time
            mov a,b                 ; restore the character from B to A
            mvi b,0feh              ; timing adjustment
            call delay              ; timing adjustment
            ifndef nocinp80
            ori 80h                 ; SCELBAL needs to have the most significant bit set
            endif
            ret                     ; return to caller

getbit:     mov a,b                 ; save the received bits from B to A
            mvi b,0ffh              ; timing adjustment
            call delay              ; timing adjustment
            mov b,a                 ; restore the received bits from A to B
            ana a                   ; timing adjustment
            in INPORT               ; get input from the serial port
            in INPORT               ; timing
            rar                     ; rotate the received bit right into carry
            mov a,b                 ; restore the previously received bits from B to A
            rar                     ; rotate the newly received bit in carry right into the MSB of A
            mov b,a                 ; save the received bits in B
            ret
            endif

;-----------------------------------------------------------------------------------------       
; CRDYBB: return Zero if no character ready, NonZero if character ready
;-----------------------------------------------------------------------------------------

CRDYBB:    in inport
           xri 0FFH                 ; invert it
           ani 01H                  ; returns nonzero if start bit was detected
           ret

;-----------------------------------------------------------------------------------------       
; CPRINTBB: print character
;-----------------------------------------------------------------------------------------

;------------------------------------------------------------------------        
; 2400 bps character output subroutine for SCELBAL
; uses A and B.
; returns with the original character in A
;------------------------------------------------------------------------
CPRINTBB:   ani 7fh                 ; mask off the most significant bit of the character
            mov b,a                 ; save the character from A to B
            xra a                   ; clear A for the start bit
            out 08h                 ; send the start bit
            mov a,b                 ; restore the character from B to A 
            mov a,b                 ; timing adjustment
            mvi b,0fdh              ; timing adjustment
            mvi b,0fdh              ; timing adjustment        
            call delay              ; timing adjustment
            
            ; send bits 0 through 7
            call putbit             ; transmit bit 0
            call putbit             ; transmit bit 1
            call putbit             ; transmit bit 2
            call putbit             ; transmit bit 3
            call putbit             ; transmit bit 4
            call putbit             ; transmit bit 5
            call putbit             ; transmit bit 6
            call putbit             ; transmit bit 7            

            ; send the stop bit 
            mov b,a                 ; save the character from A to B
            mvi a,1                 ; '1' for the stop bit
            out 08h                 ; send the stop bit 
            mov a,b                 ; restore the original character from B to A
            ifndef nocinp80
            ori 80h                 ; restore the most significant bit of the character XXX timing adjustment??
            endif
            mvi b,0fch              ; timing adjustment
            call delay              ; timing adjustment
            ret                     ; return to caller

putbit:     out 08h                 ; output the least significant bit of the character in A
            mvi b,0fdh              ; timing adjustment
            mvi b,0fdh              ; timing adjustment
            call delay              ; timing adjustment
            rrc                     ; shift the character in A right
            ret

;------------------------------------------------------------------------        
; delay in microseconds = (((255-value in B)*16)+19) * 4 microseconds
;------------------------------------------------------------------------        
delay:      inr b
            jnz delay
delay1:     ret

            endif                ; bbser
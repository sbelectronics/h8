             ifndef   scelser    ; avoid multiple inclusion
scelser     equ      1

            cpu 8008                ; use "old" mneumonics for SCELBAL
            RADIX 8                 ; use octal for numbers

INPORT: EQU 5
OUTPORT: EQU 016

;-----------------------------------------------------------------------------------------       
; SINITSCEL: initialize serial port
;-----------------------------------------------------------------------------------------

SINITSCEL: ret

;-----------------------------------------------------------------------------------------       
; CINPSCEL: wait for and read character
;-----------------------------------------------------------------------------------------

;;; HERE IS THE USER DEFINED CHARACTER INPUT TO READ FROM SERIAL PORT
	
CINPSCEL:	INP INPORT
	NDA
	JTS CINP
	XRA
	LBI 104

MORE1:	DCB
	JFZ MORE1
	OUT OUTPORT
	CAL TIMER
	CAL NEXBIT
	CAL NEXBIT
	CAL NEXBIT
	CAL NEXBIT
	CAL NEXBIT
	CAL NEXBIT
	CAL NEXBIT
	CAL NEXBIT

STOP:	LAI 001
	OUT OUTPORT
	LAB
	RLC
	LBI 314

MORE3:	DCB
	JFZ MORE3
	RET

NEXBIT:	INP INPORT
	NDI 200

       RLC
       OUT OUTPORT
       RRC
	ADB
	RRC
TIMER:	LBI 213
MORE2:	DCB
	JFZ MORE2
	LBA
	RET

;-----------------------------------------------------------------------------------------       
; CPRINTSCEL: print character
;-----------------------------------------------------------------------------------------

CPRINTSCEL:	
        NDA
	RAL
	OUT OUTPORT
	RAR
	CAL TIMER
	CAL BITOUT
	CAL BITOUT
	CAL BITOUT
	CAL BITOUT
	CAL BITOUT
	CAL BITOUT
	CAL BITOUT
	CAL BITOUT
	LBA
	LAI 001
	OUT OUTPORT
	LAB
	CAL TIMER
	LBI 103
	JMP MORE3

BITOUT:	OUT OUTPORT
	RRC
	CAL TIMER
	RET

            endif                ; scelser
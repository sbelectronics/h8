
	TITLE	'BDDVD - BUBBLE DISK DRIVER'
	EJECT
***	BDDVD - BUBBLE DISK DRIVER.
*
*	Written by Scott M Baker, http://www.smbaker.com/
*	Based on ND Driver by J.G. LETWIN

	XTEXT	ASCII
	XTEXT	DDDEF
	XTEXT	HOSDEF
	XTEXT	HOSEQU
	XTEXT	DEVDEF
        XTEXT   DIRDEF
	XTEXT	ECDEF
	XTEXT	ESINT
	XTEXT	ESVAL
	XTEXT	FILDEF
	XTEXT	PICDEF
	XTEXT	DVDDEF
	XTEXT	SETCAL

	XTEXT	BBLDEF

	CODE	PIC

***	BDCAP defines the capabilities bits for the ramdisk
*
*	DT.CW  ... Write
*	DT.CR  ... Read
*	DT.DD  ... Directory
*	DT.RN  ... Random

BDCAP EQU     DT.CW+DT.CR+DT.DD+DT.RN         Read, Write, Directory, Random

	DB	DVDFLV		DEVICE DRIVER FLAG VALUE
	DB	BDCAP		DEVICE CAPABILITIES
	DB	00000000B	MOUNTED UNIT MASK
	DB	1		UP TO 1 UNITS
	DB	BDCAP		CAPABILITIES FOR UNIT 0
	DB	0		...
	DB	0		...
	DB	0		...
	DB	0		...
	DB	0		...
	DB	0		...
	DB	0		CAPABILITIES for UNIT 7
	DB	DVDFLV		DEVICE DRIVER FLAG
	DW	0		No INIT Parameters		/80.09.gc/

.	SET	025Q						/80.09.gc/
	ERRNZ	*-.						/80.09.gc/
	ERRMI	DVD.STE-.					/80.09.gc/
	DS	DVD.STE-.	RESERVED AREAS			/80.09.gc/
	STL	'SET CODE'
	EJECT
***	SET CODE ENTRY POINT
*
*
*	ENTRY:	(DE)	=  LINE POINTER
*		(A)	=  UNIT NUMBER
*
*	EXIT:	(PSW)	=  'C' CLEAR IF NO ERROR
*			=  'C' SET   IF    ERROR
*
*	USES:	ALL
*

SETNTR	EQU	*
	ERRNZ	*-DVD.STE
	ANA	A
	JNZ	SET1
	MOV	B,D
	MOV	C,E		(BC) = PARAMETER LIST ADDRESS
	LXI	D,PRCTAB	(DE) = PROCESSOR TABLE ADDRESS
	LXI	H,OPTTAB	(HL) = OPTION TABLE ADDRESS
	CALL	$SOP
	RC			THERE WAS AN ERROR
	CALL	$SNA
	RZ			AT THE END OF THE LINE
	MVI	A,EC.ILO
	STC
	RET

SET1	MVI	A,EC.UUN	UNKNOWN UNIT NUMBER
	STC
	RET

	STL	'PROCESSORS'
	EJECT
***	PROCESSORS
*

FLAG	EQU	$PBF

	SPACE	4,10
**	HELP	-  PROCESS HELP OPTION
*
*	LIST THE VALID OPTIONS ON THE USER CONSOLE
*
*	USE 'SET BD: HELP' TO DISPLAY THIS HELP
*

HELP	CALL	$TYPTX
	DB	NL,NL,'Set Options for BD:',NL,NL
	DB	'HELP	Type this message',NL
	DB	'DEBUG  Enable debug messages',NL
	DB	NL
	DB	TAB,'The above options can be preceded by "NO" to negate their',NL
	DB	TAB,'Effect. (I.E.  SET BD: NODEBUG )',NL	
	DB	NL,ENL
	XRA	A
	RET

	SPACE	4,10
**	"what" identification

	DB	'@(#)HDOS Bubble Disk Driver v1.00 by Scott Baker.',NL
	DW	0		Date
	DW	0		Time

	STL	'SET TABLES'
	EJECT
***	SET TABLES
*
*
	SPACE	4,10
**	OPTAB	-  OPTION TABLE
*
*	CONTAINS EACH OPTION, AS WELL AS A POINTER TO THE HANLDER
*	FOR THE OPTION. FOR EXAMPLE:
*
*	   DEBUG -- sets bit0 in BDDEBUG to 1
*		Handler = FLAGI
*		Bitmask = 1
*		BitBalue = 1
*		Location = BDDEBUG
*		?unknown = 0
*
*	   NODEBUG -- sets bit0 in BDDEBUG to 0
*		Handler = FLAGI
*		Bitmask = 1
*		BitBalue = 0
*		Location = BDDEBUG
*		?unknown = 0

OPTTAB	DW	OPTTABE		END OF THE TABLE
	DB	6

	DB	'HEL','P'+200Q,HELPI
	DB	0,0,0,0,0

	DB	'DEBU','G'+200Q,FLAGI
	DB	1,1
	DW	BDDEBUG
	DB	0

	DB	'NODEBU','G'+200Q,FLAGI
	DB	1,0
	DW	BDDEBUG
	DB	0

OPTTABE	DB	0
	SPACE	4,10
**	PRCTAB	-  PROCESSOR TABLE
*

PRCTAB	DS	0
FLAGI	EQU	*-PRCTAB/2
	DW	FLAG
HELPI	EQU	*-PRCTAB/2
	DW	HELP

	SPACE	4,10

**	THE DVD ENTRY POINT IS COMING UP NEXT. IT MUST START AT 002000A. 
*	WE HAVE TO CONSUME SPACE UNTIL WE HIT THAT ADDRESS. WE MUST NOT
*	GO OVER -- THE SET CODE MUST FIT PRIOR to 002000A.

.	SET	001127A		ADJUST THIS TO THE CURRENT ADDRESS AT THIS POINT
	ERRNZ	*-.
	DS	DVD.ENT-.
	STL	'MAIN ENTRY POINT'
	EJECT

**	MAIN ENTRY POINT

BDDVD	EQU	*
	ERRNZ	*-DVD.ENT	MUST BE AT THE ENTRY POINT
	CALL	$TBRA
	DB	BDREAD-*	READ - READ DATA
	DB	BDWRITE-*	WRITE - WRITE DATA
	DB	BDREADR-*	READR - READ REGARDLESS OF VOLUME PROTECTION
	DB	BDOPE-*		OPENR - OPEN FOR READ
	DB	BDOPE-*		OPENW - OPEN FOR WRITE
	DB	BDABT-*		OPENU - OPEN FOR UPDATE
	DB	BDNOP-*		CLOSE - CLOSE
	DB	BDNOP-*		ABORT - ABORT OPERATION
	DB	BDMNT-*		MOUNT - MOUNT VOLUME
	DB	BDLOAD-*	LOAD  - LOAD DRIVER
	DB      BDRDY-*         READY - REPORT UNIT READY STATUS

**	ABORT
*
*	ABORT OPERATION. NOT USED?

BDABT	MVI	A,EC.DDA	DEVICE DRIVER ABORT
	STC
	RET

**	OPENR, OPENW, OPENU, CLOSE, ABORT
*
*	THESE ARE ALL NO-OPS FROM OUR PERSPECTIVe. WE CAN SIMPLY
*	RETURN A CLEAR CARRY. HDOS DOES THE HEAVY LIFTING HERE.

BDOPE	EQU	*
BDNOP	ANA	A
	RET			DO NOTHING

**      STOBLK
*
*	CALCULATE BLOCK ADDRESS FROM SECTOR IN HL. WRITE TO
*	BARH/BARL.
*
*	BAR = SECNO<<2
*
*       BARL = (SECNO<<2) & 0xFC
*       BARH = ((SECNO<<2)>>8) & 0x1F
*	     = ((SECNOH<<2) & 0x1C) | ((SECNOL>>6) & 0x03)
*
*	DESTROYS
*	    A

*STOBLK	EQU	*
*	PUSH	B
*	MOV	A,L			START WITH LOW BYTE OF SECNUM
*	RLC				MULTIPLY BY...
*	RLC				...FOUR
*	ANI	0FCH			STRIP OFF THE LAST TWO BITS
*	STA	BARL			

*	MOV	A,L			START WITH LOW BYTE OF SECNUM
*	RLC				MULTIPLY BY FOUR...
*	RLC				... ROTATING TOP 2 BITS TO LOWER
*	ANI	003H			KEEP ONLY THE LAST TWO BITS
*	MOV	B,A			B = (SECNO>>6)
	
*	MOV	A,H			START WITH HIGH BYTE OF SECNUM
*	RLC				MULTIPLY BY...
*	RLC				...FOUR
*	ANI	01CH			MASK BITS 11100
*	ORA	B			OR IN THE LOWER 2 BITS
*	STA	BARH
*	POP	B
*	RET

**      STOBLK - double bubble
*
*	CALCULATE BLOCK ADDRESS FROM SECTOR IN HL. WRITE TO
*	BARH/BARL.
*
*	BAR = SECNO<<1
*
*       BARL = (SECNO<<1) & 0xFE
*       BARH = ((SECNO<<1)>>8) & 0x1F
*	     = ((SECNOH<<1) & 0x1E) | ((SECNOL>>7) & 0x01)
*
*	DESTROYS
*	    A

STOBLK	EQU	*
	PUSH	B
	MOV	A,L			START WITH LOW BYTE OF SECNUM
	RLC				MULTIPLY BY TWO
	ANI	0FEH			STRIP OFF THE LAST BIT
	STA	BARL	

	MOV	A,L			START WITH LOW BYTE OF SECNUM
	RLC				MULTIPLY BY TWO, ROTATING TOP 1 BIT TO LOWER
	ANI	001H			KEEP ONLY THE LAST TWO BITS
	MOV	B,A			B = (SECNO>>7)
	
	MOV	A,H			START WITH HIGH BYTE OF SECNUM
	RLC				MULTIPLY BY TWO
	ANI	01EH			MASK BITS 11110
	ORA	B			OR IN THE LOWER 1 BIT
	STA	BARH
	POP	B
	RET

SBC64	MOV	A,C
	SUI	040H
	MOV	C,A
	MOV	A,B
	SBI	000H
	MOV	B,A
	RET

IDE64	MOV	A,E
	ADI	040H
	MOV	E,A
	MOV	A,D
	ACI	000H
	MOV	D,A
	RET

INCBAR	LDA	BARL
	ADI	001H
	STA	BARL
	RNC
	LDA	BARH
	INR	A
	STA	BARH
	RET

**	READR
*
*	READ REGARDLESS. WE CAN JUST CALL READ AND LET READ DEAL
*	WITH IT.

BDREADR	EQU	*
	CALL    DREADR
	JMP	BDREAD1
	RET

BDREAD	EQU     *
      	CALL    DREAD

BDREAD1 EQU     *
	PUSH	B		Save caller args
	PUSH	D
	PUSH	H
RNEXT16	MOV     A,B
	CPI	041H
	JC	LASTRD		Take the easy path, read is <= 16K+1sector
	PUSH	B
	PUSH	D
	PUSH	H
	LXI	B,04000H	Set count to 16K
	CALL	SMALLRD		Read 16K
	POP	H
	POP	D
	POP	B

	MOV	A,D		Increment DE by 0x4000
	ADI	040H
	MOV	D,A

	MOV	A,B		Decrement BC by 0x4000
	SUI	040H
	MOV	B,A

	MOV	A,L             Increment HL by 0x0040
	ADI	040H
	MOV	L,A
	MOV	A,H
	ACI	000H		We might have carried...
	MOV	H,A
	JMP	RNEXT16

LASTRD	CALL	SMALLRD		We are almost done, less than 16K+1sector remaining
	POP	H
	POP	D
	POP	B
	ANA	A
	RET

**	WRITE DATA
*
*	BC = BYTE COUNT
*	DE = SRC ADDRESS
*	HL = BLOCK NUMBER
*
*	SEE NOTES ON READ REGARDING CHUNKS AND LARGE TRANSFERS.

BDWRITE	EQU     *
	CALL	DWRITE
	PUSH	B		Save caller args
	PUSH	D
	PUSH	H
WNEXT16	MOV     A,B
	CPI	041H
	JC	LASTWR		Take the easy path, write is <= 16K+1sector
	PUSH	B
	PUSH	D
	PUSH	H
	LXI	B,04000H	Set count to 16K
	CALL	SMALLWR		Write 16K
	POP	H
	POP	D
	POP	B

	MOV	A,D		Increment DE by 0x4000
	ADI	040H
	MOV	D,A

	MOV	A,B		Decrement BC by 0x4000
	SUI	040H
	MOV	B,A

	MOV	A,L             Increment HL by 0x0040
	ADI	040H
	MOV	L,A
	MOV	A,H
	ACI	000H		We might have carried...
	MOV	H,A
	JMP	WNEXT16

LASTWR	CALL	SMALLWR		We are almost done, less than 16K+1sector remaining
	POP	H
	POP	D
	POP	B
	ANA	A
	RET

**	BDLOAD
*
*	LOAD DRIVER. WE INITIALIZE THE MMU HERE, SO THAT ALL LOWER PAGES ARE
*	MAPPED TO GENERAL PURPOSE RAM.

BDLOAD	EQU	*
        CALL    DLOAD

*	Initialization here...

	CALL	BBLINIT
	CPI	040H			CHECK RESULT - 0x40 OP COMPLETE
	JZ	LOADOK			
	CPI	042H			0x42 OP COMPLETE AND PARITY ERROR
	JZ	LOADOK

	CALL	DIERR
	STC				SET CARRY
	RET

LOADOK	EQU	*

*	NOTE: UNSURE IF LOCKING THE DRIVER IS NECESSARY!

*       lock the driver into memory

        LHLD    S.SYSM
        SHLD    S.RFWA                  ; adjust system pointer

        LHLD    AIO.DTA                 ; table address
        LXI     D,DEV.RES
        DAD     D
        MVI     A,DR.PR                 ; permanently resident
        ORA     M                       ; combine
        MOV     M,A                     ;  and set

	ANA	A
	RET

**	BDRDY
*
*	READY CHECK. WE PASS A POINTER TO RDINFO IN DE. THE INIT MODULE WILL USE THIS
*	TO PEEK INTO OUR DRIVER SETTINGS.

BDRDY	EQU	*
	CALL	DRDY
	LXI	DE,BDINFO
	ANA	A
	RET

**	BDMNT
*
*	MOUNT. THIS WOULD BE A GOOD PLACE TO INSERT A SANITY CHECK TO MAKE SURE THERE
*	IS A RAM CHIP INSTALLED FOR THE UNIT. RIGHT NOW WE BLINDLY LET THE USER MOUNT
*	WITHOUT CHECKING.

BDMNT	EQU	*
	CALL	DMNT
	ANA	A
	RET

**	SMALLRD
*
*	PERFORM A READ OF 16640 BYTES OR LESS. 
*
*	BC = BYTE COUNT --> HL
*	DE = DEST ADDRESS
*	HL = BLOCK NUMBER --> BARH/BARL

SMALLRD	EQU     *
	MOV	A,B
	ORA	C
	RZ				Asking to read 0 bytes so just return

	PUSH	B			SAVE BC
	PUSH	H			SAVE HL
	CALL	STOBLK
	MOV	H,B			MOVE BYTE COUNT FROM BC ...
	MOV	L,C			... TO HL
	CALL	BBLREAD
	CPI	040H			CHECK RESULT - 0x40 OP COMPLETE
	JZ	RDOK			
	CPI	042H			0x42 OP COMPLETE AND PARITY ERROR
	JZ	RDOK	
	CALL	DRERR
RDOK	POP	H			RESTORE HL
	POP	B			RESTORE BC
	ANA	A
	RET

**	SMALLWR
*
*	PERFORM A WRITE OF 16640 BYTES OR LESS. 
*
*	BC = BYTE COUNT
*	DE = SRC ADDRESS
*	HL = BLOCK NUMBER

SMALLWR	EQU     *
	MOV	A,B
	ORA	C
	RZ				Asking to write 0 bytes so just return

	PUSH	B			SAVE BC
	PUSH	H			SAVE HL
	CALL	STOBLK
	MOV	H,B			MOVE BYTE COUNT FROM BC ...
	MOV	L,C			... TO HL
	CALL	BBLWRIT
	CPI	040H			CHECK RESULT - 0x40 OP COMPLETE
	JZ	WROK			
	CPI	042H			0x42 OP COMPLETE AND PARITY ERROR
	JZ	WROK
	CALL	DWERR
WROK	POP	H			RESTORE HL
	POP	B			RESTORE BC
	ANA	A
	RET


** 	LIBRARY CODE IS LOADED HERE
*
*	PRHEX - HEX PRITING
*	DEBUG - DEBUG PRINT STATEMENTS
*	TBRA - TABLE LOOKUPS?
*	TYPTX - HELP TABLE PRINTER

	XTEXT	BBLCOM
	XTEXT	BBLRW
	XTEXT	PRHEX
	XTEXT	DEBUG

	XTEXT	TBRA
	XTEXT	TYPTX

** 	BDINFO BLOCK
*
*	HERE ARE OPTIONS AND OTHER FLAGS. THE ORDER IS IMPORTANT. DO NOT REORDER THESE
*	WITHOUT CONSIDERING THE CONSEQUENCES. THE INIT MODULE WILL LOOK FOR THESE.

BDINFO	EQU	*		ITEMS HERE ARE SHARED WITH INIT. DO NOT CHANGE THE ORDER HERE!
BDMARK	DW	0CEFAH          Sanity check used in our init module
BDDEBUG	DB	1
RSVD0	DB	0
RSVD1	DB	0		RESERVED FLAG 1
RSVD2	DB	0		RESERVED FLAG 2
BDUNIT	DB	0		Unit number

	XTEXT	BBLVAR

RDDEBUG EQU	BDDEBUG		DEBUG.ACM assumes ramdisk naming

**	STUFF FROM ND.ASM

	DB	'RW'		DUMY ADDRESS FOR RELOCATION
	DS	32		PATCH AREA

	LON	G

	END

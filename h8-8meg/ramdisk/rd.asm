
	TITLE	'RDDVD - RD DEVICE DRIVER'
	EJECT
***	RDDVD - RD DEVICE DRIVER.
*
*	J.G. LETWIN
*       SMBAKER
*
*       notes
*          AIO.UNI is unit number 


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
	XTEXT   PGREG

	CODE	PIC

RDCAP EQU     DT.CW+DT.CR+DT.DD+DT.RN         Read, Write, Directory, Random

	DB	DVDFLV		DEVICE DRIVER FLAG VALUE
	DB	RDCAP
	DB	00000000B	MOUNTED UNIT MASK
	DB	8		up to 8 units
	DB	RDCAP
	DB	RDCAP
	DB	RDCAP
	DB	RDCAP
	DB	RDCAP
	DB	RDCAP
	DB	RDCAP
	DB	RDCAP	
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

HELP	CALL	$TYPTX
	DB	NL,NL,'Set Options for RD:',NL,NL
	DB	'HELP	Type this message',NL
	DB	'DEBUG  Enable debug messages',NL
	DB	'TINY   512K-only board',NL
	DB	NL
	DB	TAB,'The above options can be preceded by "NO" to negate their',NL
	DB	TAB,'Effect. (I.E.  SET RD: NODEBUG )',NL	
	DB	NL,ENL
	XRA	A
	RET
	STL	'SET TABLES'
	EJECT
***	SET TABLES
*
*
	SPACE	4,10
**	OPTAB	-  OPTION TABLE
*

OPTTAB	DW	OPTTABE		END OF THE TABLE
	DB	6

	DB	'HEL','P'+200Q,HELPI
	DB	0,0,0,0,0

	DB	'DEBU','G'+200Q,FLAGI
	DB	1,1
	DW	RDDEBUG
	DB	0

	DB	'NODEBU','G'+200Q,FLAGI
	DB	1,0
	DW	RDDEBUG
	DB	0

	DB	'TIN','Y'+200Q,FLAGI
	DB	1,1
	DW	RDTINY
	DB	0

	DB	'NOTIN','Y'+200Q,FLAGI
	DB	1,0
	DW	RDTINY
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
.	SET	001116A		ADJUST THIS TO THE CURRENT ADDRESS AT THIS POINT
	ERRNZ	*-.
	DS	DVD.ENT-.
	STL	'MAIN ENTRY POINT'
	EJECT

**	MAIN ENTRY POINT

RDDVD	EQU	*
	ERRNZ	*-DVD.ENT	MUST BE AT THE ENTRY POINT
	CALL	$TBRA
	DB	RDREAD-*	READ
	DB	RDWRITE-*	WRITE
	DB	RDREADR-*	READR
	DB	RDOPE-*		OPENR
	DB	RDOPE-*		OPENW
	DB	RDABT-*		OPENU
	DB	RDNOP-*		CLOSE
	DB	RDNOP-*		ABORT
	DB	RDMNT-*		MOUNT
	DB	RDLOAD-*	LOAD
	DB      RDRDY-*         READY

RDABT	MVI	A,EC.DDA	DEVICE DRIVER ABORT
	STC
	RET

RDOPE	EQU	*
RDNOP	ANA	A
	RET			DO NOTHING

RDREADR	EQU	*
	CALL    DREADR
	JMP	RDREAD1
	RET


** Address calculation
**
**   in: sector number in HL
**   out: page number in A, offset in HL
**
**   secaddr = sector<<8
**   pgl  = (secaddr >> 14) & 0x7F
**
**   pgl = (sector >> 6) & 0xFF
**   ofs = (sector << 8) & 0x3F00
**
**   pgl = (L & 0xC0) >> 6
**   pgl = pgl | (H & 0x1F) << 2

CALCPG	EQU 	*
	PUSH	B		Pushes both B and C
	LDA	AIO.UNI
	ORA	A
	JNZ	CALCN0		Not unit 0
	INR	H		Skip the first 256 sectors == 4 pages
CALCN0	EQU	*
	MOV 	A,L
	ANI 	0C0H
	RRC
	RRC
	RRC
	RRC
	RRC
	RRC
	MOV 	B,A
	MOV	A,H
	ANI	01FH
	RLC
	RLC
	ORA 	B
	POP 	B		Pops both B and C
	PUSH	PSW
	MOV     A,L
	ANI	03FH
	MOV	H,A
	MVI	L,000H
	POP	PSW
	RET

** Read Data
** BC = Byte Count
** DE = Dest Address
** HL = Block Number

RDREAD	EQU	*
	CALL    DREAD
RDREAD1 EQU     *

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

** Write Data
** BC = Byte Count
** DE = Src Address
** HL = Block Number

RDWRITE	EQU     *
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

RDLOAD	EQU	*
        CALL    DLOAD
	CALL    PGINIT
	ANA	A
	RET

RDRDY	EQU	*
	CALL	DRDY
	ANA	A
	RET

RDMNT	EQU	*
	CALL	DMNT
	ANA	A
	RET

** Read/Write functions

SMALLRD	EQU	*
	MOV	A,B
	ORA	C
	JZ	SROUT		Asking to write 0 bytes

	CALL    CALCPG
	CALL	DPAGE
	OUT	RD00K,A		Map page0 to virt-page in ramdisk
	INR	A
	OUT	RD16K,A		Always allocate two pages, so we can handle writes that are greater than 16K

	DI
	LDA	AIO.UNI
	ORI	080H		Select the proper bank, and turn on paging
	OUT     RD00KH,A
	OUT	RD16KH,A

RLOOP   MOV     A,M             Load value in memory location HL into A
	STAX	D               Store value in A into memory location DE
	INX	D
	INX	H
        DCX     B
	MOV	A,B
	ORA	C
	JNZ	RLOOP

	MVI     A,000H
	OUT	RD00KH,A        disable paging and map page0 back to virt-page0
	OUT     RD00K,A		... and bank 0
	OUT     RD16KH,A        ... and page 1 back to bank 0
	INR	A
	OUT	RD16K,A		... and page 1 back to virt-page1
	EI
SROUT	RET

SMALLWR	EQU	*
	MOV	A,B
	ORA	C
	JZ	SWOUT		Asking to write 0 bytes

	CALL    CALCPG
	CALL	DPAGE
	OUT	WR00K,A		Map page0 to virt-page in ramdisk
	INR	A
	OUT	WR16K,A		Always allocate two pages, so we can handle writes that are greater than 16K

	DI
	LDA	AIO.UNI
	ORI	080H		Select the proper bank, and turn on paging
	OUT     WR00KH,A
	OUT	WR16KH,A

WLOOP   LDAX	D               Load value in memory location DE into A
	MOV     M,A             Store value in A into memory location HL
	INX	D
	INX	H
        DCX     B
	MOV	A,B
	ORA	C
	JNZ	WLOOP

	MVI     A,000H		
	OUT	WR00KH,A        disable paging and map page0 back to virt-page0
	OUT     WR00K,A		... and bank 0
	OUT     WR16KH,A        ... and page 1 back to bank 0
	INR	A
	OUT	WR16K,A		... and page 1 back to virt-page1
	EI

SWOUT	RET

** Library stuff

	XTEXT	PGMAP
	XTEXT	PRHEX
	XTEXT	DEBUG

	XTEXT	TBRA
	XTEXT	TYPTX

** flags

RDDEBUG	DB	0
RDTINY	DB	0

** stuff

	DB	'RW'		DUMY ADDRESS FOR RELOCATION
	DS	32		PATCH AREA

	LON	G

	END

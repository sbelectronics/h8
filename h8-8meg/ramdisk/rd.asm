
	TITLE	'RDDVD - RD DEVICE DRIVER'
	EJECT
***	RDDVD - RD DEVICE DRIVER.
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
	XTEXT   PGREG

	CODE	PIC

***	RDCAP defines the capabilities bits for the ramdisk
*
*	DT.CW  ... Write
*	DT.CR  ... Read
*	DT.DD  ... Directory
*	DT.RN  ... Random

RDCAP EQU     DT.CW+DT.CR+DT.DD+DT.RN         Read, Write, Directory, Random

	DB	DVDFLV		DEVICE DRIVER FLAG VALUE
	DB	RDCAP		DEVICE CAPABILITIES
	DB	00000000B	MOUNTED UNIT MASK
	DB	8		UP TO 8 UNITS
	DB	RDCAP		CAPABILITIES FOR UNIT 0
	DB	RDCAP		...
	DB	RDCAP		...
	DB	RDCAP		...
	DB	RDCAP		...
	DB	RDCAP		...
	DB	RDCAP		...
	DB	RDCAP		CAPABILITIES for UNIT 7
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
*	USE 'SET RD: HELP' TO DISPLAY THIS HELP
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

	SPACE	4,10
**	"what" identification

	DB	'@(#)HDOS Ramdisk Driver v1.03 by Scott Baker.',NL
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
*	   DEBUG -- sets bit0 in RDDEBUG to 1
*		Handler = FLAGI
*		Bitmask = 1
*		BitBalue = 1
*		Location = RDDEBUG
*		?unknown = 0
*
*	   NODEBUG -- sets bit0 in RDDEBUG to 0
*		Handler = FLAGI
*		Bitmask = 1
*		BitBalue = 0
*		Location = RDDEBUG
*		?unknown = 0

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

**	THE DVD ENTRY POINT IS COMING UP NEXT. IT MUST START AT 002000A. 
*	WE HAVE TO CONSUME SPACE UNTIL WE HIT THAT ADDRESS. WE MUST NOT
*	GO OVER -- THE SET CODE MUST FIT PRIOR to 002000A.

.	SET	001200A		ADJUST THIS TO THE CURRENT ADDRESS AT THIS POINT
	ERRNZ	*-.
	DS	DVD.ENT-.
	STL	'MAIN ENTRY POINT'
	EJECT

**	MAIN ENTRY POINT

RDDVD	EQU	*
	ERRNZ	*-DVD.ENT	MUST BE AT THE ENTRY POINT
	CALL	$TBRA
	DB	RDREAD-*	READ - READ DATA
	DB	RDWRITE-*	WRITE - WRITE DATA
	DB	RDREADR-*	READR - READ REGARDLESS OF VOLUME PROTECTION
	DB	RDOPE-*		OPENR - OPEN FOR READ
	DB	RDOPE-*		OPENW - OPEN FOR WRITE
	DB	RDABT-*		OPENU - OPEN FOR UPDATE
	DB	RDNOP-*		CLOSE - CLOSE
	DB	RDNOP-*		ABORT - ABORT OPERATION
	DB	RDMNT-*		MOUNT - MOUNT VOLUME
	DB	RDLOAD-*	LOAD  - LOAD DRIVER
	DB      RDRDY-*         READY - REPORT UNIT READY STATUS

**	ABORT
*
*	ABORT OPERATION. NOT USED?

RDABT	MVI	A,EC.DDA	DEVICE DRIVER ABORT
	STC
	RET

**	OPENR, OPENW, OPENU, CLOSE, ABORT
*
*	THESE ARE ALL NO-OPS FROM OUR PERSPECTIVe. WE CAN SIMPLY
*	RETURN A CLEAR CARRY. HDOS DOES THE HEAVY LIFTING HERE.

RDOPE	EQU	*
RDNOP	ANA	A
	RET			DO NOTHING

**	READR
*
*	READ REGARDLESS. WE CAN JUST CALL READ AND LET READ DEAL
*	WITH IT.

RDREADR	EQU	*
	CALL    DREADR
	JMP	RDREAD1
	RET


** ADDRESS CALCULATION
*
*	IN: SECTOR NUMBER IN HL
* 	OUT: PAGE NUMBER IN A, OFFSET WITHIN PAGE IN HL
*
*	THIS IS WHAT WE WANT TO DO
*		SECADDR = SECTOR<<8
*		PGL = (SECADDR >> 14) & 0X7F
*		OFS = SECADDR & 0X3F00
*
*	FIRST LEVEL OF REFACTORING
*		PGL = (SECTOR >> 6) & 0XFF
*		OFS = (SECTOR << 8) & 0X3F00
*
*	GETTING CLOSER TO ASSEMBLY LANGUAGE
*		PGL = (L & 0XC0) >> 6
*		PGL = PGL | (H & 0X1F) << 2
*		OFS = (L & 0x3F)<<8

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

**	READ DATA
*
*	BC = BYTE COUNT
*	DE = DEST ADDRESS
*	HL = BLOCK NUMBER
*
*	BYTE COUNT SHOULD BE A MULTIPLE OF 256 (UNVERIFIED)
*	BYTE COUNT COULD BE VERY LARGE. HAVE OBSERVED > 16K
*
*	GENERAL IDEA IS TO DEAL WITH THE DATA IN CHUNKS OF UP TO
*	16640 BYTES. WE CAN GUARANTEE THIS WILL FIT INTO 2 PAGES, ASSUMING
*	THE WORST CASE THAT WE START AT ADDRESS 16128 IN THE FIRST PAGE.
*
*	SMALLRD IS THE FUNCTION WE WILL CALL TO READ A CHUNK.

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

**	WRITE DATA
*
*	BC = BYTE COUNT
*	DE = SRC ADDRESS
*	HL = BLOCK NUMBER
*
*	SEE NOTES ON READ REGARDING CHUNKS AND LARGE TRANSFERS.

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

**	RDLOAD
*
*	LOAD DRIVER. WE INITIALIZE THE MMU HERE, SO THAT ALL LOWER PAGES ARE
*	MAPPED TO GENERAL PURPOSE RAM.

RDLOAD	EQU	*
        CALL    DLOAD
	CALL    PGINIT

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

**	RDRDY
*
*	READY CHECK. WE PASS A POINTER TO RDINFO IN DE. THE INIT MODULE WILL USE THIS
*	TO PEEK INTO OUR DRIVER SETTINGS.

RDRDY	EQU	*
	CALL	DRDY
	LXI	DE,RDINFO
	ANA	A
	RET

**	RDMNT
*
*	MOUNT. THIS WOULD BE A GOOD PLACE TO INSERT A SANITY CHECK TO MAKE SURE THERE
*	IS A RAM CHIP INSTALLED FOR THE UNIT. RIGHT NOW WE BLINDLY LET THE USER MOUNT
*	WITHOUT CHECKING.

RDMNT	EQU	*
	CALL	DMNT
	ANA	A
	RET

** 	READ/WRITE HELPER FUNCTIONS FOLLOW

**	SMALLRD
*
*	PERFORM A READ OF 16640 BYTES OR LESS. 
*
*	BC = BYTE COUNT
*	DE = DEST ADDRESS
*	HL = BLOCK NUMBER

SMALLRD	EQU	*
	MOV	A,B
	ORA	C
	RZ			Asking to read 0 bytes so just return

	LDA	AIO.UNI		Store a copy of AIO.UNI since we cannot access it inside critical section
	STA	RDUNIT

	CALL    CALCPG		Calc page and offset
	CALL	DPAGE

	DI			** Start Critical section: All paging happens inside here **
	ORI	080H		Turn on paging -- keep in mind the 512K board won't pay attention to RD00KH/RD16KH
	OUT	RD00K,A		Map page0 to virt-page in ramdisk
	INR	A
	OUT	RD16K,A		Always allocate two pages, so we can handle writes that are greater than 16K
	LDA	RDUNIT
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

	MVI     A,080H		do not disable paging until the last reg (8MHz Bug)
	OUT	RD00KH,A        map page0 back to virt-page0
	OUT     RD00K,A		... and bank 0
	OUT     RD16KH,A        ... and page 1 back to bank 0
	INR	A
	OUT	RD16K,A		... and page 1 back to virt-page1
	MVI	A,001H
	OUT	RD16K,A		... and disable paging
	EI			** End Critical section **
	RET

**	SMALLWR
*
*	PERFORM A WRITE OF 16640 BYTES OR LESS. 
*
*	BC = BYTE COUNT
*	DE = SRC ADDRESS
*	HL = BLOCK NUMBER

SMALLWR	EQU	*
	MOV	A,B
	ORA	C
	RZ			Asking to write 0 bytes so just return

	LDA	AIO.UNI		Store a copy of AIO.UNI since we cannot access it inside critical section
	STA	RDUNIT

	CALL    CALCPG		Calc page and offset
	CALL	DPAGE

	DI			** Start Critical section: All paging happens inside here **
	ORI	080H		Turn on paging -- keep in mind the 512K board won't pay attention to WR00KH/WR16KH
	OUT	WR00K,A		Map page0 to virt-page in ramdisk
	INR	A
	OUT	WR16K,A		Always allocate two pages, so we can handle writes that are greater than 16K
	LDA	RDUNIT
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

	MVI     A,080H		do not disable paging until the last reg (8MHz Bug)
	OUT	WR00KH,A        map page0 back to virt-page0
	OUT     WR00K,A		... and bank 0
	OUT     WR16KH,A        ... and page 1 back to bank 0
	INR	A
	OUT	WR16K,A		... and page 1 back to virt-page1
	MVI	A,001H
	OUT	WR16K,A		... and disable paging
	EI			** End Critical Section **
	RET

** 	LIBRARY CODE IS LOADED HERE
*
*	PGMAP - PAGE MAPPING
*	PRHEX - HEX PRITING
*	DEBUG - DEBUG PRINT STATEMENTS
*	TBRA - TABLE LOOKUPS?
*	TYPTX - HELP TABLE PRINTER

	XTEXT	PGMAP
	XTEXT	PRHEX
	XTEXT	DEBUG

	XTEXT	TBRA
	XTEXT	TYPTX

** 	RDINFO BLOCK
*
*	HERE ARE OPTIONS AND OTHER FLAGS. THE ORDER IS IMPORTANT. DO NOT REORDER THESE
*	WITHOUT CONSIDERING THE CONSEQUENCES. THE INIT MODULE WILL LOOK FOR THESE.

RDINFO	EQU	*		ITEMS HERE ARE SHARED WITH INIT. DO NOT CHANGE THE ORDER HERE!
RDMARK	DW	0EDFEH          Sanity check used in our init module
RDDEBUG	DB	0
RDTINY	DB	1		Tiny mode (single 512K board) for RD0, assume true by default
RSVD1	DB	0		RESERVED FLAG 1
RSVD2	DB	0		RESERVED FLAG 2
RDUNIT	DB	0		Unit number

**	STUFF FROM ND.ASM

	DB	'RW'		DUMY ADDRESS FOR RELOCATION
	DS	32		PATCH AREA

	LON	G

	END

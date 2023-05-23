
	TITLE	'DUMP - DUMP RAMDISK CONTENTS'
	EJECT
***	DUMP - DUMP RAMDISK CONTENSTS
*
*       SMBAKER


	XTEXT	HOSDEF
	XTEXT	HOSEQU
	XTEXT   PGREG
* stuff below is for cmdline parsing
	XTEXT	ASCII
	XTEXT	DIRDEF
	XTEXT	ESVAL
	XTEXT	ECDEF
	XTEXT	IOCDEF

	ORG	04000H		

ENTRY	LXI	HJ,INTRO
	SCALL	.PRINT
	CALL	PGINIT

        LXI     H,0
        DAD     SP      
        LXI     D,STACK
        CALL    HLCPDE
        JNZ     CMD1            Command line passed on stack
        CALL    PDN
        JMP     CMD2		No Command line passed on stack
CMD1    CALL    PDN.
CMD2    CALL	START

START	LDA	UNITI
	ORA	A
	JNZ	NOTUNI0
	LDA	SPAGE
	ADI	4
	STA	SPAGE
NOTUNI0	EQU	*

	MVI	H,00H		Starting address
	MVI	L,00H

	MVI	B,0		Output 256 rows

ROWLOOP	CALL	PHEXHL
	MVI	A,' '
	SCALL	.SCOUT

	PUSH	H		Save HL so we can repeat with printing the chars
	MVI	C,16
COLLOOP	DI
	LDA	UNITI		Start with unit number
	ORI	080H		Enable mapping
	OUT	RD00KH,A
	LDA	SPAGE
	ORI	080H
	OUT	RD00K,A		Select Page Starting Page	
	MOV	D,M		Load byte in (HL) into D
	MVI	A,080H
	OUT	RD00K,A
	OUT	RD00KH,A
	MVI	A,000H
	OUT	RD00KH,A	Disable mapping
	EI

	MOV	A,D
	CALL	PHEXA
	MVI	A,' '
	SCALL	.SCOUT

	INX	H

	DCR	C
	JNZ	COLLOOP
	POP	H

	MVI	C,16
PRNLP	DI
	LDA	UNITI		Start with unit number
	ORI	080H		Enable mapping
	OUT	RD00KH,A
	LDA	SPAGE
	ORI	080H
	OUT	RD00K,A		Select Starting Page
	MOV	D,M		Load byte in (HL) into D
	MVI	A,080H
	OUT	RD00K,A
	OUT	RD00KH,A
	MVI	A,000H
	OUT	RD00K,A		Disable mapping on lower  (upper is not disabled -- do we care?)
	EI

	MOV	A,D
	CPI	020H
	JC	NOTPR
	CPI	07FH
	JNC	NOTPR
	JMP	DOPR
NOTPR	MVI	A,'.'
DOPR	SCALL	.SCOUT
	INX	H
	DCR	C
	JNZ	PRNLP

	MVI	A,012Q
	SCALL	.SCOUT

	DCR	B
	JNZ	ROWLOOP

	XRA	A
	SCALL	.EXIT

** ERROR - GENERAL ERROR MESSAGE
*

ERROR   MVI     H,NL
        SCALL   .ERROR
        MVI     A,1
        SCALL   .EXIT

** INCLUDE CODE

	XTEXT	PGMAP
	XTEXT	PRHEX
* Stuff below is for cmdline parsing
	XTEXT	ITL
	XTEXT   CCO
	XTEXT	PDN
	XTEXT	DDS
	XTEXT	TYPTX
	XTEXT   MCU
	XTEXT	MLU
	XTEXT	RCHAR
	XTEXT	RTL
	XTEXT	SOB
        XTEXT   SAVALL
	XTEXT   HLCPDE

INTRO	DB	12Q,'RAMDISK DUMP UTILITY',212Q

SPAGE	DB	0		Starting page

ITLA    DS      80              Line Buffer

**	"what" identification
	DB	'@(#)HDOS Ramdisk Dump Tool by Scott Baker.',NL
	DW	0		Date
	DW	0		Time

	LON	G
	END	ENTRY

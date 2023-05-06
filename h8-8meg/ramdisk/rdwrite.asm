
	TITLE	'RD3WRITE - WRITE TEST BYTES TO RD3'
	EJECT
***	RD3WRITE - WRITE TEST BYTES TO RD3
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

	MVI	H,00H
	MVI	L,00H

	MVI	D,00H		Starting pattern

	MVI	B,0		Write 256 rows

ROWLOOP	MVI	C,16
COLLOOP	DI
	LDA	UNITI		Start with unit number
	ORI	080H		Enable mapping
	OUT	WR00KH,A
	LDA	SPAGE
	ORI	080H
	OUT	WR00K,A		Select Page Starting Page	
	MOV	M,D		Write D into (HL)
	MVI	A,080H
	OUT	WR00K,A
	OUT	WR00KH,A
	MVI	A,000H
	OUT	WR00KH,A	Disable mapping	
	EI

	INR	D		Increment pattern
	INX	H		Increment dest addr

	DCR	C
	JNZ	COLLOOP

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

INTRO	DB	12Q,'RAMDISK WRITE TEST PATTERN',212Q

SPAGE	DB	0		Starting page

ITLA    DS      80              Line Buffer

**	"what" identification
	DB	'@(#)HDOS Ramdisk Test Pattern Tool by Scott Baker.',NL
	DW	0		Date
	DW	0		Time

	LON	G
	END	ENTRY

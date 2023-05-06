
	TITLE	'BURN- BURN RAMDISK TO FLASH'
	EJECT
***	BURN - BURN RAMDISK TO FLASH
*
*       SMBAKER

	LON	C

	XTEXT	HOSDEF
	XTEXT	HOSEQU
	XTEXT   PGREG
* stuff below is for cmdline parsing
	XTEXT	ASCII
	XTEXT	DIRDEF
	XTEXT	ESVAL
	XTEXT	ECDEF
	XTEXT	IOCDEF

	ORG	08000H		Make sure we have room to map two pages

ENTRY	LXI	H,INTRO
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
CMD2    CALL	DCOPY
	LDA	SUNITI
	ORA	A
	JZ	UNSUP
	LDA	DUNITI
	ORA	A
	JZ	UNSUP
	CALL	ISRAM
	ORA	A
	JZ	COPYFLS
	JMP	COPYRAM

** COPYFLS - COPY RAM OR FLASH TO FLASH
*

COPYFLS	LXI	H,MISFLS
	SCALL	.PRINT

	LHLD	CNT4K		
	MOV	B,H
	MOV	C,L		BC = BLOCK COUNT

	LHLD	START		HL = BLOCK NUMBER

BLKLP	CALL	DBLK

	PUSH	B
	PUSH	H		SAVE BLOCK NUMBER

	CALL	FMAP
	CALL	DMAP

	PUSH	H		SAVE OFFSET
	CALL	DIFF
	POP	H
	CALL	DDIFF

	ORA	A
	JZ	NEXT

	CALL	DERASE
	LDA	DUNITI
	MOV	C,A
	PUSH	D
	PUSH	H
	CALL	FERASE
	POP	H
	POP	D

	CALL	DBURN

	LXI	B,01000H
CLOOP	PUSH	B
	DI
	LDA	SUNITI
	ORI	080H
	OUT	RD00KH		PAGE0 BANK = SRCUNI
	MOV	A,D
	ORI	080H
	OUT	RD00K
	MOV	E,M
	MVI	A,080H
	OUT	RD00KH		RESET PAGE0 BANK
	OUT	RD00K		RESET PAGE0 PAGE
	MVI	A,000H
	OUT	RD00K		DISABLE PAGING
	EI

*				D = PAGE
*				E = BYTE READ
*				HL = OFFSET
*				D = PAGE
	LDA	DUNITI
	MOV	C,A
	MOV	A,E
	PUSH	H
	CALL	FWRITE
	POP	H

	POP	B
	INX	H
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	CLOOP

NEXT	POP	H
	POP	B
	MVI	A,12Q
	SCALL	.SCOUT
	INX	H
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	BLKLP

FINISH	XRA	A
	SCALL	.EXIT

** COPYRAM - COPY RAM TO RAM
*

COPYRAM	LXI	H,MISRAM
	SCALL	.PRINT

	MVI	B,0
CRLOOP	CALL	DCPAGE
	PUSH	B
	DI
	LDA	SUNITI
	ORI	080H
	OUT	RD00KH
	LDA	DUNITI
	ORI	080H
	OUT	WR00KH
	MOV	A,B
	ORI	080H
	OUT	RD00K
	OUT	WR00K
	LXI	H,0000H
	LXI	B,04000H
CRLOOP1	MOV	A,M
	MOV	M,A
	INX	H
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	CRLOOP1
	MVI	A,080H
	OUT	RD00KH
	OUT	WR00KH
	OUT	RD00K
	OUT	WR00K
	MVI	A,000H
	OUT	WR00K
	EI
	POP	B
	INR	B
	MOV	A,B
	CPI	080H		128 16K pages
	JNZ	CRLOOP

	XRA	A
	SCALL	.EXIT

** UNSUP - RD0 IS UNSUPPORTED
*

UNSUP	LXI	H,MUNSUP
	SCALL	.PRINT
	JMP	ERROR

** ERROR - GENERAL ERROR MESSAGE
*

ERROR   MVI     H,NL
        SCALL   .ERROR
        MVI     A,1
        SCALL   .EXIT

** DIFF
* 
*  Input
*    SUNITI
*    DUNITI
*    HL = OFFSET
*    D = PAGE
*  Output
*    A = 0 if same, 1 if different

DIFF	PUSH	B
	PUSH	D
	PUSH	H
	MOV	A,D
	STA	DIFFPG
	DI
	LDA	SUNITI
	ORI	080H
	OUT	RD00KH		PAGE0 BANK = SRCUNI
	LDA	DUNITI
	ORI	080H
	OUT	RD16KH		PAGE1 BANK = DSTUNI
	LDA	DIFFPG
	ORI	080H
	OUT	RD00K		PAGE0 PAGE = DIFFPG
	OUT	RD16K		PAGE1 PAGE = DIFFPG
	LXI	B,01000H
	MOV	A,H
	ADI	040H
	MOV	D,A
	MOV	E,L		DE = HL + 004000
DIFFLP	LDAX	D
	CMP	M
	JNZ	DIFF1
	INX	D
	INX	H
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	DIFFLP		KEEP LOOPING
	MVI	B,0
	JMP	DIFFOUT
DIFF1	MVI	B,1
DIFFOUT	MVI	A,080H		RESTORE PAGE REGS
	OUT	RD00KH
	OUT	RD16KH
	OUT	RD00K
	MVI	A,081H
	OUT	RD16K
	MVI	A,001H
	OUT	RD16K		DISABLE PAGING
	EI
	MOV	A,B
	POP	H
	POP	D
	POP	B
	RET
DIFFPG	DB	0

** ISRAM - check to see if dest unit is RAM
*

ISRAM 	DI
	LDA	DUNITI
	ORI	080H
	OUT	WR00KH
	OUT	RD00KH
	MVI	A,085H		PAGE 5
	OUT	WR00K
	OUT	RD00K
	LXI	H,0
	MOV	C,M
	INR	M
	MOV	A,M
	DCR	M
	MVI	B,0
	CMP	C
	JZ	ISRAM0
	MVI	B,1
ISRAM0	MVI	A,080H
	OUT	WR00KH
	OUT	RD00KH
	OUT	WR00K
	OUT	RD00K
	MVI	A,000H
	OUT	RD00K
	MOV	A,B
	RET
	
DBLK	PUSH	H
	LXI	H,MBLK
	SCALL	.PRINT
	POP	H
	CALL	PHEXHL
	RET

DMAP	PUSH	PSW
	PUSH	H
	LXI	H,MOFS
	SCALL	.PRINT
	POP	H
	CALL	PHEXHL
	PUSH	H
	LXI	H,MPAGE
	SCALL	.PRINT
	MOV	A,D
	CALL	PHEXA
	POP	H
	POP	PSW
	RET

DDIFF	PUSH	PSW
	PUSH	H
	LXI	H,MSAME
	ORA	A
	JZ	DDIFF1
	LXI	H,MDIFF
DDIFF1	SCALL	.PRINT
	POP	H
	POP	PSW
	RET

DERASE	PUSH	H
	LXI	H,MERASE
	SCALL	.PRINT
	POP	H
	RET

DBURN	PUSH	H
	LXI	H,MBURN
	SCALL	.PRINT
	POP	H
	RET

DCOPY	LXI	H,MCOPY
	SCALL	.PRINT
	LDA	SUNITI
	CALL	PHEXA
	LXI	H,MTO
	SCALL	.PRINT
	LDA	DUNITI
	CALL	PHEXA
	MVI	A,12Q
	SCALL	.SCOUT
	RET

DCPAGE	PUSH	PSW
	PUSH	H
	LXI	H,MDCPG
	SCALL	.PRINT
	MOV	A,B
	CALL	PHEXA
	MVI	A,12Q
	SCALL	.SCOUT
	POP	H
	POP	PWR
	RET

	XTEXT	PGMAP
	XTEXT	FLASH
	XTEXT	PRHEX
* Stuff below is for cmdline parsing
	XTEXT	ITL
	XTEXT   CCO
	XTEXT	PDN2
	XTEXT	DDS
	XTEXT	TYPTX
	XTEXT   MCU
	XTEXT	MLU
	XTEXT	RCHAR
	XTEXT	RTL
	XTEXT	SOB
        XTEXT   SAVALL
	XTEXT   HLCPDE

INTRO	DB	12Q,'RAMDISK COPY TOOL',212Q
MDONE	DB	12Q,'DONE',212Q

MBLK	DB	'BLK','='+200Q
MOFS	DB	' OFS','='+200Q
MPAGE	DB	' PAGE','='+200Q
MSAME	DB	' SAM','E'+200Q
MDIFF	DB	' DIF','F'+200Q
MERASE  DB	' ERAS','E'+200Q
MBURN   DB	' BUR','N'+200Q
MISRAM	DB	'DEST UNIT IS RAM',212Q
MISFLS	DB	'DEST UNIT IS FLASH',212Q
MCOPY	DB	'COPY FROM',' '+200Q
MTO	DB	' TO',' '+200Q
MDCPG	DB	'COPY PAGE',' '+200Q
MUNSUP	DB	'RD0 IS UNSUPPORTED (SMALLER THAN THE OTHER RAMDISKS)',212Q

CNT4K	DW	512	# 2MB DISK
START	DW	0	# START AT 4K BLK 0

ITLA    DS      80              Line Buffer

**	"what" identification
	DB	'@(#)HDOS Ramdisk Copy Tool by Scott Baker.',NL
	DW	0		Date
	DW	0		Time

	LON	G
	END	ENTRY
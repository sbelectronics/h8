
	TITLE	'RD3TEST'
	EJECT
***	RD3TEST*
*       SMBAKER


	XTEXT	HOSDEF
	XTEXT	HOSEQU
	XTEXT   PGREG

	ORG	08000H		

ENTRY	LXI	HJ,INTRO
	SCALL	.PRINT
	CALL	PGINIT

	LXI	H,0
DOTEST	CALL	DBLK
	CALL	PREPBUF		Fill Buf with pattern
	CALL	TESTBUF		Check buffer Okay
	LXI	D,BUF
	LXI	B,01000H
	PUSH	H	
	CALL	SMALLWR		Write buffer to disk
	POP	H
	CALL	TESTBUF		Check buffer Okay
	CALL	CLRBUF
	LXI	D,BUF
	LXI	B,01000H	
	PUSH	H
	CALL	SMALLRD		Read buffer from disk
	POP	H
	CALL	TESTBUF		Check buffer okay

	LDA	SEED
	INR	A		Increment seed...
	STA	SEED		... for next pass

	MOV	A,L             Increment HL by 0x0010
	ADI	010H
	MOV	L,A
	MOV	A,H
	ACI	000H		We might have carried...
	MOV	H,A

	MOV	A,H
	CPI	010H		4096 blocks of 4096 bytes ought to be enough
	JNZ	DOTEST

	XRA	A
	SCALL	.EXIT

PREPBUF	PUSH	PSW
	PUSH	B
	PUSH	D
	PUSH	H

	LDA	SEED
	MOV	H,A		H holds the pattern

	LXI	D,BUF
	LXI	B,01000H
PBLOOP	MOV	A,H
	STAX	D
	INR	H		Increment pattern
	INX	D		Increment dest
	DCX	B		Decrement count
	MOV	A,B
	ORA	C
	JNZ	PBLOOP

	POP	H
	POP	D
	POP	B
	POP	PSW
	RET

CLRBUF	PUSH	PSW
	PUSH	B
	PUSH	D
	PUSH	H

	LXI	D,BUF
	LXI	B,01000H
CLOOP	MVI	A,0
	STAX	D
	INR	H		Increment pattern
	INX	D		Increment dest
	DCX	B		Decrement count
	MOV	A,B
	ORA	C
	JNZ	CLOOP

	POP	H
	POP	D
	POP	B
	POP	PSW
	RET

TESTBUF	PUSH	PSW
	PUSH	B
	PUSH	D
	PUSH	H

	LDA	SEED
	MOV	H,A		H holds the pattern
	LXI	D,BUF
	LXI	B,01000H
TLOOP	LDAX	D
	CMP	H
	JZ	TOK

	LXI	H,MERROR
	SCALL	.PRINT
	CALL	PHEXDE
	LXI	H,MBUF
	SCALL	.PRINT
	LXI	D,BUF
	CALL	PHEXDE
	LXI	H,MHALT
	SCALL	.PRINT
	XRA	A
	SCALL	.EXIT

TOK	INR	H		Increment pattern
	INX	D		Increment dest
	DCX	B		Decrement count
	MOV	A,B
	ORA	C
	JNZ	TLOOP

	POP	H
	POP	D
	POP	B
	POP	PSW
	RET


CALCPG	EQU 	*
	PUSH	B		Pushes both B and C
	LDA	AIOUNI
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

**	SMALLRD
*
*	PERFORM A READ OF 16640 BYTES OR LESS. 
*
*	BC = BYTE COUNT
*	DE = SRC ADDRESS
*	HL = BLOCK NUMBER

SMALLRD	EQU	*
	MOV	A,B
	ORA	C
	RZ			Asking to read 0 bytes so just return

	LDA	AIOUNI		Store a copy of AIO.UNI since we cannot access it inside critical section
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
*	DE = DEST ADDRESS
*	HL = BLOCK NUMBER

SMALLWR	EQU	*
	MOV	A,B
	ORA	C
	RZ			Asking to write 0 bytes so just return

	LDA	AIOUNI		Store a copy of AIO.UNI since we cannot access it inside critical section
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

DPAGE	RET

DBLK	PUSH	PSW
	PUSH	H
	LXI	H,MBLK
	SCALL	.PRINT
	POP	H
	CALL	PHEXHL
	MVI	A,12Q
	SCALL	.SCOUT
	POP	PSW
	RET

	XTEXT	PGMAP
	XTEXT   PRHEX

INTRO	DB	12Q,'RD3TEST',212Q
MERROR	DB	12Q,'DANGER, WILL ROBINSON! DANGER! ERROR ADDR','='+200Q
MBUF	DB	' BUF','='+200Q
MHALT	DB	12Q,'HALTING TEST',212Q
MBLK	DB	' BLOCK','='+200Q
AIOUNI	DB	3
RDUNIT	DB	0
SEED	DB	033H		Gotta start somewhere
BUF	DS	4096

	LON	G
	END	ENTRY

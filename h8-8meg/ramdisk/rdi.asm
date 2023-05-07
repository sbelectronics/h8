        TITLE   'RDI - RamDisk Initialization Parameters'
        LON     IC

RESIDE  EQU     0               RESIDENT HDOS ASSEMBLER
        STL     'Definitions'
        SPACE   3
        XTEXT   MTR
        XTEXT   BOODEF
        XTEXT   ECDEF
        XTEXT   DDDEF
        XTEXT   PICDEF
        XTEXT   LABDEF
        XTEXT   DIRDEF
        XTEXT   HOSEQU
        XTEXT   HOSDEF
        XTEXT   HDSROM
        XTEXT   EDCON
	XTEXT	EDVEC
        XTEXT   ESVAL
        XTEXT   ESINT
        XTEXT   H17ROM
        XTEXT   ASCII
        XTEXT   INIDEF
        XTEXT   DADA
        XTEXT   MOVE
        SPACE   3
$UDD    EQU     31157A          ;UNPACK DECIMAL DIGITS
        SPACE   3
$ZERO   EQU     31212A          ;ZERO AREA SUBROUTINE
$TJMP   EQU     031061A                 ; IN H17 ROM, (A) = INDEX*2

        STL     'Drive Parameters'
        EJECT
***     Drive Parameters
*

        IF      RESIDE
        CODE    P,SB.BOO
        ELSE
        CODE    P,SB.BOO-PIC.COD
        ENDIF

        CODE    +REL
 
.       EQU     *-SB.BOO
        ERRNZ   .

        JMP     PBOOT           Execute Primary Boot

        ERRMI   .+SB.BPE-*
        DS      .+SB.BPE-*

PBOOT   EQU     *
        LXI	D,BOOTA 		; Disk constant and vector table
	LXI	H,D.CON 		; RAM destination
	LXI	B,BOOTAL		; Length of the mess
	CALL	$MOVE			; Plug it in

        CALL    PGINIT

        LXI	H,RDROD		; Read-only driver
	SHLD	D.SYDD+1		; Install it
	LXI	H,RDMNT		; Special mount routine
	SHLD	D.MOUNT+1		; Set it
        JMP     SB.SDB          GO TO INIT COMMON BOOT CODE

* All the following XTEXT will end up built into the boot loader

        XTEXT   PGREG
        XTEXT   RDROD
        XTEXT   PGMAP
        XTEXT   PRHEX

        ERRMI   .+SB.SDB-*
        DS      .+SB.SDB-*

        STL     'RDI - Ramdisk Initialization Parameters'
        EJECT
***     INIT
*
*       INIT processes the sub-functions required by  *INIT*
*

INIT    EQU     *
*        CALL    DINIT
        CPI     INI.MAX
        CMC
        RC              Illegal sub-function code

        CALL    $$TBRA
        DB      CMV-*           Check Media Validity
        DB      INITDSK-*       Initialize Diskette Surface
        DB      DBI-*           Directory Block Interleave
        DB      PAR-*           Volume Parameters

        STL     'DBI    - Directory Block Interleave'
        EJECT
**      DBI     - Directory Block Interleave
*
*       DBI returns a pointer to the directory block
*       interleave table.  The table is in the form
*       of offsets.
*
*       This is not important to RamDisk and we will just emit
*       a sequential directory interleave.
*

DBI     EQU     *
*        CALL    DDBI
        LXI     H,DBIA
        ANA     A
        RET

DBIA    DB      0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16

        STL     'PAR    - Volume Parameters'
        EJECT
**      PAR     - Volume Parameters
*
*       PAR returns a pointer to the volume parameters as defined
*       in  *LABDEF*.
*
*       ENTRY:  NONE
*
*       EXIT:   HL      = Address of Volume Parameters
*
*       USES:   PSW,HL
*

PAR     EQU     *
*        CALL    DPAR
        CALL    $$DRVR          call driver READY, this will return RD INFO block in DE
        DB      DC.RDY
        RC                      return if error

**                              Next we go through some effort to check driver parameters, to
*                               see if our Unit 0 should be tiny (one 512K chip only, for the
*                               SEBHC board) or should be in regular mode (all four chips, for
*                               scott's board). Unit 0 is special because chip0 is shared with
*                               the 64K of main RAM.

        LDAX    D               Look for FEED at (DE)
        CPI     0FEH
        JNZ     ENOTRD
        INX     D
        LDAX    D               Skip FE
        CPI     0EDH
        JNZ     ENOTRD
        INX     D               Skip ED

        LXI     H,PARAM         Start by assuming the unit 1-7 params
        LDA     AIO.UNI
        ORA     A
        JNZ     PAROUT          If not unit 0, return with params

        LXI     H,PARAM0T       Assume params for unit0-tiny
        INX     D               Skip DEBUG bit              
        LDAX    D               Read TINY bit
        ORA     A
        JNZ     PAROUT          Tiny mode, return with params
        LXI     H,PARAM0        Load params for unit0-regular

PAROUT  ANA     A
        RET

ENOTRD: CALL    PHEXA
        CALL    PHEXDE
        LXI     H,MNOTRD        Error return, we failed to find the RD Info block
        SCALL   .PRINT
        STC
        RET

        STL     'CMV    - Check Media Validity'
        EJECT
**      CMV     - Check Media Validity
*
*       CMV checks the validity of the media in the specified unit
*
*       ENTRY:  NONE
*
*       EXIT:   PSW     = 'C' clear if no errors
*                         'C' set   if    errors
*
*       USES:   ALL
*

CMV     EQU     *
*        CALL    DCMV
        CALL    $$DRVR
        DB      DC.RDY
        RC                      ERROR, RETURN
	ANA     A               SUCCESS, RETURN CLEAR CARRY
	RET

        STL     'INITDSK   - Initialize Disk'
        EJECT
**      INITDSK
*
*       INITIALIZE THE DISK SURFACE

INITDSK EQU     *
*        CALL    DINITDK
        ANA     A               MOVE ALONG, NOTHING TO SEE HERE...
        RET

MNOTRD  DB      12Q,'RD: Failed to find RD driver info block',212Q

** parameters for units 1-7

PARAM   EQU     *

        ERRNZ   *-PARAM+LAB.VPR-LAB.SIZ
VOLSIZ  DW      8190            Volume Size (bytes/256)

        ERRNZ   *-PARAM+LAB.VPR-LAB.PSS
SECSIZ  DW      256             Physical Sector Size (bytes)

        ERRNZ   *-PARAM+LAB.VPR-LAB.VFL
VOLFLG  DB      0               Device Dependant/Volume Dependant Flags

        ERRNZ   *-PARAM-LAB.VPL Insure enough parameters are defined

PARAM2  EQU     *               Auxiliary Parameters

        ERRNZ   *-PARAM2-LAB.SPT+LAB.AUX
SPT     DB      10              Sectors per Track

        ERRNZ   *-PARAM2-LAB.AXL        Insure enough Auxiliary Parameters

** parameters for unit 0, regular mode (2MB OF RAM)

PARAM0  EQU     *

        ERRNZ   *-PARAM0+LAB.VPR-LAB.SIZ
        DW      7936            Volume Size (bytes/256)

        ERRNZ   *-PARAM0+LAB.VPR-LAB.PSS
        DW      256             Physical Sector Size (bytes)

        ERRNZ   *-PARAM0+LAB.VPR-LAB.VFL
        DB      0               Device Dependant/Volume Dependant Flags

        ERRNZ   *-PARAM0-LAB.VPL Insure enough parameters are defined

PAR20   EQU     *               Auxiliary Parameters

        ERRNZ   *-PAR20-LAB.SPT+LAB.AUX
        DB      10              Sectors per Track

        ERRNZ   *-PAR20-LAB.AXL        Insure enough Auxiliary Parameters

** parameters for unit 0, tiny mode (512K OF RAM)

PARAM0T EQU     *

        ERRNZ   *-PARAM0T+LAB.VPR-LAB.SIZ
        DW      1790            Volume Size (bytes/256)

        ERRNZ   *-PARAM0T+LAB.VPR-LAB.PSS
        DW      256             Physical Sector Size (bytes)

        ERRNZ   *-PARAM0T+LAB.VPR-LAB.VFL
        DB      0               Device Dependant/Volume Dependant Flags

        ERRNZ   *-PARAM0T-LAB.VPL Insure enough parameters are defined

PAR20T  EQU     *               Auxiliary Parameters

        ERRNZ   *-PAR20T-LAB.SPT+LAB.AUX
        DB      10              Sectors per Track

        ERRNZ   *-PAR20T-LAB.AXL        Insure enough Auxiliary Parameters

        DS      80                       Consume some space, to bring us up to > 768 length

*        XTEXT   DEBUGI                 Debug messages

        ERRMI   *-42200A+46-769          Things go bad if less than 4 256-byte blocks in size

        END

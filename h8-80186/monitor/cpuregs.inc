
; 80188 peripheral control register block address
CPU_CSCR                equ     0FF00h

PIC             equ     CPU_CSCR+020H
PIC_EOI         equ     PIC+2           ; End Of Interrupt
PIC_POLLR       equ     PIC+4
PIC_POLLSR      equ     PIC+6
PIC_IMASK       equ     PIC+8
PIC_PMREG       equ     PIC+0AH
PIC_SRVR        equ     PIC+0CH
PIC_IRQR        equ     PIC+0EH
PIC_IRQSR       equ     PIC+10H
PIC_TCR         equ     PIC+12H
PIC_DMA0CR      equ     PIC+14H
PIC_DMA1CR      equ     PIC+16H
PIC_I0CON       equ     PIC+18H
PIC_I1CON       equ     PIC+1AH
PIC_I2CON       equ     PIC+1CH
PIC_I3CON       equ     PIC+1EH

EOI_NSPEC       equ     8000h           ; Non-Specific EOI

;------------------------------------------------------------------------        
; include serial library
;
; define one of the following to control the build
;    * frontpanel - build with frontpanel and 16450
;    * ser16450 - build with 16450 but not frontpanel
;    * bitbang - build with bitbang without frontpanel
;    * ser8251 - build with 8251 from the tape board without front panel
;
; additional defines
;    * nocinpne - omit the CINPNE function
;    * nocinp - omit the CINP function
;    * nocinp80 - omit setting the high bit on CINP/CINPNE
;    * nofrontpanel - removes the frontpanel from frontpanel_isr
;------------------------------------------------------------------------

            include "h8.inc"

;; avoid a proliferation of ifdefs, and just define this stub to stand in
;; for the frontpanel functions.

EMPTYFUNC:  ret

;; front panel with 16450

            ifdef frontpanel
            include "fpanelvar.inc"
            include "fpanpoll-16450.inc"
            include "fpanel.inc"
            include "16450.inc"
SINIT:      equ SINIT450
            ifndef nocinp
CINP:       equ CINP450
            endif
            ifndef nocinpne
CINPNE:     equ FCINP450
            endif
CPRINT:     equ CPRINT450
CRDY:       equ CRDY450
            endif

;; front panel with interrupts

            ifdef frontpanel_isr
            include "fpanelvar.inc"
            include "fpanisr.inc"
            ifndef nofrontpanel
            include "fpanel.inc"
            endif
            include "16450.inc"
SINIT:      equ SINIT450
            ifndef nocinp
CINP:       equ CINP450
            endif
            ifndef nocinpne
CINPNE:     equ CINP450NE
            endif
CPRINT:     equ CPRINT450
CRDY:       equ CRDY450
            endif

;; just the 16450

            ifdef ser16450
            include "16450.inc"
SINIT:      equ SINIT450
            ifndef nocinp
CINP:       equ CINP450
            endif
            ifndef nocinpne
CINPNE:     equ CINP450NE
            endif
CPRINT:     equ CPRINT450
CRDY:       equ CRDY450
FPANINIT:   equ EMPTYFUNC
FPDISABLE:  equ EMPTYFUNC
FPENABLE:   equ EMPTYFUNC
            endif

;; just the bit-bang serial

            ifdef bitbang
            include "bbser.inc"
SINIT:      equ SINITBB
            ifndef nocinp
CINP:       equ CINPBB
            endif
            ifndef nocinpne
CINPNE:     equ CINPNEBB
            endif
CPRINT:     equ CPRINTBB
CRDY:       equ CRDYBB
FPANINIT:   equ EMPTYFUNC
FPDISABLE:  equ EMPTYFUNC
FPENABLE:   equ EMPTYFUNC
            endif

;; just the 8251 console

            ifdef ser8251
            include "8251-cons.inc"
SINIT:      equ SINIT8251
            ifndef nocinp
CINP:       equ CINP8251
            endif
            ifndef nocinpne
CINPNE:     equ CINP8251NE
            endif
CPRINT:     equ CPRINT8251
CRDY:       equ CRDY8251
FPANINIT:   equ EMPTYFUNC
FPDISABLE:  equ EMPTYFUNC
FPENABLE:   equ EMPTYFUNC
            endif

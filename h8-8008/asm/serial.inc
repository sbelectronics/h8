;------------------------------------------------------------------------        
; include serial library
;
; define one of the following to control the build
;    * frontpanel - build with frontpanel and 16450
;    * ser16450 - build with 16450 but not frontpanel
;    * bitbang - build with bitbang without frontpanel
;------------------------------------------------------------------------

;; avoid a proliferation of ifdefs, and just define this stub to stand in
;; for the frontpanel functions.

EMPTYFUNC:  ret

;; front panel with 16450

            ifdef frontpanel
            include "fpanelvar.inc"
            include "fpanel.inc"
            include "16450.inc"
SINIT:      equ SINIT450
CINP:       equ CINP450
CINPNE:     equ FCINP450
CPRINT:     equ CPRINT450
CRDY:       equ CRDY450
            endif

;; just the 16450

            ifdef ser16450
            include "16450.inc"
SINIT:      equ SINIT450
CINP:       equ CINP450
CINPNE:     equ CINP450NE
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
CINP:       equ CINPBB
CINPNE:     equ CINPNEBB
CPRINT:     equ CPRINTBB
CRDY:       equ CRDYBB
FPANINIT:   equ EMPTYFUNC
FPDISABLE:  equ EMPTYFUNC
FPENABLE:   equ EMPTYFUNC
            endif

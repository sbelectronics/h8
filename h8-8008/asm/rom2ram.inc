;; copy from ROM at 0x2100 to RAM at 0x0000.
;; This assumes the first 256 bytes were reserved for the bank switcher and
;; for this routine. That's why we start copying at 0x2100 instead of
;; 0x2000. We stop at 0x4000. We copy 8KB less 256 bytes.

rom_start:  
            mvi l,00H
            mvi b,21H                ; src MSB at 8k + 256
            mvi c,00H                ; dest MSB at 0
r2rmore:
            mov h,b                  ; from src
            mov a,m                  ; read it
            mov h,c                  ; to dest
            mov m,a                  ; write it
            inr l                    ; increment LSB
            jnz r2rmore              ; we didn't wrap L, so keep copying
            inr b                    ; wrapped, so increment MSB src
            inr c                    ; ... and MSB dest
            mov a,c
            cpi 40H                  ; are we there yet?
            jnz r2rmore              ; nope
            jmp jumpprog             ; we're done. Jump to the jump to the program start.

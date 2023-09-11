;-----------------------------------------------------------------------------------
; ROM2RAM Loader
; Scott Baker, https://www.smbaker.com/
;
; This demonstrates how any RAM program can be loaded from ROM. It does so by
; copying the contents of ROM (skipping the first 256 bytes that contain this
; loader) and then jumping to the start function.
;
; Note that the program's start function must be specified in the `jumpprog`
; label at the end of this file, since each program might potentially start
; at a different address.
;
; When building the ROM image, first copy this loader, which is exactly 256
; bytes long, then copy the program. The program may be up to 7936 bytes long.
;-----------------------------------------------------------------------------------

            include "bitfuncs.inc" 

            cpu 8008new              ; use "new" 8008 mnemonics

            ;; In reality nobody will call rst1. The monitor will directly call
            ;; go_rom2 (or whichever bank this code is residing in).

            org 2000H                ; start of EPROM
            rst 1

            org 2008H                ; rst 1 jumps here
            jmp go_rom2              ; by default, at ROM bank 2

            include "go-rom.inc"
            include "rom2ram.inc"

            org 020FDH               ; pad out so the jump ends at 256 bytes

jumpprog:   jmp 0040H                ; Jump to program start at 040H

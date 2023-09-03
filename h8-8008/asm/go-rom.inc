;-----------------------------------------------------------------------
; go-rom.inc - functions to perform bank switch and jump to start of ROM
;-----------------------------------------------------------------------

MMAP0       equ 0CH
MMAP1       equ 0DH
MMAP2       equ 0EH
MMAP3       equ 0FH

            org 2040H
go_rom0:    mvi a, 08H
            out MMAP0
            mvi a, 09H
            out MMAP1
            mvi a, 00H
            out MMAP2
            mvi a, 01H
            out MMAP3
            in 1
            jmp rom_start
go_rom1:    mvi a, 08H
            out MMAP0
            mvi a, 09H
            out MMAP1
            mvi a, 02H
            out MMAP2
            mvi a, 03H
            out MMAP3
            in 1
            jmp rom_start
go_rom2:    mvi a, 08H
            out MMAP0
            mvi a, 09H
            out MMAP1
            mvi a, 04H
            out MMAP2
            mvi a, 05H
            out MMAP3
            in 1
            jmp rom_start
go_rom3:    mvi a, 08H
            out MMAP0
            mvi a, 09H
            out MMAP1
            mvi a, 06H
            out MMAP2
            mvi a, 07H
            out MMAP3
            in 1
            jmp rom_start

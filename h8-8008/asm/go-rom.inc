;-----------------------------------------------------------------------
; go-rom.inc - functions to perform bank switch and jump to start of ROM
;-----------------------------------------------------------------------

MMAP0       equ 0CH
MMAP1       equ 0DH
MMAP2       equ 0EH
MMAP3       equ 0FH

            org 2040H
go_rom0:    mvi a,00H
            jmp go_rom
go_rom1:    mvi a,01H
            jmp go_rom
go_rom2:    mvi a,02H
            jmp go_rom
go_rom3:    mvi a,03H
            jmp go_rom

            ;; go_rom
            ;; input
            ;;    A = rom number. Assumes each ROM consumes 2 pages (8KB total)
            ;; destroys
            ;;    B
go_rom:     mov b,a
            ral                 ; A = A * 2
            ani 0FEH
            out MMAP2           ; page2 = (rom*2)
            adi 1H              
            out MMAP3           ; page3 = (rom*2)+1
            mvi a, 80H
            out MMAP0
            mvi a, 81H
            out MMAP1
            mov a,b
            in 1                ; enable mapper
            jmp rom_start


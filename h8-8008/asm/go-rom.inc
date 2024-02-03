;-----------------------------------------------------------------------
; go-rom.inc - functions to perform bank switch and jump to start of ROM
;-----------------------------------------------------------------------

MMAP0       equ 0CH
MMAP1       equ 0DH
MMAP2       equ 0EH
MMAP3       equ 0FH

PAGE0       equ 000H
PAGE1       equ 010H
PAGE2       equ 020H
PAGE3       equ 030H

            ifdef master

RAM0        equ 0CH             ; 0x08 enables RAM, 0x04 disables EXT
RAM1        equ 0DH
RAM2        equ 0EH
RAM3        equ 0FH
ROMOR       equ 04H             ; bit 04H, if low will access ext RAM

EXTRAM0     equ 08H
EXTRAM1     equ 09H
EXTRAM2     equ 0AH
EXTRAM3     equ 0BH

ROM0        equ ROMOR | 00H
ROM1        equ ROMOR | 01H

            else

RAM0        equ 80H             ; 0x80 enables RAM
RAM1        equ 81H
RAM2        equ 82H
RAM3        equ 83H
ROMOR       equ 00H

            endif

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
            ori ROMOR
            out MMAP2           ; page2 = (rom*2)
            adi 1H              
            out MMAP3           ; page3 = (rom*2)+1
            mvi a, RAM0
            out MMAP0
            mvi a, RAM1
            out MMAP1
            mov a,b
            in 1                ; enable mapper
            jmp rom_start


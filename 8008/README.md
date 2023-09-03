# H8 8008 CPU Board
### Scott Baker, https://www.smbaker.com/

This project is an 8008 CPU board for the Heathkit H8 computer. It is not software-compatible with the H8 CPO Board. You cannot run HDOS. You cannot run CP/M. The instruction sets for the 8008 and 8080 are entirely different. What you can run is a custom monitor, which includes H8 front panel support, and Scelbi BASIC.

## Credits

This project was heavily influenced by the following:

* [8008-SBC By Jim Loos](https://github.com/jim11662418/8008-SBC)

* [8008 Clock by Len Bayles](https://www.8008chron.com/)

## Manual ROM bank selection

If Software-Controlled bank switching is not used, then 8K banks in ROM may be chosen by using S3. Switch S3 has four switches, which are a simple binary input to address bits A13 .. A16 on the ROM.

To use manual ROM bank selection, be sure that jumpers JP15, JP16, and JP17 are set to positions 1-2. Also, Solder jumpers SJ1 and SJ2 (on the back side of the board near switch S3) should be populated.

The pre-build ROMs will put the monitor in the first bank, and Scelbi basic in the second bank.

## Software-Controlled Bank Switching

Switches 3 and 4 of S3 should not be used when using software bank switching.

Software controlled bank switching support is optional, provided by setting jumpers JP15, JP16, and JP17 to positions 2-3 instead of positions 1-2. Also, it's recommended to not populate SJ1 and SJ2 (the two solder jumpers on the back side of the board near switch S3) lest you accidentally end up competing with the bank switcher and potentially damaging IC24.

Bank switching is done by writing the desired values to ports 0C, 0D, 0E, and 0F. These four ports map memory in 4K segments. Port 0C covers the first 4K of address space, port 0D covers the second 4K, etc.

```
  0000  00   ROM 0000-0FFF   First 8K
  0001  01   ROM 1000-1FFF
  0010  02   ROM 2000-2FFF   Second 8K
  0011  03   ROM 3000-3FFF
  0100  04   ROM 4000-4FFF   Third 8K
  0101  05   ROM 5000-5FFF
  0110  06   ROM 6000-6FFF   Fourth 8K
  0111  07   ROM 7000-7FFF  
  1000  08   RAM 0000-0FFF   First 8K
  1001  09   RAM 1000-1FFF
  1010  0A   RAM 2000-2FFF   Second 8K
  1011  0B   RAM 3000-3FFF
  1100  0C   RAM 4000-4FFF   Third 8K
  1101  0D   RAM 5000-5FFF
  1110  0E   RAM 6000-6FFF   Fourth 8K
  1111  0F   RAM 7000-7FFF

  8K RAM + First 8K ROM: 08, 09, 00, 01
 
  8K RAM + Second 8K ROM: 08, 09, 02, 03

  8K RAM + Third 8K ROM: 08, 09, 04, 05

  8K RAM + Fourth 8K ROM: 08, 09, 06, 07
```

## H8 Front Panel Support

The H8 front panel is implemented as part of the monitor while the CINP (get character from serial port) subroutine is running. It does not use interrupts. It uses simple polling to wait for the signal from the H8 front panel that a display refresh is due. Because of this, the front panel pretty much only works when running the monitor, and only works while the monitor is waiting for keypresses. If the monitor is printing something to serial, the screen will blank.

## Serial Port support

The following ROM images are created:

* h8-16450.rom. Uses a 16450/16550 type serial board, for example an H8-4 or equivalent.

* h8-bb.rom. Bitbangs IO to a 9-pin header on the CPU board. Use this if you don't have a serial board.

## Programming PLDs

Several gal22v10d programmable logic devices are used. The associated PLD files are there and can be recompiled win WINCUPL. The compiled JED files should also be there and may be burned directly
using a TL866II+ or similar programmer.

* pld/bus. required. goes in the BUS socket.

* pld/io. required. goes in the IO socket.

* pld/intpoll. required. goes in the INTREG socket.

* pld/intreg. not used.

* pld/intcon. not used.

Make sure to place the INTPOLL PLD into the INTREG socket on the board. Do not use the INTREG PLD. Leave the INTCON socket empty.

# H8 8008 CPU Board
### Scott Baker, https://www.smbaker.com/

This project is an 8008 CPU board for the Heathkit H8 computer. It is not software-compatible with the H8 CPO Board. You cannot run HDOS. You cannot run CP/M. The instruction sets for the 8008 and 8080 are entirely different. What you can run is a custom monitor, which includes H8 front panel support, and Scelbi BASIC.

## Credits

This project was heavily influenced by the following:

* [8008-SBC By Jim Loos](https://github.com/jim11662418/8008-SBC)

* [8008 Clock by Len Bayles](https://www.8008chron.com/)

## Jumper Settings

| Jumper | Position | Default | Description |
| ------ | -------- | --------| ----------- |
|   SJ6  |          | Present | A11 connected to outmmap demux (required!) |
|   SJ7  |          | Present | IOW to H8 bus (required) |
|   SJ8  |          | Present | IOR to H8 bus (required) |
|   SJ10 |    1-2   |     X   | Two page registers (74HCT670) installed. Goes with current ROM image |
|        |    2-3   |         | Only one page register installed. Goes with old ROM image. |
|   JP1  |          |         | Enables power to 7909 regulator. Do not use if using DC/DC converter! |
|   JP2  |    1-2   |         | 4040 is reset during reset |
|        |    2-3   |     X   | 4040 is never reset
|   JP3  |    1-2   |         | 8008 clock is QG1 divided by 2 |
|        |    2-3   |     X   | 8008 clock uses QG3 |
|   JP4  |          | Present | Enables power to DC/DC converter. Do not use if using 7909 regulator! |
|   JP5  |    1-2   |     X   | MEMRD controlled by INTCON PLD |
|        |    2-3   |         | MEMRD directly controlled via bus PLD |
|   JP10 |    1-2   |     X   | RC2014-A8 is A12 |
|        |    2-3   |         | RC2014-A8 is GND |
|   JP11 |    1-2   |     X   | Power-on CPUINT controlled by INTCON PLD |
|        |    2-3   |         | INTCON PLD bypassed, CPUINT directly controlled by POR |
|   JP12 |    1-2   |         | Clock to H8 bus is not inverted |
|        |    2-3   |     X   | Clock to H8 bus is inverted |
|   JP17 |    1-2   |         | Memory mapper is always disabled |
|        |    2-3   |     X   | Memory mapper is controller by !START |
|   JP29 |          |         | Enables write signal to 512 KBIT and larger devices |

## Software-Controlled Bank Switching

Bank switching is done by writing the desired values to ports 0C, 0D, 0E, and 0F. These four ports map memory in 4K segments. Port 0C covers the first 4K of address space, port 0D covers the second 4K, etc.

When configured with two memory-mapping 74HCT670, the MSB controls whether
ROM or RAM is used. This configuration is with SJ10 set to 1-2.

The previous iteration of the board had only one memory-mapping 74HCT670, bit D3 controlled
whether ROM or RAM is used. This configuration was used with SJ10 set to 2-3. It requires
an older ROM image. It is not recommended.

```
  00000000  00   ROM 0000-0FFF   First 8K
  00000001  01   ROM 1000-1FFF
  00000010  02   ROM 2000-2FFF   Second 8K
  00000011  03   ROM 3000-3FFF
  00000100  04   ROM 4000-4FFF   Third 8K
  00000101  05   ROM 5000-5FFF
  00000110  06   ROM 6000-6FFF   Fourth 8K
  00000111  07   ROM 7000-7FFF  
  10000000  08   RAM 0000-0FFF   First 8K
  10000001  09   RAM 1000-1FFF
  10000010  0A   RAM 2000-2FFF   Second 8K
  10000011  0B   RAM 3000-3FFF
  10000100  0C   RAM 4000-4FFF   Third 8K
  10000101  0D   RAM 5000-5FFF
  10000110  0E   RAM 6000-6FFF   Fourth 8K
  10000111  0F   RAM 7000-7FFF

  8K RAM + First 8K ROM: 80, 81, 00, 01
 
  8K RAM + Second 8K ROM: 80, 81, 02, 03

  8K RAM + Third 8K ROM: 80, 82, 04, 05

  8K RAM + Fourth 8K ROM: 80, 81, 06, 07
```

## IO Mapping

The 8008 only supports 8 input ports and 24 output ports, whereas the H8 supports 256 ports, each of which can be input, output, or bidirectional. I used a port mapping scheme via 4x4 register files to accommodate this.

Port mapping is achieved by writing output ports 24-31. This is the third group of output ports. These registers configure the input ports as well as the second group of ports. This is best illustrated by example.

```
            mvi a,0E8H
            out 1AH           ; configure input port 02 and output port 12
            mvi a,0EDH
            out 1BH           ; configure input port 03 and output port 13
```

After executing the above code,

* reading from port 02H will read from port 0E8H on the H8 bus

* reading from port 03H will read from port 0EDH on the H8 bus

* writing to port 12H will write to port 0E8H on the H8 bus

* writing to port 13H will write to port 0EdH on the H8 bus

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

* pld/intreg. required if using front panel or interrupts.

* pld/intcon. required if using front panel or interrupts.

Using INTCON empty was supported in older versions of the board, but is not supported in current versions, as INTCON generates the polling signal for INTREG.

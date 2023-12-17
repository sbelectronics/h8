| Port         | Meaning |
| ------------ | ------- |
| 0600-0640    | Floppy |
| 0660-0663    | Reserved for Parallel |
| 0670-0673    | LEDs |
| 0674         | Timer2 control |
| 0675         | FPIE |
| 0676         | FDC Reset (active high) |
| 0677         | IDE Reset (active low) |
| 0680-0687    | Uart |
| 06C0-06CF    | IDE CS0 |
| 06D0-06DF    | IDE CS1 |
| 06FF         | Debug Port |
| FF20 - FF3F  | PIC |
| FF50         | Timer 0 |
| FF58         | Timer 1 |
| FF60         | Timer 2 |
| FFA0         | Upper memory select |
| FFA2         | Lower memory select |
| FFA4         | Peripheral select |
| FFA6         | Middle memory base |
| FFA8         | Mid Men and Peripherals |
| FFC0-FFDF    | DMA Stuff |}
| FFE0         | Memory partition reg |
| FFE2         | Clock prescaler |
| FFE4         | Enable refresh |
| FFF0         | Power-Save |
| FFFE         | Cpu Relocation |

How the PCS works:

PBA is set to 0x400. 0 Wait states for PCS0-PCS3. 0 wait states for PCS4-6. 

| line | range | Result |
| ---- | ----- | ------ |
| PCS0 | PBA - PBA+127 |  400-47F |
| PCS1 | PBA+128 - PBA+255 | 480-4FF |
| PCS2 | PBA+256 - PBA+383 | 500-57F |
| PCS3 | PBA+384 - PBA+511 | 580-5FF |
| PCS4 | PBA+512 - PBA+639 | 600-67F |
| PCS5 | PBA+640 - PBA+767 | 680-6FF |
| PCS6 | PBA+767 - PBA+896 | 700-77F |

The logical place to put my own regs is 0x400-0x4FF. Since H8 boards don't care about
the upper address bits, this should translate to 0x00 - 0xFF.

Alternatively, could we just set PBA to 0, and move everything down to start at zero? Not
sure why it was done this way.
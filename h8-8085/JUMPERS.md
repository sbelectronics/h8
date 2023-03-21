Jumper settings for H8-8085 board. 

Bold settings indicate what Scott set for his build.



| Jumper | Desc                                                         | 1-2                                   | 2-3             |
| ------ | ------------------------------------------------------------ | ------------------------------------- | --------------- |
| JP1    | H37                                                          | **no H37**                            | H37             |
| JP2    | H37                                                          | H37 (absent)                          |                 |
| JP3    | Side Select (note: confirm with your configuration; scott's build may be backwards) | normal                                | **inverted**    |
| JP4    | onboard RAM enable                                           | **enable**                            | disable         |
| JP5    | !CLK/CLK to HLDA delay latch                                 | **!CLK**                              | CLK             |
| JP6    | HLDA bus source                                              | !DHLDA                                | **DHLDA**       |
| JP7    | Front Panel interrupt enable                                 | **toggle based on EI/DI instruction** | force always on |
| JP8    | ROMDIS normal/inverted                                       | normal                                | **inverted**    |
| JP9    | ROM size                                                     | **32K**                               | 4K or 8K        |
| JP10   | int1 source                                                  | internal                              | **front panel** |
| JP11   | int1 eliminate dups                                          | eliminate dups (absent)               |                 |
| JP12   | 2MS clock polarity                                           | Q                                     | **!Q**          |
| JP13   | ale latch enable                                             | **obey HLDA**                         | always          |
| JP14   | bus clock source                                             | **!CLK**                              | CLK             |
| JP15   | A12 input to address PLD                                     | connect A12 **(present)**             |                 |
| JP16   | Ready input from bus                                         | connect **(present)**                 |                 |
| JP17   | 2MS clock reset                                              | **362**                               | 360             |
| JP18   | Charge                                                       | enable charge (absent)                |                 |
| JP19   | data bus latch enable                                        | **obey HLDA**                         | always          |
| JP20   | A12/A0 input to adress PLD                                   | A12                                   | **A0**          |
| JP21   | address bus latch enable                                     | **obey HLDA**                         | always          |
| JP22   | Normal Clock Source                                          | **OG3/5** (use 20.48MHz OG3)          | OG1 (use 4.096MHz OG1)  |
| JP23   | Turbo Clock Source                                           | **OG3/2** (use 20.48MHz OG3)          | OG3 (use 10MHz OG3)     |
| JP24   | 2ms enable address                                           | **363** (nortberto setting)           | 360             |
| JP25   | HOLD polarity                                                | **inverted**                          | noninverted     |
| JP26   | 2ms enable data bin                                          | **D1** (norberto setting)             | D6              |
| JP28   | 2ms clock phase                                              | **Q**                                 | !Q              |
| SV2    | ROM type                                                     | **1-2, 3-4 28C256**                   | 2-3, 4-5 27C256 |


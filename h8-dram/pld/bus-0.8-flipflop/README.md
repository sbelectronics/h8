Connect to flipflop
  1 - !RESET
  2 - G
  3 - XACK (use PLD#2 as an inverter)
  4 - PLD#1 - 14
  5 - PLD#1 - 2
  6 - NC
  7 - GND
  8 - NC
  9 - PLD#1 - 3
  10 - PLD#1 - 20
  11 - XACK (use PLD#2 as an inverter)
  12 - G
  13 - !REESET
  14 - VCC

Observed notes

1) Glitches on 8085 MEMR at end of address cycle will cause us to
   latch up the flipflop with a read while the 8203 misses this read
   because CS is dropping at the same time. Adding a capacitor to BMEMR
   had some minor effect.

2) At 20MHz clock, most writes are lost as the 8203 completes the write
   before the data is on the bus. Try a 10MHz clock.

3) On Z80, observed cases where a write was latched by the flipflop, but
   no XACK was received. RAS was high during this time. Suspect the 8203
   was busy, and CS dropped by the time it got around to being ready to
   accept the operation

Conclusion

1) Needs deglitching on MEMR / MEMW via RC filter and 7414

2) Use 10 MHz clock

3) Needs assertion of CS throughout the time we're driving RD and
   WR. Needs latching of address bits.

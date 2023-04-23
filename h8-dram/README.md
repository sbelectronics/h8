H8-64K-DRAM, aka "H8-Hellboard"
https://www.smbaker.com/

## Hellboard 0.23/0.24 - BUILD THIS ONE.

Revision 0.18 had a few bugs, such as CAS and RAS traces being broken. Those are all fixed. Also removed
some circuits (such as flipflops) that were not needed. Kept one flipflop and the LS123 just in case
they were needed.

0.23 adds the 74S03 that was used on Willis's board to generate the RD and WR pulses for the D8203, as an
option. This will produce very low latency on the read and write strobes, but unsude if it's actually
necessary.

Expectation is that this board will work as-is on 8085 and 8080, and on Z80 if Z80 board has "early write"
enabled. Board should be configured to use Delayed-WE to the DRAM, and to use SACK to generate wait states.
It's actually the period where RD or WR is asserted and SACK is not that iw when we assert WAIT.

Use the PLDs in pld/bus/bus-0.24 and pld/addr/addr-0.16.

## Hellboard 0.18

With Willis's help, we analyzed the mystery DRAM board (in the ebay folder) and determined a partial netlist. Some insights
from the mystery board:

* WAIT is initiated when Reading or Writing, but SACK has not yet occurred. This eliminates a lot
  of the complexity that I had with hellboard 0.16. 

* WE is delayed until after CAS. This is called a "late write" to DRAM as opposed to an "early write"
  which is what is normally executed. The late write is necessary because the 8080 might not have
  the data on bus at this time.

* Willis's board shows what we believe to be a 220R/27pF delay via an LS14 on the CAS signal for
  the delayed write. This was shown to be insufficient. 220R/100pF seemed to at least mostly work. The
  measured CAS delay with these components is 27ns.

* my 100ohm/10pF filter on MR and MW provides 22ns of delay

## Hellboard 0.16

Hellboard was an ill-fated attempt to use a D8203 DRAM controller to build a DRAM board
for the H8 computer. Hellboard has the following restrictions:

* Does not work at all on 8080. Writes complete on the DRAM controller before the 8080 has put them on the bus.
* Works inconsistently on the 8085.
* Sometimes gets in a bad mood on the Z80 and needs to be coaxed to boot. Once it boots once, it tends to work fine (including reboots) until it is shut back off again.
* Possibly sensitive to temperature (see above "bad mood" issue)

A few insights were made while implementing Hellboard:

* The D8203 may acknowledge a transfer after the host computer would have normally completed the
  transfer. This is not obvious from the datasheet, which suggests XACK can simply be used to
  implement wait states. You need to assert the wait state from the start of the RD or WR strobe
  until XACK is received. This will require additional logic.

* Z80 (and 8080?) sample the WAIT pin prior to asserting !WR. This means that you can't extend a
  write cycle after it has begun. This means you need to latch the address and data buses while
  performing a write, because it's possible the host computer will move on to other business while
  you're still trying to write the data.

* Even worse yet, Z80 (and 8080?) will start the next cycle, for example a !RD while you're still
  in a wait state. You have to be careful to not start the RD immediately after the WR has completed,
  or it may get lost. For this reason, I used a delay to insert about 20ns worth of deadtime before
  !RD or !WR can be asserted after an XACK. This prevents the lost-read-after-write syndrome.

Current board was built using ADDR-0.16 PLD and BUS-0.16 PLD.

## When it doesn't boot

Check address 20D7 (aka 040-327). If 0xFF, will not boot. If 0x00, will boot

This is S.CONTY which contains terminal characteristics. This is the problematic bit:

```
./acm/esval.acm:CTP.HHS EQU     00000100B               ; Terminal uses hdwr handshake  /3.0a/
```

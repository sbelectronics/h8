H8-64K-DRAM, aka "H8-Hellboard"
https://www.smbaker.com/

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

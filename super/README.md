Raspberry Pi Bus Supervisor for the Heathkit H8
Scott Baker, http://www.smbaker.com/

## Purpose

As an aid in diagnostics, debugging, and software development, this allows
a raspberry pi to seize control of the H8 bus and read and write memory. 

## Notes

Do not install the RESET jumper. Instead, run a wire from the pi-side of the
jumper to the RESIN pin on your H8 CPU Board.

This only works if your memory is external to your CPU board. If you're using
one of the aftermarket CPU boards (i.e. Norberto's Z80, Z180, 8080, etc) that
has internal memory, then you will need to disable that memory and use an
external memory board. THIS HAS NOT BEEN TESTED YET. To date, I have only
used a stock H8 8080 board.

## Examples

```bash
# poke memory, split octal address 040100, value 22 hex
$ sudo python ./supercmd.py -A 040100A -V 0x22 poke

# peek memory
$ sudo python ./supercmd.py -A 040100A peek
22

# load an H8T tape image
$ sudo python ./supercmd.py -f BHBASIC1.H8T loadh8t

# dump memory
$ sudo python ./supercmd.py -A 040100A -C 10 --octal --ascii memdump
040100 303 \xc3
040101 076 >
040102 073 ;
040103 303 \xc3
040104 164 t

# save arbitrary memory image
sudo python ./supercmd.py -f TEST.BIN -A 040100A -C 7678 saveimg

# load arbitrary memory image
$ sudo python ./supercmd.py -f TEST.BIN -A 040100A loadim
```
Note that an "A" or a "Q" suffix on a value will generally cause the program to treat the value as octal. The --octal flag will impose a similar default on numbers (other than "count").

## How it works

The H8 bus has two lines, HOLD and HLDA. Push HOLD low and the CPU will
give up the bus and acknowledge by setting HLDA high. Once the pi sees
HLDA is high, the pi can perform abitrary memory reads and writes. Once
finished, the pi releases HOLD and the H8 will resume processing.

```

```
HDOS 3.02 RAMDISK DRIVER
Scott Baker, www.smbaker.com

# Usage

Note: Do not use the Ramdisk unless you have the SEBHC 512K MMU board
or the smbaker.com 8MB MMU board installed. Using the ramdisk without
an MMU-style board will corrupt the contents of main memory, probably
inducing a reboot.

Initialize the ramdisk.

```HDOS
init rd0:
```

Mount the ramdisk.

```HDOS
mount rd0:
```

## Ramdisks

The Ramdisk driver supports devices RD0: through RD7:. If you are using the SEBHC 512K
MMU board, then only RD0: is available and you will receive unpredictable and likely highly
undesirable results if you attempt to use RD1: through RD7:.

One smbaker.com board will support drives RD0: through RD3:.

Two smbaker.com boards (hypothetically) will support drives RD0: through RD7:.

## Options

`SET RD: TINY` ... [DEFAULT] set the driver to tiny mode, assumes bank0 contains only 512K

`SET RD: NOTINY` ... set the driver to standard mode, assumes bank0 contains 2MB

`SET RD: DEBUG` ... turns on verbose debug messages

`SET RD: NODEBUG` ... [DEFAULT] turns off verbose debug messages

## Tools

* `RDCOPY` ... This perform an image copy of one ramdisk to another. It supports 39SF040 Flash Memory in addition to RAM. Probably best not to have the destination mounted when you run this. Does not support RD0, since RD0 is a different size than RD1-RD7.

* `RDDIAG` ... Will detect whether 512K or 8MB board is installed, and which banks are populated.

* `RDDUMP` ... This will dump the first 4096 bytes of a ramdisk to the console in hex and ascii.

* `RDWRITE` ... This will write an increasing pattern of hex values to a ramdisk. It is destructive.

* `RDTEST` ... This performs a write/read test of approximately 400KB to the ramdisk. It uses the same code as the driver. It is destructive.

* `BURNTEST` ... Crude test of the flash burning code, to erase sector 0 of RD3 and write 3 bytes to it.

## Issues

### Internal device table overflow, device RD: ignored

Remove some storage device drivers (hint: `rename DKOFF.DVD=DK.DVD`, etc). On HDOS 3,
there should be 4 or fewer storage devices, including the RD device. On HDOS 2,
the number may be as low as 2 (i.e. SY and RD). Your mileage may vary.

### Illegal format for INIT parameter file, device RD: ignored

This problem happened on HDOS2 and was traced to the driver file being too small and
failing in the following code:

```assembly
   073.330  052 372 074 05267           LHLD    FDPE+PIC.LEN
   073.333  104         05268           MOV     B,H
   073.334  115         05269           MOV     C,L             BC = byte count
   073.335  041 341 074 05270           LXI     H,FDPB
   073.340  315 076 077 05271           CALL    $FREAB.
   073.343  332 062 074 05272           JC      FDP7            Error
```

Suspect a possible bug in HDOS2 init where it's trying to read past the end of the
file, if the end of file is very close to the end of the last block. For this, I
increased the size of the driver until it allocated an extra block.

## Building

This driver was built using VirtualHDOS by Douglass Miller.

See https://github.com/durgadas311/virtual-cpm/tree/master/vhdos

You will need to install VirtualHDOS as per Douglass's instructions. Make sure to copy
the assembler (ASM.ABS) and other necessary binaries to your SD0 volume. On SD1, install
all of the necessary ACM files from your particular HDOS driver build source. I probably
used the HDOS 3.02 driver source from the sebhc github.

Alternatively, you should be able to perform the build directly on an H8 using something
similar to the following:

```HDOS
ASM DK1:RD.REL,DK1:RD=DK1:RD,SY1:/ERR
ASM DK1:RDI.REL,DK1:RDI=DK1:RDI,SY1:/ERR
COPY RD.DVD=RD.REL,RDI.REL
DVDDKGEN RD:
```

You can find DVDDKGEN.ABS on HUGLibrary disk 885-1095, the HUG SY Driver.

## Changelog

### 1.00

* Initial release

### 1.01

* Increase size of driver so prevent HDOS 2.0 read past eof

* Add commented-out debug code in rdi.asm

* Return clear carry on a few init calls

* Add code to lock driver during load

### 1.02

* Fix crash on 8MHz

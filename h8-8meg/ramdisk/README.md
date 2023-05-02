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
DVDDKGEN SY:
```

You can find DVDDKGEN.ABS on HUGLibrary disk 885-1095, the HUG SY Driver.



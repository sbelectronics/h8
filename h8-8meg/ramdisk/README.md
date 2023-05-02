HDOS 3.02 RAMDISK DRIVER
Scott Baker, www.smbaker.com

# Usage

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

`SET RD: TINY` ... set the driver to tiny mode, assumes bank0 contains only 512K

`SET RD: NOTINY` ... set the driver to standard mode, assumes bank0 contains 2MB

`SET RD: DEBUG` ... turns on verbose debug messages

`SET RD: NODEBUG` ... turns off verbose debug messages
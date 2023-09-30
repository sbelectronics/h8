# VDIP1 Emulator

## Purpose

VDIP1 were all out of stock and I wanted to use one to transfer files to/from
my Heathkit H8 computer. What to do? Well I decided to just emulate one with
a spare raspberry pi

## Limitations

This program is only demonstrated to work with the Heathkit H8 computer 
using Glenn Roberts's VDIP utilities for HDOS. As such I only implemented
the functionality necessary for that.

* Supports commands: E, e, ipa, clf, checkdisk, dir, opr, opw, rdf, cd, sek, wrf.
* Supports ASCII mode only
* Easily gets confused when used with computers that support uppercase only, and a linux box that has lowercase files.
* Little or no error checking

## Hardware

Two 74HCT574 latches and a 74HCT74 flipflop are needed to implement the fifo. See
my blog at https://www.smbaker.com/ for details.

## Commands

python3 ./vdipcmd.py serve # serves files from the current working directory

python3 ./vdipcmd.py -D <dir> serve # serves files from some other working directory

python3 ./vdipcmd.py talk  # launches an interactive terminal that can send and receiver over the VDIP interface. Use with debugging.

## Installation

Run install dependencies as directed in INSTALL.md

Run `make install` to install the library. This install the library and builds the C extension only. The program remains in the current working directory.

## Flow-control on the pi

You might need to switch the uarts. By default on some pis, the bluetooth gets the good UART that supports flow control and the
serial port gets the shitty mini uart that does not. Switch them by putting this in /boot/config.txt

dtoverlay=pi3-miniuart-bt

Then you need to run this tool:

https://github.com/mholling/rpirtscts

Finally, use '--flow h' in picocom. Make sure to use ttyAMA0 instead of ttyS0 as the UARTs have now switched places.


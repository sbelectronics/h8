from __future__ import print_function
import string
import sys
import time
import RPi.GPIO as IO

PIN_D0=4
PIN_D1=5
PIN_D2=6
PIN_D3=7
PIN_D4=8
PIN_D5=9
PIN_D6=10
PIN_D7=11
PIN_RXF=12
PIN_TXE=13
PIN_RCLR=16
PIN_WCLR=17
PIN_WRPI=18
PIN_RDPI=19

DATAPINS = [PIN_D0, PIN_D1, PIN_D2, PIN_D3, PIN_D4, PIN_D5, PIN_D6, PIN_D7]

class VDIP:
    def __init__(self, verbose):
        IO.setmode(IO.BCM)
        for datapin in DATAPINS:
            IO.setup(datapin, IO.IN)

        IO.setup(PIN_RXF, IO.IN)
        IO.setup(PIN_TXE, IO.IN)
        IO.setup(PIN_WCLR, IO.OUT)
        IO.setup(PIN_RCLR, IO.OUT)
        IO.setup(PIN_WRPI, IO.OUT)
        IO.setup(PIN_RDPI, IO.OUT)

        IO.output(PIN_WCLR, 1)
        IO.output(PIN_RCLR, 1)
        IO.output(PIN_WRPI, 1)
        IO.output(PIN_RDPI, 1)

    def cleanup(self):
        IO.cleanup()

    def log(self, msg):
        if self.verbose:
            print(msg, file=sys.stderr)

    def delay(self):
        time.sleep(0.001)

    def clearWrite(self):
        IO.output(PIN_WCLR, 0)
        IO.output(PIN_WCLR, 1)

    def clearRead(self):
        IO.output(PIN_RCLR, 0)
        IO.output(PIN_RCLR, 1)

    def canWrite(self):
        return (IO.input(PIN_RXF)==1)

    def canRead(self):
        return (IO.input(PIN_TXE)==1)

    def write(self, b):
        for datapin in DATAPINS:
            IO.setup(datapin, IO.OUT)
        for datapin in DATAPINS:
            IO.output(datapin, b&1)
            b = b >> 1

        # strobe the write
        IO.output(PIN_WRPI,0)
        IO.output(PIN_WRPI,1)

        for datapin in DATAPINS:
            IO.setup(datapin, IO.IN)        

        # assert RXF to inform H8 byte has been written
        IO.output(PIN_RCLR,0)   ## possible race here
        IO.output(PIN_RCLR,1)

        time.sleep(0.001)

    def waitWrite(self, b):
        while not self.canWrite():
            pass
        self.write(b)

    def waitWriteStr(self, s):
        for c in s:
            self.waitWrite(ord(c))

    def read(self):
        b = 0
        for datapin in DATAPINS:
            IO.setup(datapin, IO.IN)

        IO.output(PIN_RDPI,0)   # pull down latch output

        for datapin in reversed(DATAPINS):
            b = b << 1
            b = b | IO.input(datapin)

        IO.output(PIN_RDPI,1)   # drop latch input
        
        # assert TXE to inform H8 byte has been written
        IO.output(PIN_WCLR,0)   ## possible race here
        IO.output(PIN_WCLR,1)

        return b



from __future__ import print_function
import sys
import RPi.GPIO as IO
import smbvdip.vdip_ext


class VDIP:
    def __init__(self, verbose):
        self.ext = smbvdip.vdip_ext
        if not self.ext.init():
            sys.exit(-1)

    def cleanup(self):
        pass

    def canWrite(self):
        return self.ext.canWrite()

    def canRead(self):
        return self.ext.canRead()

    def write(self, b):
        self.ext.write(b)

    def waitWrite(self, b):
        self.ext.waitWrite(b)

    def waitWriteStr(self, s):
        self.ext.waitWriteStr(s)

    def read(self):
        return self.ext.read()

import os
import sys

data = bytearray(sys.stdin.buffer.read())

picLen = (data[3]<<8) + data[2]

numsec = ((picLen - 1) + 256) >> 8

print("PIC.LEN = %04X, numsec = %04X" % (picLen, numsec), file=sys.stderr)

data[0x13] = numsec
data[0x14] = 0

sys.stdout.buffer.write(data)

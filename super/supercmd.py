from __future__ import print_function
import smbus
import string
import sys
import time
from smbpi.ioexpand import *
from optparse import OptionParser
#from hexfile import HexFile

from supervisor_direct import SupervisorDirect

def hex_escape(s):
    printable = string.ascii_letters + string.digits + string.punctuation + ' '
    return ''.join(c if c in printable else r'\x{0:02x}'.format(ord(c)) for c in s)

def load_image(super, addr, fn):
    filebytes = open(fn, "rb").read()
    super.mem_write_start(addr)    
    try:
        for b in filebytes:
            super.mem_write_fast(addr, b)
            addr += 1
    finally:
        super.mem_write_end()

def load_h8t(super, fn):
        word = 0
        odd = False
        filebytes = open(fn, "rb").read()
        state = 0

        while filebytes[0] == 0x16:
            filebytes = filebytes[1:]

        if filebytes[0] != 0x02:
            raise Exception("Expecting STX 0x02")

        # skip the STX
        filebytes = filebytes[1:]

        while True:
            if len(filebytes) == 0:
                print("No more bytes")
                return

            rtype = filebytes[0]

            if rtype == 0xFF:
                print("End of tape")
                return

            rnum = filebytes[1]
            filebytes = filebytes[2:]

            rlen = (filebytes[0] << 8) | filebytes[1]
            filebytes = filebytes[2:]
            
            print("Rec: type= 0x%02X, number= %d, length= %d" % (rtype, rnum, rlen))

            pc = (filebytes[0] << 8) | filebytes[1]
            filebytes = filebytes[2:]

            print("PC: %03o%03o split-octal" % (pc>>8, pc & 0xFF))

            addr = (filebytes[0] << 8) | filebytes[1]
            filebytes = filebytes[2:]

            print("addr: %03o%03o split-octal" % (addr>>8, addr & 0xFF))

            super.mem_write_start(addr)
            try:
                for i in range(0, rlen):
                    super.mem_write_fast(addr+i, filebytes[i])
            finally:
                super.mem_write_end()

            filebytes = filebytes[rlen:]

            cksum = (filebytes[0] << 8) | filebytes[1]
            filebytes = filebytes[2:]

def save_image(super, addr, size, fn):
    super.mem_read_start(addr)    
    try:
        f = open(fn, "wb")
        for i in range(0, size):
            byte = super.mem_read_fast(addr)
            f.write(byte.to_bytes(1,"big"))
            addr+=1
    finally:
        super.mem_read_end()

def fill(super, addr, size, value):
    super.mem_write_start(addr)    
    try:
        for i in range(0, size):
            super.mem_write_fast(addr, value)
            addr+=1
    finally:
        super.mem_write_end()        

def main():
    parser = OptionParser(usage="supervisor [options] command",
            description="Commands: ...")

    parser.add_option("-A", "--addr", dest="addr",
         help="address", metavar="ADDR", type="string", default=0)
    parser.add_option("-C", "--count", dest="count",
         help="count", metavar="ADDR", type="string", default="65536")
    parser.add_option("-V", "--value", dest="value",
         help="value", metavar="VAL", type="string", default=0)
    parser.add_option("-P", "--ascii", dest="ascii",
         help="print ascii value", action="store_true", default=False)
    parser.add_option("-O", "--octal", dest="octal",
         help="print octal value", action="store_true", default=False)         
    parser.add_option("-R", "--rate", dest="rate",
         help="rate for slow clock", metavar="HERTZ", type="int", default=10)
    parser.add_option("-B", "--bank", dest="bank",
         help="bank number to select on ram-rom board", metavar="NUMBER", type="int", default=None)
    parser.add_option("-v", "--verbose", dest="verbose",
         help="verbose", action="store_true", default=False)
    parser.add_option("-f", "--filename", dest="filename",
         help="filename", default=None)
    parser.add_option("-r", "--reset", dest="reset_on_release",
         help="reset on release of bus", action="store_true", default=False)
    parser.add_option("-n", "--norelease", dest="norelease",
         help="do not release bus", action="store_true", default=False)
    parser.add_option("-i", "--indirect", dest="direct",
         help="use the python supervisor", action="store_false", default=True)

    #parser.disable_interspersed_args()

    (options, args) = parser.parse_args(sys.argv[1:])

    if len(args)==0:
        print("missing command")
        sys.exit(-1)

    cmd = args[0]
    args=args[1:]

    if options.direct:
      super = SupervisorDirect(options.verbose)
    else:
      raise "Unsupported"
    
    addr = None
    if (options.addr):
        if options.addr.startswith("0x") or options.addr.startswith("0X"):
            addr = int(options.addr[2:], 16)
        elif options.addr.startswith("$"):
            addr = int(options.addr[1:], 16)
        elif options.addr.lower().endswith("q") or options.addr.lower().endswith("a"):
            addr = int(options.addr[:-4], 8) << 8 | int(options.addr[-4:-1], 8)
        elif options.octal:
            addr = int(options.addr[:-3], 8) << 8 | int(options.addr[-3:], 8)
        else:
            addr = int(options.addr)

    value = None
    if (options.value):
        if options.value.startswith("0x") or options.value.startswith("0X"):
            value = int(options.value[2:], 16)
        elif options.addr.startswith("$"):
            value = int(options.value[1:], 16)
        elif options.value.lower().endswith("q"):
            value = int(options.value[:-1], 8)
        elif options.octal:
            value = int(options.value, 8)
        else:
            value = int(options.value)

    count = None
    if (options.count):
        if options.count.startswith("0x") or options.count.startswith("0X"):
            count = int(options.count[2:], 16)
        elif options.count.startswith("$"):
            count = int(options.count[1:], 16)
        elif options.count.lower().endswith("q") or options.count.lower().endswith("a"):
            count = int(options.count[:-4], 8) << 8 | int(options.count[-4:-1], 8)
        #elif options.octal:  don't assume octal applies to counts
        #    addr = int(options.addr[:-3], 8) << 8 | int(options.addr[-3:], 8)
        else:
            count = int(options.count)

    if (cmd=="reset"):
        try:
            super.take_bus()
        finally:
            if not options.norelease:
                super.release_bus(reset=True)

    elif (cmd=="memdump"):
        try:
            super.take_bus()
            for i in range(addr, addr+count):
                val = super.mem_read(i)
                if options.octal:
                    if options.ascii:
                        print("%03o%03o %03o %s" % (i>>8, i&0xFF, val, hex_escape(chr(val))))
                    else:
                        print("%03o%03o %03o" % (i>>8, i&0xFF, val))
                else:
                    if options.ascii:
                        print("%04X %02X %s" % (i, val, hex_escape(chr(val))))
                    else:
                        print("%04X %02X" % (i, val))
        finally:
            if not options.norelease:
                super.release_bus()

    elif (cmd=="peek"):
        try:
            super.take_bus()
            if options.octal:
                print("%03o" % super.mem_read(addr))
            else:
                print("%02X" % super.mem_read(addr))

        finally:
            if not options.norelease:
                super.release_bus()

    elif (cmd=="poke"):
        try:
            super.take_bus()
            super.mem_write(addr, value)
        finally:
            if not options.norelease:
                super.release_bus()

    elif (cmd=="showint"):
        last=None
        while True:
            v = ((super.ixData.get_gpio(1)&INT) !=0)
            if v!=last:
                print(v)
                last=v

    elif (cmd=="loadimg"):
        try:
            super.take_bus()
            load_image(super, addr, options.filename)
        finally:
            if not options.norelease:
                super.release_bus()

    elif (cmd=="loadh8t"):
        try:
            super.take_bus()
            load_h8t(super, options.filename)
        finally:
            if not options.norelease:
                super.release_bus()

    elif (cmd=="saveimg"):
        try:
            super.take_bus()
            save_image(super, addr, count, options.filename)
            super.reset()
        finally:
            if not options.norelease:
                super.release_bus()

    elif (cmd=="fill"):
        try:
            super.take_bus()
            fill(super, addr, count, value)
            super.reset()
        finally:
            if not options.norelease:
                super.release_bus()


if __name__=="__main__":
    main()

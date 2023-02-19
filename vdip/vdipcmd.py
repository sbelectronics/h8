from __future__ import print_function
import string
import sys
import time
from optparse import OptionParser
from vdip import VDIP

CR = chr(0x0D)

def hex_escape(s):
    printable = string.ascii_letters + string.digits + string.punctuation + ' '
    return ''.join(c if c in printable else r'\x{0:02x}'.format(ord(c)) for c in s)

class VDIPServer:
    def __init__(self, vdip):
        self.vdip = vdip
        self.cwd = "."

    def dir(self):
        pass


    def handleLine(line):
        if (line=='E'):
            self.vdip.waitWriteStr("E" + CR)
        elif (line=='e'):
            self.vdip.waitWriteStr("e" + CR)
        elif (line=="ipa"):
            # ascii mode
            self.vdip.waitWriteStr("D:\>" + CR)
        elif (line.startswith("clf")):
            # close file
            self.vdip.waitWriteStr("D:\>" + CR)
        elif (line==""):
            # check for disk
            self.vdip.waitWriteStr("D:\>" + CR)
        elif (line=="dir"):
            self.dir()


    def serve(self):
        line = ""
        while True:
            if self.vdip.canRead():
                v = self.vdip.read()
                print(hex_escape(chr(v)),end="")
                sys.stdout.flush()
                if v==0x0D:
                    self.handleLine(self.vdip, line)
                    line=""
                else:
                    line=line+chr(v)
            time.sleep(0.01)



def talk(vdip):
    from getch import getch, raw, unRaw
    raw()
    try:
        while True:
            if vdip.canRead():
                v = vdip.read()
                print(hex_escape(chr(v)),end="")
                sys.stdout.flush()
            if vdip.canWrite():
                c = getch()
                if c is not None:
                    if ord(c) == 0x03:   # CTRL-C
                        print("CTRL-C")
                        return
                    print(hex_escape(c),end="")
                    sys.stdout.flush()
                    vdip.write(ord(c))
            time.sleep(0.01)
    finally:
        unRaw()

def main():
    parser = OptionParser(usage="supervisor [options] command",
            description="Commands: ...")

    parser.add_option("-P", "--ascii", dest="ascii",
         help="print ascii value", action="store_true", default=False)
    parser.add_option("-O", "--octal", dest="octal",
         help="print octal value", action="store_true", default=False)         
    parser.add_option("-v", "--verbose", dest="verbose",
         help="verbose", action="store_true", default=False)
    parser.add_option("-f", "--filename", dest="filename",
         help="filename", default=None)
    #parser.add_option("-i", "--indirect", dest="direct",
    #     help="use the python supervisor", action="store_false", default=True)

    (options, args) = parser.parse_args(sys.argv[1:])

    if len(args)==0:
        print("missing command")
        sys.exit(-1)

    cmd = args[0]
    args=args[1:]

    #if options.direct:
    #  super = SupervisorDirect(options.verbose)
    #else:
    #  raise "Unsupported"

    vdip = VDIP(options.verbose)
    try:
        if (cmd=="talk"):
            talk(vdip)
        elif (cmd=="serve"):
            VDIPServer(vdip).serve()
        else:
            raise Exception("Unknown command %s" % cmd)
    finally:
        vdip.cleanup()

if __name__=="__main__":
    main()

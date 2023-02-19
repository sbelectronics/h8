from __future__ import print_function
import string
import sys
import time
import os
from optparse import OptionParser
from vdip import VDIP

CR = chr(0x0D)

def hex_escape(s):
    printable = string.ascii_letters + string.digits + string.punctuation + ' '
    return ''.join(c if c in printable else r'\x{0:02x}'.format(ord(c)) for c in s)

def isValidDosFilename(fn):
    parts = fn.split(".")
    if len(parts)>2:
        return False
    
    if len(parts[0]) > 8:
        return False

    if len(parts[1])> 3:
        return False

    return True

class VDIPServer:
    def __init__(self, vdip):
        self.vdip = vdip
        self.cwd = "."
        self.fnMap = {}

    def prompt(self):
        print("<prompt>")
        self.vdip.waitWriteStr("D:\>" + CR)

    def commandFailed(self):
        print("<command failed>")
        self.vdip.waitWriteStr("Command Failed" + CR)

    def getDword(self, amount):
        return int(amount)

    def getFullName(self, fn):
        if fn in self.fnMap:
            fullName = self.fnMap[fn]
        else:
            fullName = os.path.join(self.cwd, fn)
            if os.path.exists(fullName):
                return fullName

            fullNameLower = os.path.join(self.cwd, fn.lower())
            if os.path.exists(fullNameLower):
                return fullNameLower

        return fullName

    def stat(self, line):
        print("<stat>")
        fn = line.split(" ")[1]
        fullName = self.getFullName(fn)

        if not os.path.exists(fullName):
            print("<file %s does not exist>" % fullName)
            self.commandFailed()
            return

        st = os.stat(fullName)
        size = st.st_size

        self.vdip.waitWriteStr(CR)
        self.vdip.waitWriteStr("%s $%02X $%02X $%02X $%02X " % (fn, size&0xFF, (size>>8)&0xFF, (size>>16)&0xFF, size>>24) + CR)
        print("<%s $%02X $%02X $%02X $%02X >" % (fn, size&0xFF, (size>>8)&0xFF, (size>>16)&0xFF, size>>24))
        self.prompt()

    def dir(self):
        print("<dir>")
        self.vdip.waitWriteStr(CR)
        self.fnMap = {}
        if self.cwd!=".":
            self.vdip.waitWriteStr(". DIR" + CR)
            self.vdip.waitWriteStr(".. DIR" + CR)
        for fn in os.listdir(self.cwd):
            if not isValidDosFilename(fn):
                continue
            if (fn==".") or (fn==".."):
                continue
            self.fnMap[fn.upper()] = os.path.join(self.cwd,fn)
            self.vdip.waitWriteStr(fn.upper())
            if os.path.isdir(os.path.join(self.cwd, fn)):
                self.vdip.waitWriteStr(" DIR")
            self.vdip.waitWriteStr(CR)
        self.prompt()

    def openRead(self, line):
        fn = line.split()[1]
        fullName = self.getFullName(fn)

        if not os.path.exists(fullName):
            print("<file %s does not exist>" % fullName)
            self.commandFailed()
            return

        self.openFile = open(fullName)

        self.prompt()

    def readFile(self, line):
        parts = line.split()
        fn = parts[0]
        amount = parts[1]
        amount = self.getDword(amount)

        bytes = self.openFile.read(amount)
        for b in bytes:
            self.vdip.waitWrite(ord(b))
        for i in range(0, amount-len(bytes)):
            self.vdip.write(0xFF)
        self.prompt()
        
    def handleLine(self, line):
        if (line=='E'):
            self.vdip.waitWriteStr("E" + CR)
        elif (line=='e'):
            self.vdip.waitWriteStr("e" + CR)
        elif (line=="ipa"):
            # ascii mode
            self.prompt()
        elif (line.startswith("clf")):
            # close file
            self.prompt()
        elif (line==""):
            # check for disk
            self.prompt()
        elif (line=="dir"):
            self.dir()
        elif (line.startswith("dir")):
            self.stat(line)
        elif (line.startswith("opr")):
            self.openRead(line)
        elif (line.startswith("rdf")):
            self.readFile(line)


    def serve(self):
        line = ""
        while True:
            if self.vdip.canRead():
                v = self.vdip.read()
                print(hex_escape(chr(v)),end="")
                sys.stdout.flush()
                if v==0x0D:
                    self.handleLine(line)
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

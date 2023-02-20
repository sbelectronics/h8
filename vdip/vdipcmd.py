from __future__ import print_function
import string
import sys
import time
import os
from optparse import OptionParser

QUIET=0
NORMAL=1
VERBOSE=2

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

    if len(parts)==2:
        # filename has an extension
        if len(parts[1])> 3:
            return False

    return True

class VDIPServer:
    def __init__(self, vdip, verbosity):
        self.vdip = vdip
        self.cwd = "."
        self.fnMap = {}
        self.verbosity = verbosity
        self.openFile = None
        self.openFileWrite = None

    def error(self,s):
        print(s)

    def info(self, s):
        if self.verbosity >= NORMAL:
            print(s)

    def prompt(self):
        self.info("<prompt>")
        self.vdip.waitWriteStr("D:\>" + CR)

    def commandFailed(self):
        self.info("<command failed>")
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
        fn = line.split(" ")[1]
        fullName = self.getFullName(fn)

        self.info("<stat %s>" % fullName)

        if not os.path.exists(fullName):
            self.info("<file %s does not exist>" % fullName)
            self.commandFailed()
            return

        st = os.stat(fullName)
        size = st.st_size

        self.vdip.waitWriteStr(CR)
        self.vdip.waitWriteStr("%s $%02X $%02X $%02X $%02X " % (fn, size&0xFF, (size>>8)&0xFF, (size>>16)&0xFF, size>>24) + CR)
        self.info("<%s $%02X $%02X $%02X $%02X >" % (fn, size&0xFF, (size>>8)&0xFF, (size>>16)&0xFF, size>>24))
        self.prompt()

    def dir(self):
        self.info("<dir>")
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

        self.info("<ofr %s>" % fullName)

        if not os.path.exists(fullName):
            self.info("<file %s does not exist>" % fullName)
            self.commandFailed()
            return

        self.openFile = open(fullName)

        self.prompt()

    def openWrite(self, line):
        fn = line.split()[1]
        fullName = self.getFullName(fn)

        self.info("<opw %s>" % fullName)

        self.openFileWrite = open(fullName, "wb")

        self.prompt()

    def readFile(self, line):
        parts = line.split()
        amount = parts[1]
        amount = self.getDword(amount)

        self.info("<rdf %d>" % amount)

        bytes = self.openFile.read(amount)
        for b in bytes:
            self.vdip.waitWrite(ord(b))
        for i in range(0, amount-len(bytes)):
            self.vdip.write(0xFF)
        self.prompt()

    def seekFile(self, line):
        parts = line.split()
        offset = parts[1]
        offset = self.getDword(offset)

        self.info("<seek %d>" % offset)

        if self.openFile is not None:
            self.openFile.seek(offset)

        if self.openFileWrite is not None:
            self.openFileWrite.seek(offset)

        self.prompt()

    def writeFile(self, line):
        parts = line.split()
        amount = parts[1]
        amount = self.getDword(amount)

        self.info("<wrf %d>" % amount)

        bytes = bytearray()

        for i in range(0, amount):
            while not self.vdip.canRead():
                pass
            bytes.append(self.vdip.read())

        self.openFileWrite.write(bytes)
 
        self.prompt()

    def cd(self, line):
        parts = line.split()
        dirname = parts[1]

        self.info("<cd %s>" % dirname)

        if dirname == "..":
            newCwd = "/".join(self.cwd.split("/")[:-1])
        elif dirname == ".":
            newCwd = self.cwd
        else:
            newCwd = os.path.join(self.cwd, dirname)
            if not os.path.exists(newCwd):
                newCwd = os.path.join(self.cwd, dirname.lower())
                if not os.path.exists(newCwd):
                    self.commandFailed()
                    return

        self.cwd = newCwd
        self.info("<new cwd %s>" % self.cwd)

        self.prompt()

    def closeFile(self):
        self.info("<clf>")
        if self.openFile:
            self.openFile.close()
            self.openFile = None
        if self.openFileWrite:
            self.openFileWrite.close()
            self.openFileWrite = None
        self.prompt()

        
    def handleLine(self, line):
        if (line=='E'):
            self.info("<E>")
            self.vdip.waitWriteStr("E" + CR)
        elif (line=='e'):
            self.info("<e>")
            self.vdip.waitWriteStr("e" + CR)
        elif (line=="ipa"):
            # ascii mode
            self.info("<ipa>")
            self.prompt()
        elif (line.startswith("clf")):
            # close file
            self.closeFile()
        elif (line==""):
            # check for disk
            self.info("<checkdisk>")
            self.prompt()
        elif (line=="dir"):
            self.dir()
        elif (line.startswith("dir")):
            self.stat(line)
        elif (line.startswith("opr")):
            self.openRead(line)
        elif (line.startswith("opw")):
            self.openWrite(line)            
        elif (line.startswith("rdf")):
            self.readFile(line)
        elif (line.startswith("cd")):
            self.cd(line)
        elif (line.startswith("sek")):
            self.seekFile(line)
        elif (line.startswith("wrf")):
            self.writeFile(line)
        else:
            self.error("<unknown command %s>" % line)


    def serve(self):
        line = ""
        while True:
            if self.vdip.canRead():
                v = self.vdip.read()

                if self.verbosity>=VERBOSE:
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
    parser.add_option("-q", "--quiet", dest="quiet",
         help="quiet", action="store_true", default=False)
    parser.add_option("-f", "--filename", dest="filename",
         help="filename", default=None)
    parser.add_option("-p", "--python", dest="useExtension",
         help="use the python code instead of the c extension", action="store_false", default=True)

    (options, args) = parser.parse_args(sys.argv[1:])

    if len(args)==0:
        print("missing command")
        sys.exit(-1)

    cmd = args[0]
    args=args[1:]

    verbosity = NORMAL
    if options.quiet:
        verbosity = QUIET
    elif options.verbose:
        verbosity = VERBOSE

    if options.useExtension:
        from smbvdip.vdip_c import VDIP
        vdip = VDIP(options.verbose)
    else:
        from smbvdip.vdip import VDIP
        vdip = VDIP(options.verbose)

    try:
        if (cmd=="talk"):
            talk(vdip)
        elif (cmd=="serve"):
            VDIPServer(vdip,verbosity).serve()
        else:
            raise Exception("Unknown command %s" % cmd)
    finally:
        vdip.cleanup()

if __name__=="__main__":
    main()

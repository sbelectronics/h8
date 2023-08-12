import sys

def load_xcon8(fn, rom):
    filebytes = open(fn, "rb").read()

    filebytes = [ord(b) for b in filebytes]

    i=0
    for b in filebytes:
        rom[i] = b
        i += 1


def load_h8t(fn, rom):
        word = 0
        odd = False
        filebytes = open(fn, "rb").read()
        state = 0

        filebytes = [ord(b) for b in filebytes]

        while filebytes[0] == 0x16:
            filebytes = filebytes[1:]

        if filebytes[0] != 0x02:
            raise Exception("Expecting STX 0x02")

        # skip the STX
        filebytes = filebytes[1:]

        already=False
        pc=None
        rlen=None
        addr=None
        outbytes = []

        while True:
            if len(filebytes) == 0:
                print("No more bytes")
                return (addr, pc, rlen)

            rtype = filebytes[0]

            if rtype == 0xFF:
                print("End of tape")
                return (addr, pc, rlen)

            if already:
                raise Exception("Uh oh. Fixme for more than one record")

            already=True

            rnum = filebytes[1]
            filebytes = filebytes[2:]

            if (rlen is None):
                rlen = (filebytes[0] << 8) | filebytes[1]
            filebytes = filebytes[2:]

            print("Rec: type= 0x%02X, number= %d, length= %d" % (rtype, rnum, rlen))

            if (pc is None):
                pc = (filebytes[0] << 8) | filebytes[1]
            filebytes = filebytes[2:]

            print("PC: %03o%03o split-octal" % (pc>>8, pc & 0xFF))

            addr = (filebytes[0] << 8) | filebytes[1]
            filebytes = filebytes[2:]

            print("addr: %03o%03o split-octal" % (addr>>8, addr & 0xFF))

            for i in range(0, rlen):
                rom[addr + i] = filebytes[i]

            filebytes = filebytes[rlen:]

            cksum = (filebytes[0] << 8) | filebytes[1]
            filebytes = filebytes[2:]

            return (addr, pc, rlen)


def patch(fn, rom):
    lines = open(fn).readlines()
    for line in lines:
        if ";;" in line:
            line = line.split(";;")[0]
        line = line.strip()
        if not line:
            continue
        if (".ORG") in line:
            addr = int(line.split(" ")[1],16)
        elif ";" in line:
            line = line.split(";")[1].strip()
            for hv in line.split(" "):
                v = int(hv,16)
                #print("patch %04X=%02X" %(addr, v))
                rom[addr] = v
                addr += 1

def main():
    if len(sys.argv) <= 2:
        print("Syntax: h8t-to-tmi <input> <output>")

    rom = bytearray()
    for i in range(0,32768):
        rom.append(0)

    load_xcon8("2732_444-70_XCON8.ROM", rom)

    (addr, pc, totlen) = load_h8t(sys.argv[1], rom)

    patch("romload.txt",rom)

    # note: these match up to addresses in romload.txt

    rom[0x7E1] = (totlen & 0xFF)
    rom[0x7E2] = (totlen >> 8)
    rom[0x7E4] = (addr & 0xFF)
    rom[0x7E5] = (addr >> 8)
    rom[0x7F0] = (pc & 0xFF)
    rom[0x7F1] = (pc >> 8)

    open(sys.argv[2],"wb").write(rom)


if __name__ == "__main__":
    main()


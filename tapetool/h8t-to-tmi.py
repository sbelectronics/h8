import sys

def load_h8t(fn):
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

        pc=None
        rlen=None
        addr=None
        outbytes = []

        while True:
            if len(filebytes) == 0:
                print("No more bytes")
                return (addr, pc, outbytes)

            rtype = filebytes[0]

            if rtype == 0xFF:
                print("End of tape")
                return (addr, pc, outbytes)

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
                outbytes.append(filebytes[i])

            filebytes = filebytes[rlen:]

            cksum = (filebytes[0] << 8) | filebytes[1]
            filebytes = filebytes[2:]

            return (addr, pc, outbytes)


def save_tmi(fn, addr, pc, bytes):
    f=open(fn,"wb")
    f.write(chr(0xFF))
    f.write(chr(0x00))
    f.write(chr(addr & 0xFF))
    f.write(chr(addr >> 8))
    f.write(chr(len(bytes) & 0xFF))
    f.write(chr(len(bytes) >> 8))
    f.write(chr(pc & 0xFF))
    f.write(chr(pc >> 8))
    for b in bytes:
        f.write(chr(b))


def main():
    if len(sys.argv) <= 2:
        print("Syntax: h8t-to-tmi <input> <output>")

    (addr, pc, bytes) = load_h8t(sys.argv[1])

    save_tmi(sys.argv[2], addr, pc, bytes)


if __name__ == "__main__":
    main()


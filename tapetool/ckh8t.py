import sys

def crc16(data: bytes):
    xor_in = 0x0000  # initial value
    xor_out = 0x0000  # final XOR value
    poly = 0x8005  # generator polinom (normal form)

    reg = xor_in
    for octet in data:
        # reflect in
        for i in range(8):
            topbit = reg & 0x8000
            if octet & (0x80 >> i):
                topbit ^= 0x8000
            reg <<= 1
            if topbit:
                reg ^= poly
        reg &= 0xFFFF
        # reflect out
    return reg ^ xor_out

def ck_h8t():
        word = 0
        odd = False
        filebytes = sys.stdin.buffer.read() # open(fn, "rb").read()
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

            ob = filebytes

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

            # crc includes rtype:1, rnum:1, rlen:2, pc:2, addr:2, data, crc:2
            crc = crc16(ob[:(rlen+10)])

            filebytes = filebytes[rlen:]

            cksum = (filebytes[0] << 8) | filebytes[1]
            filebytes = filebytes[2:]

            if (crc == 0):
                print("CRC is good")
            else:
                print("CRC mismatch: %04X, %04X" % (crc, cksum))

ck_h8t()

#print("%04X" % crc16([1,2,3,4,0x9E,0x33]))

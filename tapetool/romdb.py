bytes = open("2732_444-70_XCON8.ROM","rb").read()

for b in bytes[:2048]:
    print("\tDB 0%02XH" % ord(b))

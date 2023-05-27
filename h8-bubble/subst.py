import sys

x = sys.stdin.read()
y = open("bbl.inc").read()

x = x.replace("XXXINCLUDEXXX",y)

sys.stdout.write(x)

import os
import sys
import re

def ireplace(old, repl, text):
    return re.sub('(?i)'+re.escape(old), lambda m: repl, text)


for l in sys.stdin.readlines():
    l = l.strip()
    l = ireplace(" print ", " PR", l)
    l = ireplace(" goto ", " GOT", l)
    l = ireplace(" gosub ", " GOS", l)
    l = ireplace(" dim ", " DI", l)
    l = ireplace(" input ", " INP", l)
    l = ireplace(" end", " EN", l)
    l = ireplace(" then ", " TH", l)
    l = ireplace(" if ", " IF", l)
    l = ireplace(" for ", " FO", l)
    l = ireplace(" to ", " TO", l)
    l = ireplace(" pin(", " PI", l)
    l = ireplace("(pin(", " (PI", l)
    l = ireplace(" and ", " AN", l)
    l = ireplace(" return", " RET", l)
    l = ireplace(" next", " NE", l)
    l = ireplace(" out", " OU", l)
    print l

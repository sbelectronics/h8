import re
import sys

data = sys.stdin.read()

def fixlabel(x):
    d=""
    while (x[0] != ' ') and (x[0] != '\t'):
        d = d + x[0];
        x = x[1:]
    d = d + ':' + x
    return d

def fixcomm(x):
    d=""
    last=None
    while x:
        if (x[0]=='*') and ((last==' ') or (last=='\t')):
           d = d + ';'
        else:
           d = d + x[0];
        last = x[0]
        x = x[1:]
    return d

for line in data.split("\n"):
    if line.startswith("*"):
       line = ';' + line[1:]
    elif line:
       line = re.sub("EQU[ \t]+\*","", line)
       if (not line.startswith(' ')) and (not line.startswith('\t')):
          if "EQU" not in line.upper():
              line = fixlabel(line)
    line = fixcomm(line)
    print line
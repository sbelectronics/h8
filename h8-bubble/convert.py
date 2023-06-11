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

# JP in 8080 is "JP P," in Z80.
# The assembler doesn't realize this and assembles it as a "JMP" instead
def fixjp(x):
   y = x.split(";")[0].upper()
   if (" JP " in y) or ("\tJP\t" in y) or (" JP\t" in y) or ("\tJP " in y):
      if not ("," in y):
         x = x.replace("JP", "JP P,")
   return x

for line in data.split("\n"):
    if line.startswith("*"):
       line = ';' + line[1:]
    elif line:
       line = re.sub("EQU[ \t]+\*","", line)
       if (not line.startswith(' ')) and (not line.startswith('\t')):
          if "EQU" not in line.upper():
              line = fixlabel(line)
    line = fixcomm(line)
    line = fixjp(line)
    print line
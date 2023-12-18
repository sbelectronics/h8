import os

data = open("/home/smbaker/projects/pi/sbc188/sbc188-bios-smbaker/bios064.bin","rb").read()

#data = open("/home/smbaker/projects/pi/sbc188/bios044/ansi/BIOS064.BIN","rb").read()

flo = open("biosl.bin","wb")
fhi = open("biosh.bin","wb")

for i in range(0,4):
  i=0
  for x in data:
    if(i%2)==0:
      flo.write(bytes([x]))
    else:
      fhi.write(bytes([x]))
    i+=1



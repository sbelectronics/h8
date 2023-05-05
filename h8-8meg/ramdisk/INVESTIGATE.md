# HDOS 2.0 init bug

Problem was around 073.330. Failed to read the reset of the init file.
Suspect the issue is a bug in init, that it reads past the end
of the file. Solved by incrementing the size of the file enough so
that it grabs an extra block.

# 8MHz crash

Used rd3test.asm to find that things flipped out when it wrote block
200. Suspect the problem has to do with dropping paging in an abrupt
manner, causing MA14/MA15 from the PLD to be asserted in conflict 
with the MA14/MA15 from the page register. Resolved by dropping
paging only after we had reset all the page registers back to their
initial values.

10 REM bruteprime: the world's worst prime number calculator
15 REM www.smbaker.com
20 PRINT "LIMIT";
30 INPUT L
40 FOR N = 3 to L
50 FOR D = 2 TO (N-1)
60 IF (INT(N/D)*D)=N THEN GOTO 100
70 NEXT D
80 PRINT N;
90 GOTO 110
100 PRINT ".";
110 NEXT N
120 END

org 0xC000
MVI H, 0xC0
MVI L, 0x30
INR M       		; MOV M,A exhibits similar problem
JMP 0xC004


;; 
;; 26  C0  2E  30  34 C3 04 C0


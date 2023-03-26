org 0xC000
MVI H, 0xC0
MVI L, 0x30
CALL 0x3B0
INR M       		; MOV M,A exhibits similar problem
JMP 0xC004

;; requires XCON8 keyboard routine at 0x3B0
;; 
;; 26  C0  2E  30  CD  B0  03  34  C3  04  C0
;;
;; 046 300 056 060 315 260 003 064 303 004 300

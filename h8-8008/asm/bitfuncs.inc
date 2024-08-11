; Two functions for computing the hi and low byte of a word.
; Based on bitfuncs.inc from AS assembler by Alfred Arnold, http://john.ccac.rwth-aachen.de:8000/as

hi              function x,(x>>8)&255
lo              function x,x&255

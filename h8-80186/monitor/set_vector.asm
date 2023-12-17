section .text 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  get_vector
;       Get an interrupt vector
;
;       Enter with vector number in BL
;       Exit with vector in DX:AX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        global  get_vector
get_vector:
        pushm   bx,ds		; register saves

        xor     ax,ax           ; zero BX
        mov     ds,ax           ; set DS=0
        cnop
	mov	bh,0
        shl     bx,2            ; index * 4

        mov     ax,[bx]         ; load the vector
        mov     dx,[bx+2]       ;

        popm    bx,ds		; register restores
        ret                     ; result in DX:AX

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  set_vector
;       Set an interrupt vector
;
;       Enter with vector number in BL
;               vector in DX:AX
;
;       All registers preserved
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        global  set_vector

set_vector:
        pushm   cx,bx,ds	; register saves

	xor	cx,cx
        mov     ds,cx           ; set DS=0
        cnop
	mov	bh,0
        shl     bx,2            ; index * 4

        mov     [bx],ax         ; set offset
        mov     [bx+2],dx       ; set segment

        popm    cx,bx,ds	; register restores
        ret                     ; return

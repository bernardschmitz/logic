

        j       start

result:
        dw      0	; 1
	dw	0

start:
        li      r1, 10
back:
        sw      r1, zero, result
        dec     r1
        bne     r1, zero, back



	halt


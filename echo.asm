
charout:	equ	0fffe


start:
	li	a0,	pad
	jal	cout

	halt


cout:
	lw     at, a0, 0
        beq     at, zero, done 
        sw      at, zero, charout
        inc     a0
        j       cout
done:	jr	ra

	


pad:
	dw 	"hello", 0


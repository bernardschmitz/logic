
; random characters

loop:

	lw	t1, zero, 0xf002 ; get random num
	andi	t2, t1, 0x1f
	addi	t2, t2, 32
	sw	t2, zero, 0xfffe ; write random character

	lw	at, zero, 0xfffc
	beq	at, zero, loop

	halt


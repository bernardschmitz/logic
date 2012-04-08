
loop:

	lw	t1, zero, 0f002 ; get random num
	andi	t2, t1, 1f
	addi	t2, t2, 20
	sw	t2, zero, 0fffe ; write random character

	lw	at, zero, 0fffc
	beq	at, zero, loop

	halt



loop:
	lw	t1, zero, 0f002	; load random
	andi	t2, t0, 1f	; get screen row
	sw	t1, t2, 0a000	; send random num to screen row

	lw	t1, zero, 0f002 ; get random num
	andi	t2, t1, 1f
	addi	t2, t2, 20
	sw	t2, zero, 0fffe ; write random character

	inc	t0

	j	loop



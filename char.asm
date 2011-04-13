
start:
	li	t0, 20		; char ascii space
	li	t1, 7e		; limit ~

loop:
	sw	t0, zero, 0fffe	; write char
	addi	t0, t0, 1
	ble	t0, t1, loop

	sw	t0, zero, 0ffff ; clear screen
	j	start





start:
	li	t0, 20		; char ascii space
	li	t1, 0b		; limit

loop:
	sw	t0, zero, 0fffe	; write char
	inc	t0
	sw	t0, zero, 0fffe	; write char
	inc	t0
	sw	t0, zero, 0fffe	; write char
	inc	t0
	sw	t0, zero, 0fffe	; write char
	inc	t0
	sw	t0, zero, 0fffe	; write char
	inc	t0
	sw	t0, zero, 0fffe	; write char
	inc	t0
	sw	t0, zero, 0fffe	; write char
	inc	t0

	dec	t1
	bne	t1, zero, loop

	;sw	t0, zero, 0ffff ; clear screen
	j	start




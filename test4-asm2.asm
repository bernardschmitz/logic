
back:

	bne	r0, r0, back
	bne	r0, r0, forward

	beq	r0, r0, back
	beq	r0, r0, forward

	blt	r0, r0, back
	blt	r0, r0, forward

	bgt	r0, r0, back
	bgt	r0, r0, forward

	ble	r0, r0, back
	ble	r0, r0, forward

	bge	r0, r0, back
	bge	r0, r0, forward

forward:



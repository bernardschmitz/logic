
q0:	.org	54
	.set	ccc, 45

loop:
	 add	r4, zero, r6
	addi r3, zero, 0x34*0b11	; comment
	lw r3, zero, 1234

;	halt

	.string " wewefw ' ; wfwefwf "

	; clear

;	div
blah: .word 34, loop, 2+3

	.string "hello", 'hi'


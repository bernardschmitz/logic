
	changequote`'changequote(`{',`}')dnl

	j	start

result:
	dw	0, 0, 0, 0, 0, 0, 0, 0, 0, 0

	define(multest, {
		
		li	r1, $1
		li	r2, $2

		mul	r1, r2

		mflo	r4
		sw	r4, r3, result
		inc	r3
		mfhi	r4
		sw	r4, r3, result
		inc	r3

	})dnl

	align
start:

	clear	r3

	multest(64, 3)

	multest(2000, 3000)

	multest(64, 0fffd)   ; -3

	multest(0ff9c, 0fffd)     ; -100 -3

	multest(64, 0)
	



	halt


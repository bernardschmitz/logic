

0000	addi	r4, r0, ffff		0140 ffff
0002	addi	r1, r0, fill		0110 000a
loop:
0004	sw	r4, r1, 0		1a41 0000
0006	addi	r1, r1, 1		0111 0001
0008	j	loop			1500 0004
fill:
000a



-----------------


0000	addi	r1, r0, ffff					0110 ffff
0002	addi	r2, r0, 0000					0120 0000
0004	slt		r3, r1, r2		; true			0d31 2000
0006	slt		r4, r2, r1		; false		0d42 1000




		addi	r1, r0, ff			0110	00ff
		addi	r2, r0, 4			0120	0004
		mul		r1, r2				0301	2000
		mfhi	r3					1b30	0000	r3=0
		mflo	r4					1c40	0000	r4=3fc
		div		r1, r2				0401	2000
		mfhi	r5					1b50	0000	r5=3
		mflo	r6					1c60	0000	r6=3f
		halt						1f00	0000
		

0000:	
		addi	r1, r0, 1			0110	0001
		j		6510				1500	6510
		halt						1f00	0000
4004:
		addi	r1, r1, 1			0110	0001
		jr		r11					1600	b000
		halt						1f00	0000
6510:
		addi	r1, r1, 1			0110	0001
		addi	r10, r0, 8086		01a0	8086
		jr			r10				1600	a000
		halt						1f00	0000
8086:	
		addi	r1, r1, 1			0110	0001
		jal		r11, 4004			17b0	4004
		addi	r1, r1, 1			0110	0001
		addi	r13, r0, fff0		01d0	fff0
		jalr	r12, r13			18c0	d000
		addi	r1, r1, 1			0110	0001	r1=7
		halt						1f00	0000
fff0:
		addi	r1, r1, 1			0110	0001
		jr		r12					1600	c000
		halt						1f00	0000
		
		
		

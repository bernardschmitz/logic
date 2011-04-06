

0000	addi	r4, r0, ffff		0140 ffff
0002	addi	r1, r0, fill		0110 000a
loop:
0004	sw	r4, r1, 0		1a41 0000
0006	addi	r1, r1, 1		0111 0001
0008	j	loop			1500 0004
fill:
000a






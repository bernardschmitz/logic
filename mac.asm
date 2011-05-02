
	define(`id', 0)
	define(`label', `$1`'id')


	define(`blah', `define(`id', incr(id))
	clear	$1
label(ok):
	clear	$2
	clear	$3
	')


	blah(r1, r2, r3)

	nop

	blah(a2, v0, t1)

	halt


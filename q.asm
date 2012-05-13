
	.org	1

        .align
name_HIDDEN:
        .word   0
                .word   0
        .word   0x0006
        .string "hidden"
        .align
HIDDEN:
        .word   code_HIDDEN
        .align
code_HIDDEN:
	.word 0xbabe


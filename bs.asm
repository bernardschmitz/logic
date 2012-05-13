
	
	
	.set	timerlo,0xf000
	.set	timerhi,0xf001
	.set	random,0xf002
	.set	bufferclr,0xfffb
	.set	charrdy,0xfffc
	.set	charin,0xfffd
	.set	charout,0xfffe
	.set	screenclr,0xffff

	.set	f_immediate,0x8000
	.set	f_hidden,0x0001

	.set	data_stack,0x8000
	.set	return_stack,0x9000
	.set	buffer,0xa000
	.set	bufferlen,0x00ff

                	
	

; tos r8
; i r10
; w r11
; x r12
; rsp r13
; dsp r14

	

	
	
	
	
	
	j	start

	.org	0x10
	.align
DOCOL:
	
	 dec	r13
	 sw	r10, r13, 0	
	
	inc	r11
	
		inc	r11
		andi	r11, r11, 0xfffe
	
	move	r10, r11
_NEXT:
	lw	r11, r10, 0
	inc	r10
	lw	r12, r11, 0
	jr	r12


	

	



start:

	li	r13, return_stack
	li	r14, data_stack
	sw	r14, zero, var_SZ

	li	r10, yeah
	
	 j	_NEXT
	

yeah:	.word	INTERPRET, HALT
;yeah:	.word	TEST5, HALT

	
	.align
name_TEST:
	.word	0
		.word	0
	.word	0x0004
	.string "test"
	.align
TEST:
	.word	DOCOL
	.align
	
	.word LIT, 0xcafe, LIT, 0xbabe, OVER, EXIT

	
	.align
name_TEST0:
	.word	name_TEST
		.word	0
	.word	0x0005
	.string "test0"
	.align
TEST0:
	.word	DOCOL
	.align
	
	.word LIT, 0xcafe, LIT, 0xbabe, LIT, 0x10, ROT, EXIT

	
	.align
name_TEST2:
	.word	name_TEST0
		.word	0
	.word	0x0005
	.string "test2"
	.align
TEST2:
	.word	DOCOL
	.align
	
	.word LIT, 0xa, LIT, 0x1000, STORE, LIT, 0x1, LIT, 0x1000, PLUS_STORE, EXIT
	
	
	.align
name_TEST3:
	.word	name_TEST2
		.word	0
	.word	0x0005
	.string "test3"
	.align
TEST3:
	.word	DOCOL
	.align
	
	.word STATE, FETCH, VERSION, BASE, FETCH, EXIT

	
	.align
name_TEST4:
	.word	name_TEST3
		.word	0
	.word	0x0005
	.string "test4"
	.align
TEST4:
	.word	DOCOL
	.align
	
	.word LIT, buffer, LIT, 0x0ff, ACCEPT, LIT, 0, TO_IN, STORE
	.word BL, PARSE, CR, TYPE
	.word BL, PARSE, CR, TYPE
	.word BL, PARSE, CR, TYPE
	.word CR, EXIT

	
	.align
name_TEST5:
	.word	name_TEST4
		.word	0
	.word	0x0005
	.string "test5"
	.align
TEST5:
	.word	DOCOL
	.align
	
	.word LIT, 0x5, LIT, msg, LIT, 0x1a, TYPE, CR, ONE_MINUS, DUPE, LIT, 0, EQUALS, ZBRANCH, -0xc, EXIT
msg:	.string "Hi there, this is bsforth!"


	
	.align
name_TEST6:
	.word	name_TEST5
		.word	0
	.word	0x0005
	.string "test6"
	.align
TEST6:
	.word	DOCOL
	.align
	
	.word	LIT, buffer, LIT, 0x0ff, ACCEPT, LIT, 0, TO_IN, STORE
	.word	BL, PARSE, CR, TYPE
	.word	EXIT

	
	.align
name_TEST7:
	.word	name_TEST6
		.word	0
	.word	0x0005
	.string "test7"
	.align
TEST7:
	.word	DOCOL
	.align
	
	;dw	LIT, 0x2a, LIT, EMIT, EXECUTE, EXIT
	.word	LIT, TEST9, BRK, EXECUTE, EXIT


	
	.align
name_TEST8:
	.word	name_TEST7
		.word	0
	.word	0x0005
	.string "test8"
	.align
TEST8:
	.word	DOCOL
	.align
	
	.word	BINARY, LIT, num, LIT, 0xf, NUMBER, HALT
num:	.string	"-001100000101xx"



	
	.align
name_TEST9:
	.word	name_TEST8
		.word	0
	.word	0x0005
	.string "test9"
	.align
TEST9:
	.word	DOCOL
	.align
	
	.word	LIT, msg1, LIT, 5, TYPE, EXIT
msg1:	.string	"sheep"


	
	.align
name_TEST10:
	.word	name_TEST9
		.word	0
	.word	0x0006
	.string "test10"
	.align
TEST10:
	.word	DOCOL
	.align
	
	.word	LIT, msg2, LIT, 5, FIND, TO_CFA, EXECUTE, EXIT
msg2:	.string	"test9"

	
	.align
name_TEST11:
	.word	name_TEST10
		.word	0
	.word	0x0006
	.string "test11"
	.align
TEST11:
	.word	DOCOL
	.align
	
	.word	LIT, msg1, LIT, 5, FIND, EXIT

	
	.align
name_HIDDEN_TEST:
	.word	name_TEST11
		.word	f_hidden
	.word	0x000b
	.string "hidden_test"
	.align
HIDDEN_TEST:
	.word	DOCOL
	.align
	
	.word	TEST9, EXIT

	
	.align
name_TEST12:
	.word	name_HIDDEN_TEST
		.word	0
	.word	0x0006
	.string "test12"
	.align
TEST12:
	.word	DOCOL
	.align
	
	.word	LIT, msg3, LIT, 0xb, FIND, QUESTION_DUPE, ZBRANCH, 9
	.word	LIT, 0x2a, EMIT, CR, TO_CFA, EXECUTE, BRANCH, 7
	.word	LIT, msg3, LIT, 0xb, TYPE, CR, EXIT
msg3:	.string	"hidden_test"


	
	.align
name_HALT:
	.word	name_TEST12
		.word	0
	.word	0x0004
	.string "halt"
	.align
HALT:
	.word	code_HALT
	.align
code_HALT:
	
	halt

	
	.align
name_BRK:
	.word	name_HALT
		.word	0
	.word	0x0003
	.string "brk"
	.align
BRK:
	.word	code_BRK
	.align
code_BRK:
	
	brk
	
	 j	_NEXT
	

	
	.align
name_DSPFETCH:
	.word	name_BRK
		.word	0
	.word	0x0004
	.string "dsp@"
	.align
DSPFETCH:
	.word	code_DSPFETCH
	.align
code_DSPFETCH:
	
	move	r1, r14
	
	 dec	r14
	 sw	r1, r14, 0	
	
	
	 j	_NEXT
	

	
	.align
name_DSPSTORE:
	.word	name_DSPFETCH
		.word	0
	.word	0x0004
	.string "dsp!"
	.align
DSPSTORE:
	.word	code_DSPSTORE
	.align
code_DSPSTORE:
	
	lw	r1, r14, 0
	move	r14, r1
	
	 j	_NEXT
	


	
	.align
name_DROP:
	.word	name_DSPSTORE
		.word	0
	.word	0x0004
	.string "drop"
	.align
DROP:
	.word	code_DROP
	.align
code_DROP:
	
	inc	r14
	
	 j	_NEXT
	

	
	.align
name_NIP:
	.word	name_DROP
		.word	0
	.word	0x0003
	.string "nip"
	.align
NIP:
	.word	code_NIP
	.align
code_NIP:
	
	lw	r2, r14, 0
	inc	r14
	sw	r2, r14, 0
	
	 j	_NEXT
	

	
	.align
name_SWAP:
	.word	name_NIP
		.word	0
	.word	0x0004
	.string "swap"
	.align
SWAP:
	.word	code_SWAP
	.align
code_SWAP:
	
	lw	r2, r14, 0
	lw	r3, r14, 1

	sw	r3, r14, 0
	sw	r2, r14, 1
	
	 j	_NEXT
	

	
	.align
name_DUPE:
	.word	name_SWAP
		.word	0
	.word	0x0003
	.string "dup"
	.align
DUPE:
	.word	code_DUPE
	.align
code_DUPE:
	
	lw	r2, r14, 0
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	

	
	.align
name_OVER:
	.word	name_DUPE
		.word	0
	.word	0x0004
	.string "over"
	.align
OVER:
	.word	code_OVER
	.align
code_OVER:
	
	lw	r2, r14, 1
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	

	
	.align
name_ROT:
	.word	name_OVER
		.word	0
	.word	0x0003
	.string "rot"
	.align
ROT:
	.word	code_ROT
	.align
code_ROT:
	
	lw	r2, r14, 0
	lw	r3, r14, 1
	lw	r4, r14, 2

	sw	r4, r14, 0
	sw	r2, r14, 1
	sw	r3, r14, 2	
	
	 j	_NEXT
	

	
	.align
name_TWO_DROP:
	.word	name_ROT
		.word	0
	.word	0x0005
	.string "2drop"
	.align
TWO_DROP:
	.word	code_TWO_DROP
	.align
code_TWO_DROP:
	
	addi	r14, r14, 2
	
	 j	_NEXT
	

	
	.align
name_TWO_DUPE:
	.word	name_TWO_DROP
		.word	0
	.word	0x0004
	.string "2dup"
	.align
TWO_DUPE:
	.word	code_TWO_DUPE
	.align
code_TWO_DUPE:
	
	lw	r2, r14, 0
	lw	r3, r14, 1
	addi	r14, r14, -2
	sw	r2, r14, 0
	sw	r3, r14, 1
	
	 j	_NEXT
	

	
	.align
name_TWO_SWAP:
	.word	name_TWO_DUPE
		.word	0
	.word	0x0005
	.string "2swap"
	.align
TWO_SWAP:
	.word	code_TWO_SWAP
	.align
code_TWO_SWAP:
	
	lw	r2, r14, 0
	lw	r3, r14, 1
	lw	r4, r14, 2
	lw	r5, r14, 3

	sw	r4, r14, 0
	sw	r5, r14, 1
	sw	r2, r14, 2
	sw	r3, r14, 3
	
	 j	_NEXT
	

	
	.align
name_QUESTION_DUPE:
	.word	name_TWO_SWAP
		.word	0
	.word	0x0004
	.string "?dup"
	.align
QUESTION_DUPE:
	.word	code_QUESTION_DUPE
	.align
code_QUESTION_DUPE:
	
	lw	r2, r14, 0
	beq	r2, zero, qdup0
	
	 dec	r14
	 sw	r2, r14, 0	
	
qdup0:
	
	 j	_NEXT
	

	
	.align
name_ONE_PLUS:
	.word	name_QUESTION_DUPE
		.word	0
	.word	0x0002
	.string "1+"
	.align
ONE_PLUS:
	.word	code_ONE_PLUS
	.align
code_ONE_PLUS:
	
	lw	r2, r14, 0
	inc	r2
	sw	r2, r14, 0
	
	 j	_NEXT
	

	
	.align
name_ONE_MINUS:
	.word	name_ONE_PLUS
		.word	0
	.word	0x0002
	.string "1-"
	.align
ONE_MINUS:
	.word	code_ONE_MINUS
	.align
code_ONE_MINUS:
	
	lw	r2, r14, 0
	dec	r2
	sw	r2, r14, 0
	
	 j	_NEXT
	

	
	.align
name_PLUS:
	.word	name_ONE_MINUS
		.word	0
	.word	0x0001
	.string "+"
	.align
PLUS:
	.word	code_PLUS
	.align
code_PLUS:
	
	lw	r2, r14, 0
	lw	r3, r14, 1
	add	r2, r2, r3
	inc	r14
	sw	r2, r14, 0
	
	 j	_NEXT
	

	
	.align
name_MINUS:
	.word	name_PLUS
		.word	0
	.word	0x0001
	.string "-"
	.align
MINUS:
	.word	code_MINUS
	.align
code_MINUS:
	
	lw	r2, r14, 0
	lw	r3, r14, 1
	sub	r2, r3, r2
	inc	r14
	sw	r2, r14, 0
	
	 j	_NEXT
	

	
	.align
name_STAR:
	.word	name_MINUS
		.word	0
	.word	0x0001
	.string "*"
	.align
STAR:
	.word	code_STAR
	.align
code_STAR:
	
	lw	r2, r14, 0
	lw	r3, r14, 1
	mult	r2, r2, r3
	inc	r14
	sw	r2, r14, 0
	
	 j	_NEXT
	

	
	.align
name_SLASH:
	.word	name_STAR
		.word	0
	.word	0x0001
	.string "/"
	.align
SLASH:
	.word	code_SLASH
	.align
code_SLASH:
	
	lw	r2, r14, 0
	lw	r3, r14, 1
	divd	r2, r3, r2
	inc	r14
	sw	r2, r14, 0
	
	 j	_NEXT
	
	
	
	
	.align
name_SLASH_MOD:
	.word	name_SLASH
		.word	0
	.word	0x0004
	.string "/mod"
	.align
SLASH_MOD:
	.word	code_SLASH_MOD
	.align
code_SLASH_MOD:
	
	lw	r2, r14, 0
	lw	r3, r14, 1
	divd	r2, r3, r2
	sw	r2, r14, 0
	mfhi	r3
	sw	r3, r14, 1
	
	 j	_NEXT
	

	
	.align
name_INVERT:
	.word	name_SLASH_MOD
		.word	0
	.word	0x0006
	.string "invert"
	.align
INVERT:
	.word	code_INVERT
	.align
code_INVERT:
	
	lw	r2, r14, 0
	not	r2
	sw	r2, r14, 0
	
	 j	_NEXT
	

	
	.align
name_EQUALS:
	.word	name_INVERT
		.word	0
	.word	0x0001
	.string "="
	.align
EQUALS:
	.word	code_EQUALS
	.align
code_EQUALS:
	
	clear	r2
	lw	r3, r14, 0
	lw	r4, r14, 1
	bne	r3, r4, equals0
	not	r2
equals0:
	inc	r14
	sw	r2, r14, 0
	
	 j	_NEXT
	

	
	.align
name_LESS_THAN:
	.word	name_EQUALS
		.word	0
	.word	0x0001
	.string "<"
	.align
LESS_THAN:
	.word	code_LESS_THAN
	.align
code_LESS_THAN:
	
	clear	r2
	lw	r3, r14, 0
	lw	r4, r14, 1
	bge	r4, r3, not_lt
	not	r2
not_lt:
	inc	r14
	sw	r2, r14, 0
	
	 j	_NEXT
	

	
	.align
name_ZERO_EQUALS:
	.word	name_LESS_THAN
		.word	0
	.word	0x0002
	.string "0="
	.align
ZERO_EQUALS:
	.word	code_ZERO_EQUALS
	.align
code_ZERO_EQUALS:
	
	clear	r2
	lw	r3, r14, 0
	bne	r3, zero, not_eq
	not	r2
not_eq:
	sw	r2, r14, 0
	
	 j	_NEXT
	

	
	.align
name_NOT_EQUALS:
	.word	name_ZERO_EQUALS
		.word	0
	.word	0x0002
	.string "<>"
	.align
NOT_EQUALS:
	.word	DOCOL
	.align
	
	.word EQUALS, INVERT, EXIT

	
	.align
name_EXIT:
	.word	name_NOT_EQUALS
		.word	0
	.word	0x0004
	.string "exit"
	.align
EXIT:
	.word	code_EXIT
	.align
code_EXIT:
	
	
	 lw	r10, r13, 0	
	 inc	r13
	
	
	 j	_NEXT
	

	
	.align
name_LIT:
	.word	name_EXIT
		.word	0
	.word	0x0003
	.string "lit"
	.align
LIT:
	.word	code_LIT
	.align
code_LIT:
	
	lw	r2, r10, 0
	inc	r10
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	

	
	.align
name_STORE:
	.word	name_LIT
		.word	0
	.word	0x0001
	.string "!"
	.align
STORE:
	.word	code_STORE
	.align
code_STORE:
	
	lw	r2, r14, 0
	lw	r3, r14, 1
	sw	r3, r2, 0
	addi	r14, r14, 2
	
	 j	_NEXT
	

	
	.align
name_FETCH:
	.word	name_STORE
		.word	0
	.word	0x0001
	.string "@"
	.align
FETCH:
	.word	code_FETCH
	.align
code_FETCH:
	
	lw	r2, r14, 0
	lw	r2, r2, 0
	sw	r2, r14, 0
	
	 j	_NEXT
	

	
	.align
name_PLUS_STORE:
	.word	name_FETCH
		.word	0
	.word	0x0002
	.string "+!"
	.align
PLUS_STORE:
	.word	code_PLUS_STORE
	.align
code_PLUS_STORE:
	
	lw	r2, r14, 0
	lw	r3, r14, 1
	lw	r4, r2, 0
	add	r4, r4, r3
	sw	r4, r2, 0
	addi	r14, r14, 2
	
	 j	_NEXT
	


	

	
	
	.align
name_STATE:
	.word	name_PLUS_STORE
		.word	0
	.word	0x0005
	.string "state"
	.align
STATE:
	.word	code_STATE
	.align
code_STATE:
	
	li	r2, var_STATE
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	
var_STATE:	.word	0
	
	
	
	.align
name_HERE:
	.word	name_STATE
		.word	0
	.word	0x0004
	.string "here"
	.align
HERE:
	.word	code_HERE
	.align
code_HERE:
	
	li	r2, var_HERE
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	
var_HERE:	.word	start_dp
	
	
	
	.align
name_LATEST:
	.word	name_HERE
		.word	0
	.word	0x0006
	.string "latest"
	.align
LATEST:
	.word	code_LATEST
	.align
code_LATEST:
	
	li	r2, var_LATEST
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	
var_LATEST:	.word	name_LAST_WORD
	
	
	
	.align
name_SZ:
	.word	name_LATEST
		.word	0
	.word	0x0002
	.string "s0"
	.align
SZ:
	.word	code_SZ
	.align
code_SZ:
	
	li	r2, var_SZ
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	
var_SZ:	.word	data_stack
	
	
	
	.align
name_BASE:
	.word	name_SZ
		.word	0
	.word	0x0004
	.string "base"
	.align
BASE:
	.word	code_BASE
	.align
code_BASE:
	
	li	r2, var_BASE
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	
var_BASE:	.word	0xa
	
	
	
	.align
name_TO_IN:
	.word	name_BASE
		.word	0
	.word	0x0003
	.string ">in"
	.align
TO_IN:
	.word	code_TO_IN
	.align
code_TO_IN:
	
	li	r2, var_TO_IN
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	
var_TO_IN:	.word	0
	
	
	
	.align
name_NUMBER_TIB:
	.word	name_TO_IN
		.word	0
	.word	0x0004
	.string "#tib"
	.align
NUMBER_TIB:
	.word	code_NUMBER_TIB
	.align
code_NUMBER_TIB:
	
	li	r2, var_NUMBER_TIB
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	
var_NUMBER_TIB:	.word	0
	

	
	.align
name_BINARY:
	.word	name_NUMBER_TIB
		.word	0
	.word	0x0006
	.string "binary"
	.align
BINARY:
	.word	DOCOL
	.align
	
	.word	LIT, 0x2, BASE, STORE, EXIT

	
	.align
name_OCTAL:
	.word	name_BINARY
		.word	0
	.word	0x0005
	.string "octal"
	.align
OCTAL:
	.word	DOCOL
	.align
	
	.word	LIT, 0x8, BASE, STORE, EXIT

	
	.align
name_HEX:
	.word	name_OCTAL
		.word	0
	.word	0x0003
	.string "hex"
	.align
HEX:
	.word	DOCOL
	.align
	
	.word	LIT, 0x10, BASE, STORE, EXIT

	
	.align
name_DECIMAL:
	.word	name_HEX
		.word	0
	.word	0x0007
	.string "decimal"
	.align
DECIMAL:
	.word	DOCOL
	.align
	
	.word	LIT, 0xa, BASE, STORE, EXIT



	
	
	
	.align
name_VERSION:
	.word	name_DECIMAL
		.word	0
	.word	0x0007
	.string "version"
	.align
VERSION:
	.word	code_VERSION
	.align
code_VERSION:
	
	li	r2, 1
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	
	
	
	
	.align
name_RZ:
	.word	name_VERSION
		.word	0
	.word	0x0002
	.string "r0"
	.align
RZ:
	.word	code_RZ
	.align
code_RZ:
	
	li	r2, return_stack
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	
	
	
	
	.align
name__DOCOL:
	.word	name_RZ
		.word	0
	.word	0x0005
	.string "docol"
	.align
_DOCOL:
	.word	code__DOCOL
	.align
code__DOCOL:
	
	li	r2, DOCOL
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	
	
	
	
	.align
name_TIB:
	.word	name__DOCOL
		.word	0
	.word	0x0003
	.string "tib"
	.align
TIB:
	.word	code_TIB
	.align
code_TIB:
	
	li	r2, buffer
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	
	

	.set	blank,0x20

	
	
	.align
name_BL:
	.word	name_TIB
		.word	0
	.word	0x0002
	.string "bl"
	.align
BL:
	.word	code_BL
	.align
code_BL:
	
	li	r2, blank
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	
	

	
	.align
name_SPACE:
	.word	name_BL
		.word	0
	.word	0x0005
	.string "space"
	.align
SPACE:
	.word	code_SPACE
	.align
code_SPACE:
	
	li	r2, blank
	sw	r2, zero, charout
	
	 j	_NEXT
	

	
	.align
name_CR:
	.word	name_SPACE
		.word	0
	.word	0x0002
	.string "cr"
	.align
CR:
	.word	code_CR
	.align
code_CR:
	
	li	r2, newline
	sw	r2, zero, charout
	
	 j	_NEXT
	

	
	.align
name_TO_R:
	.word	name_CR
		.word	0
	.word	0x0002
	.string ">r"
	.align
TO_R:
	.word	code_TO_R
	.align
code_TO_R:
	
	
	 lw	r2, r14, 0	
	 inc	r14
	
	
	 dec	r13
	 sw	r2, r13, 0	
	
	
	 j	_NEXT
	

	
	.align
name_FROM_R:
	.word	name_TO_R
		.word	0
	.word	0x0002
	.string "r>"
	.align
FROM_R:
	.word	code_FROM_R
	.align
code_FROM_R:
	
	
	 lw	r2, r13, 0	
	 inc	r13
	
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	

	
	.align
name_RSPFETCH:
	.word	name_FROM_R
		.word	0
	.word	0x0004
	.string "rsp@"
	.align
RSPFETCH:
	.word	code_RSPFETCH
	.align
code_RSPFETCH:
	
	
	 dec	r14
	 sw	r13, r14, 0	
		
	
	 j	_NEXT
	

	
	.align
name_RSPSTORE:
	.word	name_RSPFETCH
		.word	0
	.word	0x0004
	.string "rsp!"
	.align
RSPSTORE:
	.word	code_RSPSTORE
	.align
code_RSPSTORE:
	
	
	 lw	r13, r14, 0	
	 inc	r14
		
	
	 j	_NEXT
	

	
	.align
name_RDROP:
	.word	name_RSPSTORE
		.word	0
	.word	0x0005
	.string "rdrop"
	.align
RDROP:
	.word	code_RDROP
	.align
code_RDROP:
	
	inc	r13
	
	 j	_NEXT
	


	
	.align
name_KEY_QUESTION:
	.word	name_RDROP
		.word	0
	.word	0x0004
	.string "key?"
	.align
KEY_QUESTION:
	.word	code_KEY_QUESTION
	.align
code_KEY_QUESTION:
	
	clear	r2
	lw	r3, zero, charrdy
	beq	r3, zero, _keyq0
	not	r2
_keyq0:
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	


	
	.align
name_KEY:
	.word	name_KEY_QUESTION
		.word	0
	.word	0x0003
	.string "key"
	.align
KEY:
	.word	code_KEY
	.align
code_KEY:
	
	jal	r15, _key
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	
_key:
	lw	r2, zero, charrdy
	beq	r2, zero, _key
	lw	r2, zero, charin
	jr	r15


	
	.align
name_EMIT:
	.word	name_KEY
		.word	0
	.word	0x0004
	.string "emit"
	.align
EMIT:
	.word	code_EMIT
	.align
code_EMIT:
	
	
	 lw	r2, r14, 0	
	 inc	r14
	
	sw	r2, zero, charout
	
	 j	_NEXT
	

	.set delete,0x08
	.set newline,0x0a

	
	.align
name_ACCEPT:
	.word	name_EMIT
		.word	0
	.word	0x0006
	.string "accept"
	.align
ACCEPT:
	.word	code_ACCEPT
	.align
code_ACCEPT:
	
	lw	r2, r14, 0		; max count
	lw	r3, r14, 1		; buffer address
	jal	r15, _accept
	inc	r14
	sw	r2, r14, 0		; count
	
	 j	_NEXT
	
_accept:
	move	r4, r2			; save max count
	clear	r5			; zero char count
	li	r6, newline		; eol char
	li	r7, delete		; bs char
_accept0:
	lw	r2, zero, charrdy
	beq	r2, zero, _accept0
	lw	r2, zero, charin

	beq	r2, r6, eol0		; is it eol char?
	beq	r2, r7, bs0		; is it bs char?
	beq	r4, zero, lim0		; have we reached the char limit?

	sw	r2, zero, charout	; output char
	sw	r2, r3, 0		; store char
	inc	r5			; count char
	inc	r3			; inc buffer address
	dec	r4			; decr max count
	j	_accept0		; get next char
lim0:
	sw	r7, zero, charout
	sw	r2, zero, charout	; output char
	sw	r2, r3, -1
	j	_accept0		; get next char
eol0:
	move	r2, r5			; save actual char count
	jr	r15			; return
bs0:
	beq	r5, zero, _accept0	; ignore bs if first key
	sw	r7, zero, charout
	dec	r5			; backspace buffer
	dec	r3
	inc	r4
	j	_accept0		; continue





	
	.align
name_TYPE:
	.word	name_ACCEPT
		.word	0
	.word	0x0004
	.string "type"
	.align
TYPE:
	.word	code_TYPE
	.align
code_TYPE:
	
	lw	r2, r14, 0
	beq	r2, zero, _type1
	lw	r3, r14, 1
	jal	r15, _type
_type1:
	addi	r14, r14, 2
	
	 j	_NEXT
	
_type:
	lw	r4, r3, 0
	sw	r4, zero, charout
	inc	r3
	dec	r2
	bne	r2, zero, _type
	jr	r15



	
	.align
name_PARSE:
	.word	name_TYPE
		.word	0
	.word	0x0005
	.string "parse"
	.align
PARSE:
	.word	code_PARSE
	.align
code_PARSE:
	
	lw	r2, r14, 0		; delimiter
	jal	r15, _parse
	sw	r3, r14, 0		; addr
	
	 dec	r14
	 sw	r2, r14, 0	
				; length
	
	 j	_NEXT
	
	; TODO enable different buffers
_parse:
	lw	r4, zero, var_NUMBER_TIB ; size of buffer
	lw	r3, zero, var_TO_IN	; get current index into buffer
	move	r6, r3			; save index
	li	r7, buffer		; load buffer address
	add	r7, r7, r3		; address of start of parsed string
	beq	r3, r4, _parse_empty

_parse_more:
	lw	r5, r3, buffer		; load char at buffer index
	inc	r3			; incr index
	beq	r5, r2, _parse_done	; char equals to delimiter?
	bne	r3, r4, _parse_more	; compare index to buffer size

	sw	r3, zero, var_TO_IN	; save index
	j	_parse0
_parse_done:
	sw	r3, zero, var_TO_IN	; save index
	dec	r3
_parse0:
	sub	r2, r3, r6		; length of parsed string
	move	r3, r7
;	li	r7, buffer
;	add	r3, r7, r6		; address of start of parsed string
	jr	r15	

_parse_empty:
	clear	r2
	li	r3, buffer
	add	r3, r3, r4
	jr	r15



	
	.align
name_EXECUTE:
	.word	name_PARSE
		.word	0
	.word	0x0007
	.string "execute"
	.align
EXECUTE:
	.word	code_EXECUTE
	.align
code_EXECUTE:
	
	
	 lw	r11, r14, 0	
	 inc	r14
	
	lw	r12, r11, 0
	jr	r12


	
	.align
name_FETCH_EXECUTE:
	.word	name_EXECUTE
		.word	0
	.word	0x0008
	.string "@execute"
	.align
FETCH_EXECUTE:
	.word	code_FETCH_EXECUTE
	.align
code_FETCH_EXECUTE:
	
	
	 lw	r2, r14, 0	
	 inc	r14
	
	lw	r3, r2, 0
	beq	r3, zero, exec_skip
	jr	r3
exec_skip:
	
	 j	_NEXT
	


	
	.align
name_BRANCH:
	.word	name_FETCH_EXECUTE
		.word	0
	.word	0x0006
	.string "branch"
	.align
BRANCH:
	.word	code_BRANCH
	.align
code_BRANCH:
	
	lw	r2, r10, 0
	add	r10, r10, r2
	
	 j	_NEXT
		


	
	.align
name_ZBRANCH:
	.word	name_BRANCH
		.word	0
	.word	0x0007
	.string "0branch"
	.align
ZBRANCH:
	.word	code_ZBRANCH
	.align
code_ZBRANCH:
	
	
	 lw	r2, r14, 0	
	 inc	r14
	
	beq	r2, zero, code_BRANCH
	inc	r10
	
	 j	_NEXT
	


	.set minus,0x2d
	.set ascii_zero,0x30
	.set ascii_a_0,0x31

	
	.align
name_NUMBER:
	.word	name_ZBRANCH
		.word	0
	.word	0x0006
	.string "number"
	.align
NUMBER:
	.word	code_NUMBER
	.align
code_NUMBER:
	
	lw	r2, r14, 0		; length of string
	lw	r3, r14, 1		; address of string
	jal	r15, _number
	sw	r3, r14, 0		; count of parsed chars, 0 = success
	sw	r2, r14, 1		; parsed number
	
	 j	_NEXT
	
_number:
	clear	r7			; clear parsed number
	clear	r8			; count of chars processed
	li	r9, 0x9			; store a 9 for future comparison

	clear	r12			; clear negative flag
	li	r6, minus		; load ascii minus
	lw	r4, r3, 0		; get first char
	bne	r4, r6, _pos		; is first char ascii minus sign?
	not	r12			; set negative flag

	inc	r8			; update counts and pointers
	inc	r3			
	dec	r2
	beq	r2, zero, _num_fail	; contunue?

_pos:
	lw	r6, zero, var_BASE	; get number base
_num0:
	lw	r4, r3, 0		; get next character

	;subi	r3, r3, ascii_zero
	addi	r4, r4, 0xffd0		; subtract ascii zero char
	blt	r4, zero, _num_fail	; finish if < 0
	ble	r4, r9, _num1		; skip if <= 9

	;subi	r3, r3, ascii_a_0
	addi	r4, r4, 0xffcf		; substract difference between ascii a and 0
	blt	r4, zero, _num_fail	; finish if < 0

	addi	r4, r4, 0xa		; add 10

_num1:
	bge	r4, r6, _num_fail	; finish if >= base

	mult	r7, r7, r6		; multiple current number by base
	add	r7, r7, r4		; add new digit

_over:
	inc	r8			; update counters and pointers
	inc	r3
	dec	r2
	bne	r2, zero, _num0		; repeat if still got digits to process

_num_fail:
	beq	r12, zero, _not_neg	; negative flag set?

	not	r7			; negate number
	inc	r7
_not_neg:
	move	r2, r7
	move	r3, r8
	jr	r15
	


	
	.align
name_QUIT:
	.word	name_NUMBER
		.word	0
	.word	0x0004
	.string "quit"
	.align
QUIT:
	.word	DOCOL
	.align
	
	.word	LIT, buffer, DUPE, LIT, 0x0ff, ACCEPT, SPACE, TYPE, CR, BRANCH, -0xa, EXIT
	



;hex
;0xf002 constant rand
;0xfffe constant screen

; : randchar rand @ 0x1f and 0x20 + ;

; : randchars begin pad dup 0xa + do randchar i ! loop pad 0xa type again ;

	
	.align
name_AND:
	.word	name_QUIT
		.word	0
	.word	0x0003
	.string "and"
	.align
AND:
	.word	code_AND
	.align
code_AND:
	
	lw	r2, r14, 0
	lw	r3, r14, 1
	and	r2, r2, r3
	inc	r14
	sw	r2, r14, 0
	
	 j	_NEXT
	

	
	
	.align
name_RAND:
	.word	name_AND
		.word	0
	.word	0x0004
	.string "rand"
	.align
RAND:
	.word	code_RAND
	.align
code_RAND:
	
	li	r2, random
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	
	
	
	
	.align
name_CHAROUT:
	.word	name_RAND
		.word	0
	.word	0x0007
	.string "charout"
	.align
CHAROUT:
	.word	code_CHAROUT
	.align
code_CHAROUT:
	
	li	r2, charout
	
	 dec	r14
	 sw	r2, r14, 0	
	
	
	 j	_NEXT
	
	


	
	.align
name_RANDCHAR:
	.word	name_CHAROUT
		.word	0
	.word	0x0008
	.string "randchar"
	.align
RANDCHAR:
	.word	DOCOL
	.align
	
	.word	RAND, FETCH, LIT, 0x1f, AND, LIT, 0x20, PLUS, EXIT

	
	.align
name_RANDCHARS:
	.word	name_RANDCHAR
		.word	0
	.word	0x0009
	.string "randchars"
	.align
RANDCHARS:
	.word	DOCOL
	.align
	
	.word	RANDCHAR, EMIT, BRANCH, -0x3, EXIT

	
	.align
name_RC:
	.word	name_RANDCHARS
		.word	0
	.word	0x0002
	.string "rc"
	.align
RC:
	.word	code_RC
	.align
code_RC:
	
loop:
	lw	r2, zero, random ; get random num
	andi	r3, r2, 0x1f
	addi	r3, r3, 0x20
	sw	r3, zero, charout ; write random character
	j	loop
	
	 j	_NEXT
	

; : sum100 0 101 0 do i + loop ;
; 13ba
	
	.align
name_SUM100:
	.word	name_RC
		.word	0
	.word	0x0006
	.string "sum100"
	.align
SUM100:
	.word	DOCOL
	.align
	
	.word	LIT, 0, LIT, 0x64, DUPE, TO_R, PLUS, FROM_R, ONE_MINUS, DUPE, LIT, 0, EQUALS, ZBRANCH, -0xa, DROP, EXIT


	
	.align
name_FIND:
	.word	name_SUM100
		.word	0
	.word	0x0004
	.string "find"
	.align
FIND:
	.word	code_FIND
	.align
code_FIND:
	
	lw	r2, r14, 0	; length
	lw	r3, r14, 1	; string address
	jal	r15, _find
	inc	r14
	sw	r2, r14, 0
	
	 j	_NEXT
	
_find:
	lw	r6, zero, var_LATEST	; address of latest word

_find_search:

;li	r1, 0x2a
;sw	r1, zero, charout

	lw	r4, r6, 1		; get flags
	andi	r4, r4, f_hidden
	bne	r4, zero, _find_next	; skip if hidden

	lw	r4, r6, 2		; get name length
	bne	r4, r2, _find_next	; next if lengths don't match
	addi	r5, r6, 3		; get name address
	move	r8, r3			; addr of word to find
_find_cmp:
	lw	r1, r5, 0		; get dict char
	lw	r7, r8, 0		; get search char
	bne	r1, r7, _find_next	; skip if not equal
	inc	r5			; bump word pointers
	inc	r8
	dec	r4			; decr length
	bne	r4, zero, _find_cmp	; continue if more chars to compare
	
	; found word here
	move	r2, r6			; return dict word addr
	jr	r15

_find_next:

	lw	r6, r6, 0		; get link
	bne	r6, zero, _find_search	; done if link zero
	clear	r2			; return zero, word not found
	jr	r15


	

	

	

	
	.align
name_TO_CFA:
	.word	name_FIND
		.word	0
	.word	0x0004
	.string ">cfa"
	.align
TO_CFA:
	.word	code_TO_CFA
	.align
code_TO_CFA:
	
	lw	r2, r14, 0		; dictionary address
	
		lw	r1, r2, 2		; get length
		addi	r2, r2, 3		; get addr of name
		add	r2, r2, r1		; add length
		
		inc	r2
		andi	r2, r2, 0xfffe
	
	
	sw	r2, r14, 0		; cfa addr on stack
	
	 j	_NEXT
	


	
	.align
name_TO_DFA:
	.word	name_TO_CFA
		.word	0
	.word	0x0004
	.string ">dfa"
	.align
TO_DFA:
	.word	code_TO_DFA
	.align
code_TO_DFA:
	
	lw	r2, r14, 0
	
		
		lw	r1, r2, 2		; get length
		addi	r2, r2, 3		; get addr of name
		add	r2, r2, r1		; add length
		
		inc	r2
		andi	r2, r2, 0xfffe
	
	
		
		inc	r2
		
		inc	r2
		andi	r2, r2, 0xfffe
	
	
	
	sw	r2, r14, 0
	
	 j	_NEXT
	


	
	.align
name_INTERPRET:
	.word	name_TO_DFA
		.word	0
	.word	0x0009
	.string "interpret"
	.align
INTERPRET:
	.word	DOCOL
	.align
	
	.word	NUMBER_TIB, FETCH, TO_IN, FETCH, EQUALS, ZBRANCH, 0x11
	.word	LIT, ok_msg, LIT, 3, TYPE, CR
	.word	TIB, LIT, 0x0ff, ACCEPT, NUMBER_TIB, STORE, LIT, 0, TO_IN, STORE
	.word	BL, PARSE, TWO_DUPE, FIND, QUESTION_DUPE, ZBRANCH, 0x8
	.word	NIP, NIP, SPACE, TO_CFA, EXECUTE, BRANCH, 0xb
	.word	NUMBER, ZERO_EQUALS, ZBRANCH, 0x7
	.word	LIT, err_msg, LIT, 4, TYPE, CR
	.word	BRANCH, -0x30
	.word	EXIT
ok_msg:
	.string	" ok"
err_msg:
	.string	" err"



	
	.align
name_U_DOT:
	.word	name_INTERPRET
		.word	0
	.word	0x0002
	.string "u."
	.align
U_DOT:
	.word	code_U_DOT
	.align
code_U_DOT:
	
	lw	r2, r14, 0
	inc	r14
	jal	r15, _udot
	
	 j	_NEXT
	
_udot:
	lw      r3, zero, var_BASE
	li	r4, _udot_buf
	li	r5, 0xa
_udot_rep:
	dec	r4
	div     r2, r3
	mflo    r2
	mfhi    r6

	blt	r6, r5, _udot_lt_10	; less than 10?

	addi	r6, r6, 0x57		; add -10 + 'a'
	sw	r6, r4, 0
	bne	r2, zero, _udot_rep
	j	_udot_out

_udot_lt_10:
	addi	r6, r6, 0x30
	sw	r6, r4, 0
	bne	r2, zero, _udot_rep

_udot_out:
	lw	r6, r4, 0
	beq	r6, zero, _udot_done
	sw	r6, zero, charout
	inc	r4
	j	_udot_out
_udot_done:
	jr	r15

	.word      0,0,0,0,0,0,0,0
	.word      0,0,0,0,0,0,0,0
	.word      0,0,0,0,0,0,0,0
	.word      0,0,0,0,0,0,0,0
	.word      0,0,0,0,0,0,0,0
	.word      0,0,0,0,0,0,0,0
_udot_buf:
	.word	0


	
	.align
name_DOT:
	.word	name_U_DOT
		.word	0
	.word	0x0001
	.string "."
	.align
DOT:
	.word	code_DOT
	.align
code_DOT:
	
	lw	r2, r14, 0
	inc	r14
	jal	r15, _dot
	
	 j	_NEXT
	
_dot:
	bge	r2, zero, _dot_pos
	li	r1, minus
	sw	r1, zero, charout
	neg	r2
_dot_pos:
	j	_udot



	
	.align
name_CREATE:
	.word	name_DOT
		.word	0
	.word	0x0006
	.string "create"
	.align
CREATE:
	.word	code_CREATE
	.align
code_CREATE:
	
	jal	r15, _create
	
	 j	_NEXT
	
_create:
	move	r9, r15		; save return address
	li	r2, blank
	jal	r15, _parse

	lw	r4, zero, var_HERE
;	inc	r4
;	andi	r4, r4, 0xfffe	; align data pointer

	lw	r1, zero, var_LATEST
	sw	r1, r4, 0	; store link

;	clear	r1
	sw	zero, r4, 1	; store flags
	sw	r2, r4, 2	; store len
	addi	r4, r4, 3	; address of dict name
_create0:
	lw	r1, r3, 0	; get name char
	sw	r1, r4, 0	; store name char
	inc	r4		; bump pointers
	inc	r3
	dec	r2		; decr char count
	bne	r2, zero, _create0	; keep copying until done

	
		inc	r4
		andi	r4, r4, 0xfffe
	
;	inc	r4
;	andi	r4, r4, 0xfffe	; align cfa field
				; r4 = cfa addr
	li	r1, _create_xt
	sw	r1, r4, 0	; store create xt in cfa

	inc	r4		; align
	
		inc	r4
		andi	r4, r4, 0xfffe
	
;	andi	r4, r4, 0xfffe 	; r4 = dfa

	lw	r1, zero, var_HERE
	sw	r1, zero, var_LATEST
	sw	r4, zero, var_HERE

	jr	r9

_create_xt:
	move	r1, r11
	inc	r1
	
	 dec	r14
	 sw	r1, r14, 0	
		
	
	 j	_NEXT
	


	
	.align
name_COMMA:
	.word	name_CREATE
		.word	0
	.word	0x0001
	.string ","
	.align
COMMA:
	.word	code_COMMA
	.align
code_COMMA:
	
	
	 lw	r2, r14, 0	
	 inc	r14
	
	lw	r3, zero, var_HERE
	sw	r2, r3, 0
	inc	r3
	sw	r3, zero, var_HERE
	
	 j	_NEXT
	


	
	.align
name_LBRAC:
	.word	name_COMMA
		.word	f_immediate
	.word	0x0001
	.string "["
	.align
LBRAC:
	.word	code_LBRAC
	.align
code_LBRAC:
	
	clear	r2
	sw	r2, zero, var_STATE
	
	 j	_NEXT
	
	
	
	.align
name_RBRAC:
	.word	name_LBRAC
		.word	0
	.word	0x0001
	.string "]"
	.align
RBRAC:
	.word	code_RBRAC
	.align
code_RBRAC:
	
	li	r2, 0xffff
	sw	r2, zero, var_STATE
	
	 j	_NEXT
	


	
	.align
name_IMMEDIATE:
	.word	name_RBRAC
		.word	0
	.word	0x0009
	.string "immediate"
	.align
IMMEDIATE:
	.word	code_IMMEDIATE
	.align
code_IMMEDIATE:
	
	lw	r2, zero, var_LATEST	; get latest word
	inc	r2			; flags addr
	lw	r3, r2, 0		; get flags
	li	r4, f_immediate		; immediate bit
	xor	r3, r3, r4		; toggle
	sw	r3, r2, 0		; store it
	
	 j	_NEXT
	

	
	.align
name_HIDDEN:
	.word	name_IMMEDIATE
		.word	0
	.word	0x0006
	.string "hidden"
	.align
HIDDEN:
	.word	code_HIDDEN
	.align
code_HIDDEN:
	
	
	 lw	r2, r14, 0	
	 inc	r14
				; dict header addr from stack
	inc	r2			; flags addr
	lw	r3, r2, 0		; get flags
	li	r4, f_hidden		; hidden bit
	xor	r3, r3, r4		; toggle
	sw	r3, r2, 0		; store it
	
	 j	_NEXT
	

	
	.align
name_HIDE:
	.word	name_HIDDEN
		.word	0
	.word	0x0004
	.string "hide"
	.align
HIDE:
	.word	DOCOL
	.align
	
	.word	BL, PARSE, FIND, HIDDEN, EXIT


	
	.align
name_TICK:
	.word	name_HIDE
		.word	0
	.word	0x0001
	.string "'"
	.align
TICK:
	.word	DOCOL
	.align
	
	.word	BL, PARSE, FIND, TO_CFA, EXIT

	
	.align
name_TEST_UDOT:
	.word	name_TICK
		.word	0
	.word	0x0009
	.string "test-udot"
	.align
TEST_UDOT:
	.word	DOCOL
	.align
	
	.word	LIT, 0x141, U_DOT, CR
	.word	HEX
	.word	LIT, 0xcafe, U_DOT, CR
	.word	BINARY
	.word	LIT, 0xbabe, U_DOT, CR
	.word	DECIMAL
	.word	LIT, 0x293a, DOT, CR
	.word	LIT, -0x141, DOT, CR
	.word	EXIT

	
	.align
name_LAST_WORD:
	.word	name_TEST_UDOT
		.word	0
	.word	0x0009
	.string "last_word"
	.align
LAST_WORD:
	.word	DOCOL
	.align
	
	.word	EXIT
	
	.align
start_dp:


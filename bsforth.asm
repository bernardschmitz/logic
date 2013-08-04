
	changecom
	changequote`'changequote(`{',`}')dnl

	.set	_timerlo,0xf000
	.set	_timerhi,0xf001
	.set	_random,0xf002
	.set	_bufferclr,0xfffb
	.set	_charrdy,0xfffc
	.set	_charin,0xfffd
	.set	_charout,0xfffe
	.set	_screenclr,0xffff

	.set	f_immediate,0x8000
	.set	f_hidden,0x0001

	.set	data_stack,0x8000
	.set	return_stack,0x9000
	.set	buffer,0xa000
	.set	top, 0x8000

        define(id, 0)dnl
        define(l, {$1{}id})dnl
	define(nl, {define({id}, incr(id))})dnl

	define(LINK, 0)dnl


; i r10
; w r11
; x r12
; rsp r13
; dsp r14

	define(NEXT, {
	 j	_NEXT
	})dnl


	define(PUSHRSP, {
	 dec	r13
	 sw	$1, r13, 0	
	})dnl

	define(POPRSP, {
	 lw	$1, r13, 0	
	 inc	r13
	})dnl

	define(PUSHDSP, {
	 dec	r14
	 sw	$1, r14, 0	
	})dnl

	define(POPDSP, {
	 lw	$1, r14, 0	
	 inc	r14
	})dnl

	define(ALIGN, {
		inc	$1
		andi	$1, $1, 0xfffe
	})dnl

	j	start

;	.org	0x10
	.align
DOCOL:
	PUSHRSP(r10)
	;inc	r11
	;move	r10, r11
	lw	r10, r11, 1
_NEXT:
	lw	r11, r10, 0
	inc	r10
_RUN:
	lw	r12, r11, 0
	jr	r12


	define(DEFWORD, {
;	.align
name_$3:
	.word	LINK
	define({LINK}, name_$3)dnl
	.word	$2
	.word	{0x}format({%04x}, len({$1}))
	.string "$1"
	.word	LINK
;	.align
$3:
	.word	DOCOL
	.word	$+1
;	.align
	})dnl


	define(DEFCODE, {
;	.align
name_$3:
	.word	LINK
	define({LINK}, name_$3)dnl
	.word	$2
	.word	{0x}format({%04x}, len({$1}))
	.string "$1"
	.word	LINK
;	.align
$3:
	.word	code_$3
	.align
code_$3:
	})dnl



	.align
start:

	li	r13, return_stack
	li	r14, data_stack
	li	r10, _boot
	NEXT
_boot:	.word	BOOT


	DEFCODE(halt, 0, HALT)
	halt

	DEFCODE(brk, 0, BRK)
	brk
	NEXT

	DEFCODE(sp@, 0, SPFETCH)
	move	r1, r14
	PUSHDSP(r1)
	NEXT

	DEFCODE(sp!, 0, SPSTORE)
	lw	r1, r14, 0
	move	r14, r1
	NEXT


	DEFCODE(drop, 0, DROP)
	inc	r14
	NEXT

	DEFCODE(nip, 0, NIP)
	; swap, drop
	lw	r2, r14, 0
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(tuck, 0, TUCK)
	; swap over
	lw	r2, r14, 0
	lw	r3, r14, 1

	sw	r3, r14, 0
	sw	r2, r14, 1

	lw	r2, r14, 1
	PUSHDSP(r2)
	NEXT


	DEFCODE(swap, 0, SWAP)
	lw	r2, r14, 0
	lw	r3, r14, 1

	sw	r3, r14, 0
	sw	r2, r14, 1
	NEXT

	DEFCODE(dup, 0, DUPE)
	lw	r2, r14, 0
	PUSHDSP(r2)
	NEXT

	DEFCODE(over, 0, OVER)
	lw	r2, r14, 1
	PUSHDSP(r2)
	NEXT

	DEFCODE(rot, 0, ROT)
	lw	r2, r14, 0
	lw	r3, r14, 1
	lw	r4, r14, 2

	sw	r3, r14, 2	
	sw	r2, r14, 1
	sw	r4, r14, 0
	NEXT

	DEFCODE(-rot, 0, MINUS_ROT)
	lw	r2, r14, 0
	lw	r3, r14, 1
	lw	r4, r14, 2

	sw	r2, r14, 2	
	sw	r4, r14, 1
	sw	r3, r14, 0
	NEXT

	DEFCODE(pick, 0, PICK)
	lw	r2, r14, 0
	inc	r2
	add	r2, r2, r14
	lw	r2, r2, 0
	sw	r2, r14, 0
	NEXT

	DEFCODE(roll, 0, ROLL)
	POPDSP(r2)
	add	r3, r14, r2	; stack address of new tos
	lw	r5, r3, 0	; save tos
roll_more:
	beq	r3, r14, roll_done
	lw	r6, r3, -1
	sw	r6, r3, 0
	dec	r3
	j	roll_more
roll_done:
	sw	r5, r14, 0
	NEXT

	DEFCODE(2drop, 0, TWO_DROP)
	addi	r14, r14, 2
	NEXT

	DEFCODE(2dup, 0, TWO_DUPE)
	lw	r2, r14, 0
	lw	r3, r14, 1
	addi	r14, r14, -2
	sw	r2, r14, 0
	sw	r3, r14, 1
	NEXT

	DEFCODE(2swap, 0, TWO_SWAP)
	lw	r2, r14, 0
	lw	r3, r14, 1
	lw	r4, r14, 2
	lw	r5, r14, 3

	sw	r4, r14, 0
	sw	r5, r14, 1
	sw	r2, r14, 2
	sw	r3, r14, 3
	NEXT

	DEFCODE(?dup, 0, QUESTION_DUPE)
	lw	r2, r14, 0
	beq	r2, zero, qdup0
	PUSHDSP(r2)
qdup0:
	NEXT

	DEFCODE(1+, 0, ONE_PLUS)
	lw	r2, r14, 0
	inc	r2
	sw	r2, r14, 0
	NEXT

	DEFCODE(1-, 0, ONE_MINUS)
	lw	r2, r14, 0
	dec	r2
	sw	r2, r14, 0
	NEXT

	DEFCODE(+, 0, PLUS)
	lw	r2, r14, 0
	lw	r3, r14, 1
	add	r2, r2, r3
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(-, 0, MINUS)
	lw	r2, r14, 0
	lw	r3, r14, 1
	sub	r2, r3, r2
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(*, 0, STAR)
	lw	r2, r14, 0
	lw	r3, r14, 1
	mult	r2, r2, r3
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(/, 0, SLASH)
	lw	r2, r14, 0
	lw	r3, r14, 1
	divd	r2, r3, r2
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(/mod, 0, SLASH_MOD)
	lw	r2, r14, 0
	lw	r3, r14, 1
	divd	r2, r3, r2
	sw	r2, r14, 0
	mfhi	r3
	sw	r3, r14, 1
	NEXT

	DEFCODE(invert, 0, INVERT)
	lw	r2, r14, 0
	not	r2
	sw	r2, r14, 0
	NEXT

	DEFCODE(negate, 0, NEGATE)
	lw	r2, r14, 0
	neg	r2
	sw	r2, r14, 0
	NEXT

	DEFCODE(2*, 0, TWO_STAR)
	lw	r2, r14, 0
	sll	r2, r2, 1
	sw	r2, r14, 0
	NEXT

	DEFCODE(2/, 0, TWO_SLASH)
	lw	r2, r14, 0
	sra	r2, r2, 1
	sw	r2, r14, 0
	NEXT
	
	DEFCODE(lshift, 0, LSHIFT)
	lw	r2, r14, 0
	lw	r3, r14, 1
	sllv	r3, r3, r2
	inc	r14
	sw	r3, r14, 0
	NEXT

	DEFCODE(rshift, 0, RSHIFT)
	lw	r2, r14, 0
	lw	r3, r14, 1
	srlv	r3, r3, r2
	inc	r14
	sw	r3, r14, 0
	NEXT

	DEFCODE(arshift, 0, ARSHIFT)
	lw	r2, r14, 0
	lw	r3, r14, 1
	srav	r3, r3, r2
	inc	r14
	sw	r3, r14, 0
	NEXT

	DEFCODE(=, 0, EQUALS)
	lw	r3, r14, 0
	lw	r4, r14, 1
	li	r2, 0xffff
	beq	r3, r4, equals0
	clear	r2
equals0:
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(<>, 0, NOT_EQUALS)
	lw	r3, r14, 0
	lw	r4, r14, 1
	li	r2, 0xffff
	bne	r3, r4, nequals0
	clear	r2
nequals0:
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(<, 0, LESS_THAN)
	lw	r3, r14, 0
	lw	r4, r14, 1
	li	r2, 0xffff
	blt	r4, r3, lt0
	clear	r2
lt0:
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(>, 0, GREATER_THAN)
	lw	r3, r14, 0
	lw	r4, r14, 1
	li	r2, 0xffff
	bgt	r4, r3, gt0
	clear	r2
gt0:
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(<=, 0, LESS_THAN_EQUALS)
	lw	r3, r14, 0
	lw	r4, r14, 1
	li	r2, 0xffff
	ble	r4, r3, le0
	clear	r2
le0:
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(>=, 0, GREATER_THAN_EQUALS)
	lw	r3, r14, 0
	lw	r4, r14, 1
	li	r2, 0xffff
	bge	r4, r3, ge0
	clear	r2
ge0:
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(0=, 0, ZERO_EQUALS)
	lw	r3, r14, 0
	li	r2, 0xffff
	beq	r3, zero, zeq0
	clear	r2
zeq0:
	sw	r2, r14, 0
	NEXT

	DEFCODE(0<>, 0, ZERO_NOT_EQUALS)
	lw	r3, r14, 0
	li	r2, 0xffff
	bne	r3, zero, zneq0
	clear	r2
zneq0:
	sw	r2, r14, 0
	NEXT

	DEFCODE(0<, 0, ZERO_LESS_THAN)
	lw	r3, r14, 0
	li	r2, 0xffff
	blt	r3, zero, ltz0
	clear	r2
ltz0:
	sw	r2, r14, 0
	NEXT

	DEFCODE(0>, 0, ZERO_GREATER_THAN)
	lw	r3, r14, 0
	li	r2, 0xffff
	bgt	r3, zero, gtz0
	clear	r2
gtz0:
	sw	r2, r14, 0
	NEXT

	DEFCODE(0<=, 0, ZERO_LESS_THAN_EQUALS)
	lw	r3, r14, 0
	li	r2, 0xffff
	ble	r3, zero, lez0
	clear	r2
lez0:
	sw	r2, r14, 0
	NEXT

	DEFCODE(0>=, 0, ZERO_GREATER_THAN_EQUALS)
	lw	r3, r14, 0
	li	r2, 0xffff
	bge	r3, zero, gez0
	clear	r2
gez0:
	sw	r2, r14, 0
	NEXT

	DEFCODE(min, 0, MIN)
	lw	r2, r14, 0
	lw	r3, r14, 1
	blt	r2, r3, min0
	move	r2, r3
min0:
	inc	r14
	sw	r2, r14, 0
	NEXT	

	DEFCODE(max, 0, MAX)
	lw	r2, r14, 0
	lw	r3, r14, 1
	bgt	r2, r3, max0
	move	r2, r3
max0:
	inc	r14
	sw	r2, r14, 0
	NEXT	


	DEFCODE(exit, 0, EXIT)
	POPRSP(r10)
	NEXT

	DEFCODE(lit, 0, LIT)
	lw	r2, r10, 0
	inc	r10
	PUSHDSP(r2)
	NEXT

	DEFCODE(!, 0, STORE)
	lw	r2, r14, 0
	lw	r3, r14, 1
	sw	r3, r2, 0
	addi	r14, r14, 2
	NEXT

	DEFCODE(@, 0, FETCH)
	lw	r2, r14, 0
	lw	r2, r2, 0
	sw	r2, r14, 0
	NEXT

	DEFCODE(+!, 0, PLUS_STORE)
	lw	r2, r14, 0
	lw	r3, r14, 1
	lw	r4, r2, 0
	add	r4, r4, r3
	sw	r4, r2, 0
	addi	r14, r14, 2
	NEXT

	DEFCODE(-!, 0, MINUS_STORE)
	lw	r2, r14, 0
	lw	r3, r14, 1
	lw	r4, r2, 0
	sub	r4, r4, r3
	sw	r4, r2, 0
	addi	r14, r14, 2
	NEXT


	define(DEFVAR, {
	DEFCODE($1, $2, $3)
	li	r2, var_$3
	PUSHDSP(r2)
	NEXT
var_$3:	.word	$4
	})dnl


	DEFVAR(state, 0, STATE, 0)
	DEFVAR(dp, 0, DP, start_dp)
	DEFVAR(latest, 0, LATEST, name_BOOT)
	DEFVAR(base, 0, BASE, 0xa)

	DEFVAR(>in, 0, TO_IN, 0)
	DEFVAR(#tib, 0, NUMBER_TIB, 0)
	DEFVAR(source-id, 0, SOURCE_ID, 0)
	DEFVAR(buf, 0, BUF, buffer)


	DEFCODE(tib, 0, TIB)
	lw	r2, zero, var_BUF
	PUSHDSP(r2)
	NEXT


	DEFCODE(here, 0, HERE)
	lw	r2, zero, var_DP
	PUSHDSP(r2)
	NEXT



	define(DEFCONST, {
	DEFCODE($1, $2, $3)
	li	r2, $4
	PUSHDSP(r2)
	NEXT
	})dnl

	DEFCONST(version, 0, VERSION, 1)
	DEFCONST(r0, 0, RZ, return_stack)
	DEFCONST(sp0, 0, SPZ, data_stack)
	DEFCONST(_docol, 0, _DOCOL, DOCOL)

	DEFCONST(top, 0, TOP, top)

	DEFCONST(zero, 0, ZERO, 0)
	DEFCONST(false, 0, FALSE, 0)
	DEFCONST(true, 0, TRUE, 0xffff)

	DEFCONST(timerlo, 0, TIMERLO, _timerlo)
	DEFCONST(timerhi, 0, TIMERHI, _timerhi)

	.set	blank,0x20

	DEFCONST(bl, 0, BL, blank)

	DEFCODE(space, 0, SPACE)
	li	r2, blank
	sw	r2, zero, _charout
	NEXT

	DEFCODE(spaces, 0, SPACES)
	; 0 ?do space loop
	POPDSP(r2)
	beq	r2, zero, spaces0
	li	r3, blank
spaces1:
	sw	r3, zero, _charout
	dec	r2
	bne	r2, zero, spaces1
spaces0:	
	NEXT


	DEFCODE(cr, 0, CR)
	li	r2, newline
	sw	r2, zero, _charout
	NEXT

	DEFCODE(>r, 0, TO_R)
	POPDSP(r2)
	PUSHRSP(r2)
	NEXT

	DEFCODE(r>, 0, FROM_R)
	POPRSP(r2)
	PUSHDSP(r2)
	NEXT

	DEFCODE(r@, 0, R_FETCH)
	lw	r2, r13, 0
	PUSHDSP(r2)
	NEXT

	DEFCODE(2>r, 0, TWO_TO_R)
	lw	r2, r14, 0
	lw	r3, r14, 1
	addi	r14, r14, 2
	addi	r13, r13, -2
	sw	r2, r13, 0
	sw	r3, r13, 1
	NEXT

	DEFCODE(2r>, 0, TWO_FROM_R)
	lw	r2, r13, 0
	lw	r3, r13, 1
	addi	r13, r13, 2
	addi	r14, r14, -2
	sw	r2, r14, 0
	sw	r3, r14, 1
	NEXT

	DEFCODE(2r@, 0, TWO_R_FETCH)
	lw	r2, r13, 0
	lw	r3, r13, 1
	addi	r14, r14, -2
	sw	r2, r14, 0
	sw	r3, r14, 1
	NEXT

	DEFCODE(rsp@, 0, RSPFETCH)
	PUSHDSP(r13)	
	NEXT

	DEFCODE(rsp!, 0, RSPSTORE)
	POPDSP(r13)	
	NEXT

	DEFCODE(rdrop, 0, RDROP)
	inc	r13
	NEXT

	DEFCODE(within, 0, WITHIN)
	lw	r2, r14, 2
	lw	r3, r14, 1
	lw	r4, r14, 0
	addi	r14, r14, 2
	blt	r2, r3, within0
	bge	r2, r4, within0
	li	r5, 0xffff
	sw	r5, r14, 0	
	NEXT
within0:
	clear	r5
	sw	r5, r14, 0	
	NEXT


	DEFCODE(cmove, 0, CMOVE)
	lw	r2, r14, 0	; count
	lw	r3, r14, 1	; dest
	lw	r4, r14, 2	; src
	addi	r14, r14, 3
cmove0:
	lw	r1, r4, 0
	sw	r1, r3, 0
	inc	r4
	inc	r3
	dec	r2
	bne	r2, zero, cmove0
	NEXT

	DEFCODE(cmove>, 0, CMOVE_UP)
	lw	r2, r14, 0	; count
	lw	r3, r14, 1	; dest
	lw	r4, r14, 2	; src
	addi	r14, r14, 3
	add	r3, r3, r2
	add	r4, r4, r2
cmoveup0:
	dec	r4
	dec	r3
	lw	r1, r4, 0
	sw	r1, r3, 0
	dec	r2
	bne	r2, zero, cmoveup0
	NEXT

	DEFWORD({move}, 0, MOVE)
	; >r 2dup swap dup r@ + within r> swap if cmove> else cmove then
	.word	TO_R, TWO_DUPE, SWAP, DUPE, R_FETCH, PLUS, WITHIN, FROM_R, SWAP
	.word	ZBRANCH, 4, CMOVE_UP, BRANCH, 2, CMOVE, EXIT


	DEFCODE(fill, 0, FILL)
	lw	r2, r14, 0	; fill
	lw	r3, r14, 1	; count
	lw	r4, r14, 2	; dest
	addi	r14, r14, 3
fill0:
	sw	r2, r4, 0
	inc	r4
	dec	r3
	bne	r3, zero, fill0
	NEXT

	DEFWORD(erase, 0, ERASE)
	.word	ZERO, FILL, EXIT

	DEFWORD(blank, 0, BLANK)
	.word	BL, FILL, EXIT

	DEFWORD(pad, 0, PAD)
	.word	HERE, LIT, 0xff, PLUS, EXIT

	DEFCODE(key?, 0, KEY_QUESTION)
	clear	r2
	lw	r3, zero, _charrdy
	beq	r3, zero, _keyq0
	not	r2
_keyq0:
	PUSHDSP(r2)
	NEXT


	DEFCODE(key, 0, KEY)
	jal	r15, _key
	PUSHDSP(r2)
	NEXT
_key:
	lw	r2, zero, _charrdy
	beq	r2, zero, _key
	lw	r2, zero, _charin
	jr	r15


	DEFCODE(emit, 0, EMIT)
	POPDSP(r2)
	sw	r2, zero, _charout
	NEXT

	.set delete,0x08
	.set newline,0x0a

	DEFCODE(accept, 0, ACCEPT)
	lw	r2, r14, 0		; max count
	lw	r3, r14, 1		; buffer address
	jal	r15, _accept
	inc	r14
	sw	r2, r14, 0		; count
	NEXT
_accept:
	move	r4, r2			; save max count
	clear	r5			; zero char count
	li	r6, newline		; eol char
	li	r7, delete		; bs char
_accept0:
	lw	r2, zero, _charrdy
	beq	r2, zero, _accept0
	lw	r2, zero, _charin

	beq	r2, r6, eol0		; is it eol char?
	beq	r2, r7, bs0		; is it bs char?
	beq	r4, zero, lim0		; have we reached the char limit?

dnl	sw	r2, zero, _charout	; output char
	sw	r2, r3, 0		; store char
	inc	r5			; count char
	inc	r3			; inc buffer address
	dec	r4			; decr max count
	j	_accept0		; get next char
lim0:
dnl	sw	r7, zero, _charout
dnl	sw	r2, zero, _charout	; output char
	sw	r2, r3, -1
	j	_accept0		; get next char
eol0:
	move	r2, r5			; save actual char count
	jr	r15			; return
bs0:
	beq	r5, zero, _accept0	; ignore bs if first key
dnl	sw	r7, zero, _charout
	dec	r5			; backspace buffer
	dec	r3
	inc	r4
	j	_accept0		; continue





	DEFCODE(type, 0, TYPE)
	lw	r2, r14, 0
	beq	r2, zero, _type1
	lw	r3, r14, 1
	jal	r15, _type
_type1:
	addi	r14, r14, 2
	NEXT
_type:
	lw	r4, r3, 0
	sw	r4, zero, _charout
	inc	r3
	dec	r2
	bne	r2, zero, _type
	jr	r15



	DEFCODE(parse, 0, PARSE)
	lw	r2, r14, 0		; delimiter
	jal	r15, _parse
	sw	r3, r14, 0		; addr
	PUSHDSP(r2)			; length
	NEXT

_parse:
	lw	r4, zero, var_NUMBER_TIB ; size of buffer
	lw	r3, zero, var_TO_IN	; get current index into buffer
	move	r6, r3			; save index
;	li	r7, buffer		; load buffer address
;	add	r7, r7, r3		; address of start of parsed string
	lw	r9, zero, var_BUF
	add	r9, r9, r3
	move	r8, r9
	move	r7, r9

	beq	r3, r4, _parse_empty

_parse_more:
;	lw	r5, r3, buffer		; load char at buffer index
	lw	r5, r8, 0
	inc	r8
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
	jr	r15	

_parse_empty:
	sw	r3, zero, var_TO_IN	; save index
	clear	r2
;	li	r3, buffer
	lw	r3, zero, var_BUF
	add	r3, r3, r4
	jr	r15


	DEFCODE(parse-word, 0, PARSE_WORD)
	jal	r15, _parse_word
	addi	r14, r14, -2
	sw	r3, r14, 1		; addr
	sw	r2, r14, 0
	NEXT

_parse_word:
	li	r2, blank		; delimiter
	lw	r4, zero, var_NUMBER_TIB ; size of buffer
	lw	r3, zero, var_TO_IN	; get current index into buffer
	lw	r9, zero, var_BUF
	add	r9, r9, r3
	move	r8, r9
	beq	r3, r4, _pw_empty

_pw_skip:
;	lw	r5, r3, buffer		; get char
	lw	r5, r8, 0
	inc	r8
	inc	r3			; bump index
	;bne	r5, r2, _pw_word	; found start of word
	bgt	r5, r2, _pw_word	; found start of word
	beq	r3, r4, _pw_empty
	j	_pw_skip

_pw_word:
	move	r7, r8
;	li	r7, buffer		; load buffer address
;	add	r7, r7, r3		; address of start of parsed string
	dec	r7
	addi	r6, r3, -1
	beq	r3, r4, _pw_done1

_pw_more:
;	lw	r5, r3, buffer		; get char
	lw	r5, r8, 0
	inc	r8
	inc	r3			; bump index
	;beq	r5, r2, _pw_done0	; char is a space, so done
	ble	r5, r2, _pw_done0	; char is a space, so done
	bne	r3, r4, _pw_more	; not at end of buffer, so continue

_pw_done1:
	sw	r3, zero, var_TO_IN	; save index
	j	_pw0
_pw_done0:
	sw	r3, zero, var_TO_IN	; save index
	dec	r3
_pw0:

	sub	r2, r3, r6		; count of chars
	move	r3, r7			; address of chars
	jr	r15

_pw_empty:
	sw	r3, zero, var_TO_IN	; save index
	clear	r2			; zero length
;	li	r3, buffer
	lw	r3, zero, var_BUF
	add	r3, r3, r4		; end address of the buffer
	jr	r15





	DEFCODE(execute, 0, EXECUTE)
	POPDSP(r11)
	lw	r12, r11, 0
	jr	r12


	DEFCODE(@execute, 0, FETCH_EXECUTE)
	POPDSP(r2)
	lw	r3, r2, 0
	beq	r3, zero, exec_skip
	jr	r3
exec_skip:
	NEXT


	DEFCODE(branch, 0, BRANCH)
	lw	r2, r10, 0
	add	r10, r10, r2
	NEXT	


	DEFCODE(0branch, 0, ZBRANCH)
	POPDSP(r2)
	beq	r2, zero, code_BRANCH
	inc	r10
	NEXT


	.set minus,0x2d
	.set ascii_zero,0x30
	.set ascii_a_0,0x31

	DEFCODE(number, 0, NUMBER)
	lw	r2, r14, 0		; length of string
	lw	r3, r14, 1		; address of string
	jal	r15, _number
	sw	r3, r14, 0		; count of chars remaining, 0 = success
	sw	r2, r14, 1		; parsed number
	NEXT
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

	addi	r4, r4, -ascii_zero	; subtract ascii zero char
	blt	r4, zero, _num_fail	; finish if < 0
	ble	r4, r9, _num1		; skip if <= 9

	addi	r4, r4, -ascii_a_0	; substract difference between ascii a and 0
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
	neg	r7			; negate number
_not_neg:
	move	r2, r7			; number parsed
	lw	r4, r14, 0		; length of string
	sub	r3, r4, r8		; number of chars remaining
	jr	r15
	

	DEFWORD(char, 0, CHAR)
	.word	PARSE_WORD, DROP, FETCH, EXIT

	DEFWORD({[char]}, f_immediate, BRACKET_CHAR)
	.word	CHAR, LIT, LIT, COMMA, COMMA, EXIT


	DEFCODE(and, 0, AND)
	lw	r2, r14, 0
	lw	r3, r14, 1
	and	r2, r2, r3
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(or, 0, OR)
	lw	r2, r14, 0
	lw	r3, r14, 1
	or	r2, r2, r3
	inc	r14
	sw	r2, r14, 0
	NEXT

	DEFCODE(xor, 0, XOR)
	lw	r2, r14, 0
	lw	r3, r14, 1
	xor	r2, r2, r3
	inc	r14
	sw	r2, r14, 0
	NEXT


	DEFCONST(rand, 0, RAND, _random)
	DEFCONST(charout, 0, CHAROUT, _charout)


	DEFWORD(randchar, 0, RANDCHAR)
	.word	RAND, FETCH, LIT, 0x1f, AND, LIT, 0x20, PLUS, EXIT


	DEFCODE(find, 0, FIND)
	lw	r2, r14, 0	; length
	lw	r3, r14, 1	; string address
	jal	r15, _find
	inc	r14
	sw	r2, r14, 0
	NEXT
_find:
	lw	r6, zero, var_LATEST	; address of latest word

_find_search:

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





	define(DICT2CFA, {
		lw	r1, $1, 2		; get length
		addi	$1, $1, 3		; get addr of name
		add	$1, $1, r1		; add length
		inc	$1			; skip back pointer
	})dnl


	define(CFA2DFA, {
		addi	$1, $1, 2
;;		inc	$1
		
	})dnl

	define(CFA2DICT, {
		lw	$1, $1, -1		; get dict addr from contents of cfa-1
	})dnl

	define(DFA2DICT, {
		lw	$1, $1, -3		; get dict addr from contents of dfa-3
	})dnl

	define(DICT2DFA, {
		DICT2CFA($1)
		CFA2DFA($1)
	})dnl

	
	DEFCODE(cfa>dict, 0, CFA_TO_DICT)
	lw	r2, r14, 0		; cfa
	CFA2DICT(r2)
	sw	r2, r14, 0
	NEXT

	DEFCODE(dfa>dict, 0, DFA_TO_DICT)
	lw	r2, r14, 0		; dfa
	DFA2DICT(r2)
	sw	r2, r14, 0
	NEXT


	DEFCODE(>cfa, 0, TO_CFA)
	lw	r2, r14, 0		; dictionary address
	DICT2CFA(r2)
	sw	r2, r14, 0		; cfa addr on stack
	NEXT


	DEFCODE(>dfa, 0, TO_DFA)
	lw	r2, r14, 0
	DICT2DFA(r2)
	sw	r2, r14, 0
	NEXT

	DEFWORD(?stack, 0, QUESTION_STACK)
;	.word	EXIT
	.word	SPFETCH, SPZ, GREATER_THAN, ZBRANCH, stack_ok-$
	.word	LIT, stack_msg0, LIT, stack_msg0_len, TYPE, CR, ABORT
stack_ok:
	.word	EXIT
stack_msg0:
	.string " stack underflow"
stack_msg1:
	.set	stack_msg0_len, stack_msg1 - stack_msg0




	DEFWORD(interpret, 0, INTERPRET)
int_begin:
	.word	NUMBER_TIB, FETCH, TO_IN, FETCH, NOT_EQUALS
	.word	ZBRANCH, int_done-$
	.word	PARSE_WORD, QUESTION_DUPE, ZBRANCH, int_zero_len-$
	.word	TWO_DUPE, FIND, QUESTION_DUPE
	.word	ZBRANCH, int_not_found-$
	.word	NIP, NIP
	.word	DUPE, QUESTION_IMMEDIATE, ZBRANCH, int_not_immed-$
	.word	TO_CFA, EXECUTE, QUESTION_STACK, BRANCH, int_then0-$
int_not_immed:
	.word	TO_CFA, STATE, FETCH
	.word	ZBRANCH, int_execute-$
	.word	COMMA
	.word	BRANCH, int_then0-$
int_execute:
	.word	EXECUTE, QUESTION_STACK
int_then0:
	.word	BRANCH, int_word_end-$
int_not_found:
	.word	TWO_DUPE, NUMBER
	.word	ZBRANCH, int_number-$
	.word	STATE, FETCH, ZBRANCH, int_err-$
	.word	LATEST, FETCH, DUPE, FETCH, LATEST, STORE, DP, STORE
int_err:
	.word	DROP, SPACE, LIT, 0x3e, EMIT, TYPE, LIT, err_msg, LIT, 3, TYPE
	.word	ABORT
int_number:
	.word	NIP, NIP, STATE, FETCH, ZBRANCH, int_not_literal-$
	.word	LITERAL
int_not_literal:
int_word_end:
	.word	BRANCH, int_begin-$
int_zero_len:
	.word	DROP
int_done:
	.word	EXIT
err_msg:
	.string "< ?"


	DEFWORD(abort, 0, ABORT)
	.word	SPZ, SPSTORE, ZERO, SOURCE_ID, STORE
	.word	LBRAC
	.word	LIT, abort_msg, LIT, 6, TYPE, CR
	.word	QUIT
abort_msg:
	.string	" abort"

	DEFWORD(quit, 0, QUIT)
	.word	LBRAC, RZ, RSPSTORE
quit_loop:
	.word	TIB, LIT, 0x0ff, ACCEPT, NUMBER_TIB, STORE, ZERO, TO_IN, STORE
	.word	SPACE, INTERPRET
	.word	STATE, FETCH, ZBRANCH, quit_int-$
	.word	LIT, comp_msg, LIT, 9, TYPE, CR, BRANCH, quit_loop-$
quit_int:
	.word	LIT, ok_msg, LIT, 3, TYPE, CR
	.word	BRANCH, quit_loop-$
ok_msg:
	.string	" ok"
comp_msg:
	.string	" compiled"


dnl 	DEFCODE(u., 0, U_DOT)
dnl 	lw	r2, r14, 0
dnl 	inc	r14
dnl 	jal	r15, _udot
dnl 	jal	r15, _udot_out
dnl 	li	r1, blank
dnl 	sw	r1, zero, _charout
dnl 	NEXT
dnl _udot:
dnl 	lw      r3, zero, var_BASE
dnl 	li	r4, _udot_buf
dnl 	li	r5, 0xa
dnl _udot_rep:
dnl 	dec	r4
dnl 	div     r2, r3
dnl 	mflo    r2
dnl 	mfhi    r6
dnl 
dnl 	blt	r6, r5, _udot_lt_10	; less than 10?
dnl 
dnl 	addi	r6, r6, 0x57		; add -10 + 'a'
dnl 	sw	r6, r4, 0
dnl 	bne	r2, zero, _udot_rep
dnl 	jr	r15
dnl 
dnl _udot_lt_10:
dnl 	addi	r6, r6, 0x30
dnl 	sw	r6, r4, 0
dnl 	bne	r2, zero, _udot_rep
dnl 	jr	r15
dnl 
dnl 
dnl 
dnl _udot_out:
dnl 	lw	r6, r4, 0
dnl 	beq	r6, zero, _udot_done
dnl 	sw	r6, zero, _charout
dnl 	inc	r4
dnl 	j	_udot_out
dnl _udot_done:
dnl ;	li	r1, blank
dnl ;	sw	r1, zero, _charout
dnl 	jr	r15
dnl 
dnl 	.word      0,0,0,0,0,0,0,0
dnl 	.word      0,0,0,0,0,0,0,0
dnl 	.word      0,0,0,0,0,0,0,0
dnl 	.word      0,0,0,0,0,0,0,0
dnl 	.word      0,0,0,0,0,0,0,0
dnl 	.word      0,0,0,0,0,0,0,0
dnl _udot_buf:
dnl 	.word	0
dnl _dot_neg:
dnl 	.word	0
dnl 
dnl 	DEFCODE(u.r, 0, U_DOT_R)
dnl 	lw	r2, r14, 1
dnl 	jal	r15, _udot
dnl 	lw	r2, r14, 0		; field width
dnl 	addi	r14, r14, 2
dnl 
dnl 	li	r8, _udot_buf
dnl 	sub	r5, r8, r4		; num digits
dnl 	sub	r2, r2, r5
dnl 	dec	r2
dnl ;	addi	r2, r2, -2
dnl 
dnl 	ble	r2, zero, _udotr_out
dnl 	li	r3, blank
dnl _udotr_spc:
dnl 	sw	r3, zero, _charout	; print space
dnl 	dec	r2
dnl 	bge	r2, zero, _udotr_spc
dnl 	
dnl _udotr_out:
dnl 	jal	r15, _udot_out
dnl 	NEXT
dnl 
dnl 
dnl 	DEFCODE(.r, 0, DOT_R)
dnl 	lw	r2, r14, 1
dnl 
dnl 	clear	r3
dnl 	bge	r2, zero, _dotr_pos
dnl 	neg	r2
dnl 	not	r3
dnl _dotr_pos:
dnl 	sw	r3, zero, _dot_neg
dnl 
dnl 	jal	r15, _udot
dnl 	
dnl 	lw	r2, r14, 0		; field width
dnl 	addi	r14, r14, 2
dnl ;	dec	r2
dnl 
dnl 	li	r8, _udot_buf
dnl 	sub	r5, r8, r4		; num digits
dnl 	sub	r2, r2, r5
dnl ;	dec	r2
dnl 	addi	r2, r2, -2
dnl 
dnl 	li	r3, blank
dnl 	ble	r2, zero, _dotr_out
dnl _dotr_spc:
dnl 	sw	r3, zero, _charout	; print space
dnl 	dec	r2
dnl 	bge	r2, zero, _dotr_spc
dnl 
dnl _dotr_out:
dnl 	lw	r2, zero, _dot_neg
dnl 	beq	r2, zero, _dotr_pos1
dnl 	li	r3, minus
dnl _dotr_pos1:
dnl 	sw	r3, zero, _charout
dnl 	
dnl 	jal	r15, _udot_out
dnl 	NEXT
dnl 	
dnl 
dnl 
dnl 	DEFCODE(., 0, DOT)
dnl 	lw	r2, r14, 0
dnl 	inc	r14
dnl 	jal	r15, _dot
dnl 	jal	r15, _udot_out
dnl 	li	r1, blank
dnl 	sw	r1, zero, _charout
dnl 	NEXT
dnl _dot:
dnl 	bge	r2, zero, _dot_pos
dnl 	li	r1, minus
dnl 	sw	r1, zero, _charout
dnl 	neg	r2
dnl _dot_pos:
dnl 	j	_udot





	DEFCODE(create, 0, CREATE)
_create:
	jal	r15, _parse_word

	lw	r4, zero, var_DP
	lw	r1, zero, var_LATEST
	sw	r1, r4, 0	; store link

	sw	zero, r4, 1	; store flags
	sw	r2, r4, 2	; store len
	move	r5, r4		; save dict ptr

	addi	r4, r4, 3	; address of dict name
_create0:
	lw	r1, r3, 0	; get name char
	sw	r1, r4, 0	; store name char
	inc	r4		; bump pointers
	inc	r3
	dec	r2		; decr char count
	bne	r2, zero, _create0	; keep copying until done

	sw	r5, r4, 0	; store back ptr
	inc	r4

	li	r1, _create_xt
	sw	r1, r4, 0	; store create xt in cfa

;	inc	r4
	addi	r4, r4, 2	; dfa
	sw	r4, r4, -1	; code pointer


	lw	r1, zero, var_DP
	sw	r1, zero, var_LATEST
	sw	r4, zero, var_DP
	NEXT

	.align
_create_xt:
	move	r2, r11		; r11 is word pointer (cfa)
	CFA2DFA(r2)
	PUSHDSP(r2)	
	NEXT

	DEFCODE(build, 0, BUILD)
	lw	r4, zero, var_DP
;	lw	r1, zero, var_LATEST
;	sw	r1, r4, 0	; store link
;	sw	zero, r4, 2	; store len
;	addi	r4, r4, 3	; address of dict name

	li	r1, _create_xt
	sw	r1, r4, 0	; store create xt in cfa

	PUSHDSP(r4)		; push xt addr to stack (cfa)

;	inc	r4
	addi	r4, r4, 2	; dfa
	sw	r4, r4, -1	; code pointer

	lw	r1, zero, var_DP
;	sw	r1, zero, var_LATEST
	sw	r4, zero, var_DP
	NEXT

	DEFCONST(_create_xt, 0, _CREATE_XT, _create_xt)
	DEFCONST(_does_xt, 0, _DOES_XT, _does_xt)

;: does> latest @ >cfa _does_xt over ! r> swap 1+ ! ;
dnl;	DEFWORD(does>, 0, DOES)
dnl;	.word	LATEST, FETCH, TO_CFA
dnl;	.word	LIT, _does_xt
dnl;	.word	OVER, STORE
dnl;	.word	FROM_R, SWAP, 1+, STORE
dnl;	.word	EXIT

	.align
_does_xt:
	move	r2, r11		; r11 is word pointer (cfa)
	CFA2DFA(r2)
	PUSHDSP(r2)		; push dfa to stack
xDOCOL:
	PUSHRSP(r10)
	;inc	r11
	;move	r10, r11
	lw	r10, r11, 1
xNEXT:
	lw	r11, r10, 0
	inc	r10
xRUN:
	lw	r12, r11, 0
	jr	r12
	NEXT

dnl;	DEFWORD(constant, 0, CONSTANT)
dnl;	.word	CREATE, COMMA
dnl;const_does:
dnl;	;.word	DOCOL, $+1
dnl;	.word	 FETCH, EXIT
dnl;
dnl;name_LENG:
dnl;	.word	LINK
dnl;	define({LINK}, name_LENG)dnl
dnl;	.word	0
dnl;	.word	{0x}format({%04x}, len({leng}))
dnl;	.string "leng"
dnl;LENG:
dnl;	.word	_does_xt
dnl;	.word	const_does
dnl;code_LENG:
dnl;	.word	10
dnl;



	DEFCODE({,}, 0, COMMA)
	; : , dp @ ! dp @ 1+ dp ! ;
	POPDSP(r2)
	lw	r3, zero, var_DP
	sw	r2, r3, 0
	inc	r3
	sw	r3, zero, var_DP
	NEXT


	DEFWORD(literal, f_immediate, LITERAL)
	; : literal ['] lit , , ; immediate
	.word	LIT, LIT, COMMA, COMMA, EXIT

	DEFCODE(litstring, 0, LITSTRING)
	lw	r2, r10, 0	; length of string
	inc	r10		; advance to string address
	addi	r14, r14, -2
	sw	r10, r14, 1	; push string address
	sw	r2, r14, 0	; push string length
	add	r10, r10, r2	; get past the string
 	NEXT

	DEFWORD(sliteral, f_immediate, SLITERAL)
	; sliteral ( addr count -- ) ['] sliteral , dup , here swap 2dup + dp ! move exit ; immediate
	.word	LIT, LITSTRING, COMMA, DUPE, COMMA
	.word	HERE, SWAP, TWO_DUPE, PLUS, DP, STORE, MOVE, EXIT


	DEFCODE([, f_immediate, LBRAC)
	clear	r2
	sw	r2, zero, var_STATE
	NEXT
	
	DEFCODE(], 0, RBRAC)
	li	r2, 0xffff
	sw	r2, zero, var_STATE
	NEXT

	DEFCODE(?immediate, 0, QUESTION_IMMEDIATE)
	lw	r2, r14, 0		; dict addr from stack
	inc	r2			; flags addr
	lw	r3, r2, 0		; get flags
	li	r4, f_immediate		; immediate bit
	and	r3, r3, r4		; isolate immediate bit
	clear	r2
	beq	r3, zero, not_immediate
	not	r2
not_immediate:
	sw	r2, r14, 0	
	NEXT

	DEFCODE(?hidden, 0, QUESTION_HIDDEN)
	lw	r2, r14, 0		; dict addr from stack
	inc	r2			; flags addr
	lw	r3, r2, 0		; get flags
	li	r4, f_hidden		; immediate bit
	and	r3, r3, r4		; isolate immediate bit
	clear	r2
	beq	r3, zero, not_hidden
	not	r2
not_hidden:
	sw	r2, r14, 0	
	NEXT


	DEFWORD(source, 0, SOURCE)
	.word	TIB, NUMBER_TIB, FETCH, EXIT

	DEFWORD(save-input, 0, SAVE_INPUT)
	.word	SOURCE, TO_IN, FETCH, SOURCE_ID, FETCH, LIT, 4, EXIT

	DEFWORD(restore-input, 0, RESTORE_INPUT)
	.word	LIT, 4, NOT_EQUALS, ZBRANCH, 2, ABORT
	.word	DUPE, SOURCE_ID, FETCH, NOT_EQUALS, ZBRANCH, 2, ABORT
	.word	SOURCE_ID, STORE, TO_IN, STORE, NUMBER_TIB, STORE, BUF, STORE
	.word	ZERO
	.word	EXIT


	DEFWORD(evaluate, 0, EVALUATE)
	.word	SAVE_INPUT, TO_R, TO_R, TO_R, TO_R, TO_R, NUMBER_TIB, STORE, BUF, STORE
	.word	ZERO, TO_IN, STORE
	.word	LIT, -1, SOURCE_ID, STORE
	.word	INTERPRET
	.word	ZERO, SOURCE_ID, STORE
	.word	FROM_R, FROM_R, FROM_R, FROM_R, FROM_R, RESTORE_INPUT, ZBRANCH, 2, ABORT
	.word	EXIT

	DEFCODE(immediate, 0, IMMEDIATE)
	lw	r2, zero, var_LATEST	; get latest word
	inc	r2			; flags addr
	lw	r3, r2, 0		; get flags
	li	r4, f_immediate		; immediate bit
	xor	r3, r3, r4		; toggle
	sw	r3, r2, 0		; store it
	NEXT

	DEFCODE(hidden, 0, HIDDEN)
	POPDSP(r2)			; dict header addr from stack
	inc	r2			; flags addr
	lw	r3, r2, 0		; get flags
	li	r4, f_hidden		; hidden bit
	xor	r3, r3, r4		; toggle
	sw	r3, r2, 0		; store it
	NEXT

	DEFWORD(hide, 0, HIDE)
	.word	PARSE_WORD, FIND, HIDDEN, EXIT


	DEFWORD({'}, 0, TICK)
	.word	PARSE_WORD, FIND, DUPE, ZBRANCH, tick0-$
	.word	TO_CFA, EXIT
tick0:	.word	ABORT

	DEFWORD({[']}, f_immediate, BRACKET_TICK_BRACKET)
	.word	TICK, LIT, LIT, COMMA, COMMA, EXIT

	DEFWORD(postpone, f_immediate, POSTPONE)
	.word	TICK, COMMA, EXIT

	DEFWORD(:, 0, COLON)
	.word	CREATE
	.word	LATEST, FETCH, DUPE, HIDDEN
	.word	DUPE, TO_CFA, _DOCOL, SWAP, STORE
	.word	TRUE
	.word	RBRAC
	.word	EXIT

	DEFWORD({;}, f_immediate, SEMICOLON)
	.word	LIT, EXIT, COMMA
	.word	ZBRANCH, _semi0-$
	.word	HIDDEN, BRANCH, _semi1-$
_semi0:
	.word	DROP
_semi1:
	.word	LBRAC
	.word	EXIT

	DEFWORD(:noname, 0, NONAME)
	.word	BUILD, DUPE, DUPE
	.word	_DOCOL, SWAP, STORE
	.word	FALSE
	.word	RBRAC
	.word	EXIT



	DEFWORD(init, 0, INIT)
	.word	LIT, code, LIT, end_code-code, EVALUATE
	.word	EXIT


	; should always be last
	DEFWORD(boot, 0, BOOT)
	.word	INIT
	.word	QUIT

;	.align
start_dp:

	.org	0xb000-1
	.word	end_code - code
	.org	0xb000
code:
	.string |

undivert(bsforth.fs)

|

end_code:



cr

: newline 10 ;
: \ newline parse 2drop ; immediate

: id. 3 + dup 1- @ type ;
\ : ; latest @ id. cr postpone ; ; immediate

: depth sp@ sp0 swap - ;
: progress [char] . emit space depth . cr ;

: .( [char] ) parse type ; immediate 

.( init )

: ( [char] ) parse 2drop ; immediate

progress

( comment test )


: binary 2 base ! ;
: octal 8 base ! ;
: decimal 10 base ! ;
: hex 16 base ! ;

: ? @ . ;

progress

: u? @ u. ;

: mod /mod drop ;


: star ( -- ) [char] * emit ;

: s" [char] " parse postpone sliteral ; immediate

: ." postpone s" ['] type , ; immediate

progress

: if ['] 0branch , here 0 , ; immediate

: then dup here swap - swap ! ; immediate

: else ['] branch , here >r 0 , dup here swap - swap ! r> ; immediate

: recurse latest @ >cfa , ;  immediate

: begin here ; immediate

: until ['] 0branch , here - , ; immediate

progress

: while postpone if ; immediate

: repeat ['] branch , swap here - , dup here swap - swap ! ; immediate

: (do) swap r> -rot >r >r >r ;

: do ['] (do) , 0 here ; immediate

\ : ?do ['] 2dup , ['] <> , ['] 0branch , here 0 , ['] (do) , here ; immediate

: (?do) 2dup = dup if -rot 2drop else -rot swap r> -rot >r >r >r then 0= ;
: ?do ['] (?do) , ['] 0branch , here 0 , here ; immediate

progress

: (loop) r> r> 1+ dup r@ < dup if swap >r else rdrop nip then 0= swap >r ;

: loop ['] (loop) , ['] 0branch , here - , ?dup if dup here swap - swap ! then ; immediate

: (+loop) r> r> rot + dup r@ < dup if swap >r else rdrop nip then 0= swap >r ;

: +loop ['] (+loop) , ['] 0branch , here - , ?dup if dup here swap - swap ! then ; immediate

: i r> r@ swap >r ;

: j r> r> r> r@ -rot >r >r swap >r ;

progress

\ : k r> r> r> r> r> r@ -rot >r >r -rot >r >r swap >r ;

: .s depth u. [char] ; emit space depth 0 ?do depth i - 1- pick . loop ;

: words latest begin @ ?dup while dup ?hidden 0= if dup id. space then repeat ;

: unused top here - ;

: welcome 
	cr ." bsforth version" version u. cr
	unused u. ."  cells free" cr cr
	;

progress

.( ready ) cr

welcome
hide welcome

progress


cr

: newline 10 ;

: \ newline parse 2drop ; immediate

: id. 3 + dup 1- @ type ;

\ : ; latest @ id. space postpone ; ; immediate

: depth sp@ sp0 swap - ;

\ : progress ;
: progress [char] . emit ;

: .( [char] ) parse type ; immediate

.( init )

: ( [char] ) parse 2drop ; immediate

progress

( comment test )

: binary 2 base ! ;
: octal 8 base ! ;
: decimal 10 base ! ;
: hex 16 base ! ;

: cells ;

: cell+ 1+ ;

: chars ;

: char+ 1+ ;

progress

: mod /mod drop ;

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

: (?do) 2dup = dup if -rot 2drop else -rot swap r> -rot >r >r >r then 0= ;

: ?do ['] (?do) , ['] 0branch , here 0 , here ; immediate

progress

: (loop) r> r> 1+ dup r@ < dup if swap >r else rdrop nip then 0= swap >r ;

: loop ['] (loop) , ['] 0branch , here - , ?dup if dup here swap - swap ! then ; immediate

: (+loop) r> r> rot + dup r@ < dup if swap >r else rdrop nip then 0= swap >r ;

: +loop ['] (+loop) , ['] 0branch , here - , ?dup if dup here swap - swap ! then ; immediate

: unloop r> r> drop r> drop >r ;

\ : leave ['] unloop , ['] branch , here  ;

: i r> r@ swap >r ;

: j r> r> r> r@ -rot >r >r swap >r ;

: k r> r> r> r> r> r@ -rot >r >r -rot >r >r swap >r ;

: unused top here - ;

: variable create 0 , ;

: allot here + dp ! ;

progress

create digits char 0 , char 1 , char 2 , char 3 , char 4 , char 5 , char 6 , char 7 , char 8 , char 9 , char a , char b , char c , char d , char e , char f ,

variable num-buf

: abs dup 0< if negate then ; 

: <# pad num-buf ! ;

: store-buf num-buf @ ! ;

: dec-buf num-buf @ 1- num-buf ! ;

: hold store-buf dec-buf ;

: sign 0< if [char] - hold then ;

: get-digit base @ /mod swap digits + @ ;

: # get-digit hold ;

: #s begin # dup 0= until ;

: #> drop num-buf @ 1+ pad num-buf @ - ;

: (.) abs <# #s swap sign #> ;
: (u.) <# #s #> ;

: . dup (.) type space ;
: u. (u.) type space ;

: .r swap (.) rot over - spaces type ;
: u.r swap (u.) rot over - spaces type ;

: ? @ . ;
: u? @ u. ;

: .s depth u. [char] ; emit space depth 0 ?do depth i - 1- pick . loop ;

: words latest begin @ ?dup while dup ?hidden 0= if dup id. space then repeat ;


progress

: does> latest @ >cfa _does_xt over ! r> swap 1+ ! ;

: constant create , does> @ ;

: @execute @ execute ;

: u< 2dup < -rot 0< swap 0< <> xor ;

: u> 2dup u< -rot = or invert ;



: 4hex. <# # # # # #> type ;

: addr. 4hex. [char] : emit space ;

: 8cells. dup 8 + swap do i @ 4hex. space loop ;

: 1char. dup bl >= over [char] ~ <= and if emit else drop [char] . emit then ;

: 8chars. dup 8 + swap do i @ 1char. loop ;

: (dump) dup addr. dup 8cells. space space 8chars. ;

: dump ( addr count -- ) 
	base @ >r hex 
	cr 
	8 * over + swap do i (dump) cr 8 +loop
	r> base ! ;



: welcome 
	cr ." bsforth version " version u. cr
	unused u. ." cells free" cr cr
	;

progress

.(  ready ) 
cr




welcome
hide welcome

: star ( -- ) [char] * emit ;

: prev dup @ swap ;
: prev-word prev dup . id. ;
: _words latest @ begin prev-word cr ?dup 0= until ; 


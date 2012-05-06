
use strict;
use warnings;

use Parse::RecDescent;
use Data::Dumper;

use vars qw(%VARIABLE);

# Enable warnings within the Parse::RecDescent module.

#$::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
#$::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
#$::RD_HINT   = 1; # Give out hints to help fix problems.
#$::RD_TRACE = 1;

my $grammar = <<'_EOGRAMMAR_';

	<autoaction: { [@item] } >

 
	SYMBOL: /[a-zA-Z_][a-zA-Z0-9_]*/
		| LOCATION

	LOCATION: '$'

	NUMBER  : /-?0x[0-9a-fA-F]+/
		| /-?0[0-7]+/
		| /-?0b[01]+/
		| /-?[0-9]+/

	addop: m([-+])

	mulop: m([*/])

	expression:	sum

	sum:	prod addop sum
		| prod 

	prod:	value mulop prod
		| value 

	value:	NUMBER | SYMBOL | '(' expression ')' { [$item[0,2]] }


	STRING:	/'/ /[^']*/ /'/ { [ @item[2] ] }
		| /"/ /[^"]*/ /"/ { [ @item[2] ] }

	OPCODE1:
		'add'
		| 'sub'
		| 'sllv'
		| 'srlv'
		| 'srav'
		| 'slt'
		| 'and'
		| 'or'
		| 'xor'
		| 'nor'

	OPCODE2: 'addi'
		| 'sll'
		| 'srl'
		| 'sra'
		| 'beq'
		| 'bne'
		| 'slti'
		| 'andi'
		| 'ori'
		| 'lw'
		| 'sw'

	OPCODE3:
		 'mul'
		| 'div'
		| 'jalr'

	OPCODE4: 'jal'

	OPCODE5:
		'jr'
		| 'mfhi'
		| 'mflo'

	OPCODE6: 'j'

	OPCODE7: 'brk'
		| 'halt'

	comment: ';' /.*\n/ { 1; }

	REG:	'r10' | 'r11' | 'r12' | 'r13' | 'r14' | 'r15'
		| 'r0' | 'r1' | 'r2' | 'r3' | 'r4' | 'r5' | 'r6' | 'r7' | 'r8' | 'r9' 
		| 'zero' | 'at' | 'v0' | 'v1' | 'a0' | 'a1' | 'a2' | 's0'
		| 's1' | 's2' | 't0' | 't1' | 't2' | 'fp' | 'sp' | 'ra'


	PSEUDO_OP1:	'mult' | 'divd'
	PSEUDO_OP2:	'bgt' | 'blt' | 'bge' | 'ble'
	PSEUDO_OP3:	'move'
	PSEUDO_OP4:	'li'
	PSEUDO_OP5:	'inc' | 'dec' | 'clear' | 'not' | 'neg'
	PSEUDO_OP6:	'nop'


	ps_type1:	PSEUDO_OP1 REG ',' REG ',' REG { [ @item[1,2,4,6] ] }
	ps_type2:	PSEUDO_OP2 REG ',' REG ',' expression { [ @item[1,2,4,6] ] }
	ps_type3:	PSEUDO_OP3 REG ',' REG  { [ @item[1,2,4] ] }
	ps_type4:	PSEUDO_OP4 REG ',' expression { [ @item[1,2,4] ] }
	ps_type5:	PSEUDO_OP5 REG { [ @item[1,2] ] }
	ps_type6:	PSEUDO_OP6 { [ @item[1] ] }


	pseudo:
		ps_type1
		| ps_type2
		| ps_type3
		| ps_type4
		| ps_type5
		| ps_type6



		
	op_type1:	OPCODE1 REG ',' REG ',' REG { [ @item[1,2,4,6] ] }
	op_type2:	OPCODE2 REG ',' REG ',' expression { [ @item[1,2,4,6] ] }
	op_type3:	OPCODE3 REG ',' REG { [ @item[1,2,4] ] }
	op_type4:	OPCODE4 REG ',' expression { [ @item[1,2,4] ] }
	op_type5:	OPCODE5 REG { [ @item[1,2] ] }
	op_type6:	OPCODE6 expression { [ @item[1,2] ] }
	op_type7:	OPCODE7 { [ @item[1] ] }



	instruction:
		op_type1
		| op_type2
		| op_type3
		| op_type4
		| op_type5
		| op_type6
		| op_type7

	label:	SYMBOL ':'

	directive:
		'.org' expression
		| '.word' expression(s /,/)
		| '.string' STRING(s /,/)
		| '.align'
		| '.set' SYMBOL ',' expression { [ @item[0,1,2,4] ] }

	line:	
		comment
		| directive 
		| pseudo 
		| instruction 
		| label 
		


	eof:	/^\Z/

	startrule: 
		line(s) eof { [$item[1]] }
		| <error>

_EOGRAMMAR_


sub log {

	print join(' ', @_),"\n";
	#print Dumper(\@_);

	1;
}

sub log2 {

	#print join(' ', @_),"\n";
	print Dumper(\@_);

	1;
}


sub build_tree {

	print "bt: ". Dumper(\@_);

	shift;

	my $lhs = shift;
	my $op = shift;
	my $rhs = shift;
	
	my $tree = { type => 'OP', name => $op, lhs => $lhs, rhs => $rhs };

	if($#_ == 0) {
		return $tree;
	}



	while ($#_ > 0) {

		my $op = shift;
		my $rhs = shift;

		$tree = { type => 'OP', name => $op, lhs => $tree, rhs => $rhs };
	}

	return $tree;
}


my $parser = Parse::RecDescent->new($grammar);

my @text = <>;

my $text = join('', @text);
#print "$text";

#my $tree = build_tree( ( '1', '*', '2', '*', '3', '*', '4' ) );

#print Dumper(\$tree);

my $ast = $parser->startrule($text);

defined $ast || die "Bad text!\n";

print Dumper($ast);


traverse(0, $ast);


sub traverse {
	
	my $depth = shift;
	my $node = shift;

	if(ref $node eq 'ARRAY') {
		for(@{$node}) {
			traverse($depth+1, $_);
		}
	}
	else {
		print ' ' x $depth . $node . "\n";
	}
}







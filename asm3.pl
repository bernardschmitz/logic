
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

 
	symbol: /[a-zA-Z_][a-zA-Z0-9_]*/
		| location

	location: '$'

	number  : /-?0x[0-9a-fA-F]+/
		| /-?0[0-7]+/
		| /-?0b[01]+/
		| /-?[0-9]+/

	addop: m([-+])

	mulop: m([*/])

	expression:	sum { [ map { $_ } @item ] } 

	sum:	prod addop sum
		| prod 

	prod:	value mulop prod
		| value 

	value:	number | symbol | '(' expression ')' { [$item[0,2]] }


	string:	/'/ /[^']*/ /'/ { [ @item[2] ] }
		| /"/ /[^"]*/ /"/ { [ @item[2] ] }

	opcode1:
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

	opcode2: 'addi'
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

	opcode3:
		 'mul'
		| 'div'
		| 'jalr'

	opcode4: 'jal'

	opcode5:
		'jr'
		| 'mfhi'
		| 'mflo'

	opcode6: 'j'

	opcode7: 'brk'
		| 'halt'

	comment: ';' /.*\n/ { 1; }

	reg:	'r10' | 'r11' | 'r12' | 'r13' | 'r14' | 'r15'
		| 'r0' | 'r1' | 'r2' | 'r3' | 'r4' | 'r5' | 'r6' | 'r7' | 'r8' | 'r9' 
		| 'zero' | 'at' | 'v0' | 'v1' | 'a0' | 'a1' | 'a2' | 's0'
		| 's1' | 's2' | 't0' | 't1' | 't2' | 'fp' | 'sp' | 'ra'


	pseudo_op1:	'mult' | 'divd'
	pseudo_op2:	'bgt' | 'blt' | 'bge' | 'ble'
	pseudo_op3:	'move'
	pseudo_op4:	'li'
	pseudo_op5:	'inc' | 'dec' | 'clear' | 'not' | 'neg'
	pseudo_op6:	'nop'


	ps_type1:	pseudo_op1 reg ',' reg ',' reg { [ @item[1,2,4,6] ] }
	ps_type2:	pseudo_op2 reg ',' reg ',' expression { [ @item[1,2,4,6] ] }
	ps_type3:	pseudo_op3 reg ',' reg  { [ @item[1,2,4] ] }
	ps_type4:	pseudo_op4 reg ',' expression { [ @item[1,2,4] ] }
	ps_type5:	pseudo_op5 reg { [ @item[1,2] ] }
	ps_type6:	pseudo_op6 { [ @item[1] ] }


	pseudo:
		ps_type1
		| ps_type2
		| ps_type3
		| ps_type4
		| ps_type5
		| ps_type6



		
	op_type1:	opcode1 reg ',' reg ',' reg { [ @item[1,2,4,6] ] }
	op_type2:	opcode2 reg ',' reg ',' expression { [ @item[1,2,4,6] ] }
	op_type3:	opcode3 reg ',' reg { [ @item[1,2,4] ] }
	op_type4:	opcode4 reg ',' expression { [ @item[1,2,4] ] }
	op_type5:	opcode5 reg { [ @item[1,2] ] }
	op_type6:	opcode6 expression { [ @item[1,2] ] }
	op_type7:	opcode7 { [ @item[1] ] }



	instruction:
		op_type1
		| op_type2
		| op_type3
		| op_type4
		| op_type5
		| op_type6
		| op_type7

	label:	symbol ':' { [ $item[1] ] }

	directive:
		'.org' expression
		| '.word' expression(s /,/)
		| '.string' string(s /,/)
		| '.align'
		| '.set' symbol ',' expression { [ @item[0,1,2,4] ] }

	line:	
		comment
		| directive 
		| pseudo 
		| instruction 
		| label 
		


	eof:	/^\Z/

	startrule: 
		line(s) eof { [ map { $_ } @{$item[1]} ] } 
#{ [$item[1]] }
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

#	print ' ' x $depth . join(' ', @{$node}), "\n";
	
	for(@{$node}) {
		if(ref $_ eq 'ARRAY') {
			traverse($depth+1, $_);
		}
		else {
			print ' ' x $depth . $_ . "\n";
		}
	}

	return;

	if(ref $node eq 'ARRAY') {
		for(@{$node}) {
			traverse($depth+1, $_);
		}
	}
	else {
		print ' ' x $depth . $node . "\n";
	}
}







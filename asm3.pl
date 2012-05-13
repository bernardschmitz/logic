
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
		| location { @item[1] }

	location: '$' { [ @item[0] ] }

	number  : /0x[0-9a-fA-F]+/
		| /0[0-7]+/
		| /0b[01]+/
		| /[0-9]+/

	addop: '+' | '-' | '&' | '^' | '|'

	mulop: '*' | '/' | '%' | '<<' | '>>'

	unop:	'~' | '-'

	expression:	sum 

	sum:	prod addop sum | prod

	prod:	value mulop prod | unary 

	unary:	unop value | value

	value:	number | symbol | '(' expression ')' { [@item[0,2]] }

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

	comment: ';' /.*\n/ { [@item[0]] }

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


	pseudo:
		pseudo_op1 reg ',' reg ',' reg { [ @item[0,1,2,4,6] ] }
		| pseudo_op2 reg ',' reg ',' expression { [ @item[0,1,2,4,6] ] }
		| pseudo_op3 reg ',' reg  { [ @item[0,1,2,4] ] }
		| pseudo_op4 reg ',' expression { [ @item[0,1,2,4] ] }
		| pseudo_op5 reg { [ @item[0,1,2] ] }
		| pseudo_op6 { [ @item[0,1] ] }


	instruction:
		opcode1 reg ',' reg ',' reg { [ @item[0,1,2,4,6] ] }
		| opcode2 reg ',' reg ',' expression { [ @item[0,1,2,4,6] ] }
		| opcode3 reg ',' reg { [ @item[0,1,2,4] ] }
		| opcode4 reg ',' expression { [ @item[0,1,2,4] ] }
		| opcode5 reg { [ @item[0,1,2] ] }
		| opcode6 expression { [ @item[0,1,2] ] }
		| opcode7 { [ @item[0,1] ] }

	label:	symbol ':' { [ @item[0,1] ] }

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
		# remove comment nodes
		line(s) eof { [ map { $_->[1] } grep { $_->[1]->[0] ne 'comment' } @{$item[1]} ] } 
		| <error>

_EOGRAMMAR_


sub log {

	print join(' ', @_),"\n";
	1;
}

sub log2 {

	print Dumper(\@_);
	1;
}



my $parser = Parse::RecDescent->new($grammar);

my @text = <>;

my $text = join('', @text);
#print "$text";

my $ast = $parser->startrule($text);

defined $ast || die "Bad text!\n";



#print "\n", Dumper($ast);



#traverse(0, $ast);

#print "\n";
#$ast = strip_comments($ast);

print "\n";
$ast = replace_pseudo_ops($ast);

my $location = 0;
my %symbol = ();

print "\n";
collect_symbols($ast);

print Dumper(\%symbol);

#print "\n";
#traverse(0, $ast);


#sub strip_comments {
#
#	my $node = shift;
#	my @ast = grep { $_->[0] ne 'comment' } @{$node};
#	return \@ast;
#}


sub traverse {
	
	my $depth = shift;
	my $node = shift;

#	print ' ' x $depth . join(' ', @{$node}), "\n";
	
	for(@{$node}) {
		if(ref $_ eq 'ARRAY') {
#			print "\n";
			traverse($depth+1, $_);
		}
		else {
			print ' ' x $depth . $_ . "\n";
		}
	}
}


sub replace_pseudo_ops {

	my $lines = shift;

	my @ast = map { 
		if($_->[0] eq 'pseudo') {
			replace_pseudo_op($_);
		}
		else {
			$_;
		}
	} @{$lines};

	return \@ast;
}

sub replace_pseudo_op {

	my $node = shift;

#	print Dumper($node);

	my $op = $node->[1]->[1];

	if($op eq 'not') {
		my $reg = $_->[2];
		[ 'instruction', 
			[ 'opcode1', 'nor' ],
			$reg, $reg, $reg
		];
	}
	elsif($op eq 'nop') {
		[ 'instruction', 
			[ 'opcode1', 'add' ],
			[ 'reg', 'zero' ],
			[ 'reg', 'zero' ],
			[ 'reg', 'zero' ]
		];
	}
	elsif($op eq 'clear') {
		my $reg = $_->[2];
		[ 'instruction', 
			[ 'opcode1', 'add' ],
			$reg,
			[ 'reg', 'zero' ],
			[ 'reg', 'zero' ]
		];
	}
	elsif($op eq 'inc') {
		my $reg = $_->[2];
		[ 'instruction',
			[ 'opcode2', 'addi' ],
			$reg, $reg, 
			[ 'expression', 
				[ 'sum',
					[ 'prod',
						[ 'value',
							[ 'number', 1 ]
						]
					]
				]
			]
		];
	}
	elsif($op eq 'dec') {
		my $reg = $_->[2];
		[ 'instruction',
			[ 'opcode2', 'addi' ],
			$reg, $reg, 
			[ 'expression', 
				[ 'sum',
					[ 'prod',
						[ 'value',
							[ 'number', -1 ]
						]
					]
				]
			]
		];
	}
	elsif($op eq 'move') {
		my $dst = $_->[2];
		my $src = $_->[3];
		[ 'instruction', 
			[ 'opcode1', 'add' ],
			$dst, $src,
			[ 'reg', 'zero' ]
		];
	}
	elsif($op eq 'li') {
		my $dst = $_->[2];
		my $addr = $_->[3];
		[ 'instruction', 
			[ 'opcode2', 'addi' ],
			$dst,
			[ 'reg', 'zero' ],
			$addr
		];
	}
	elsif($op eq 'neg') {
		my $reg = $_->[2];

		(
			[ 'instruction', 
				[ 'opcode1', 'nor' ],
				$reg, $reg, $reg
			],
			[ 'instruction',
				[ 'opcode2', 'addi' ],
				$reg, $reg, 
				[ 'expression', 
					[ 'sum',
						[ 'prod',
							[ 'value',
								[ 'number', -1 ]
							]
						]
					]
				]
			]
		);
	}
	elsif($op eq 'mult') {
		my $dst = $_->[2];
		my $src = $_->[3];
		my $targ = $_->[4];

		(
			[ 'instruction',
				[ 'opcode3', 'mul' ],
				$src, $targ
			],
			[ 'instruction',
				[ 'opcode5', 'mflo' ],
				$dst
			]
		);

	}
	elsif($op eq 'divd') {
		my $dst = $_->[2];
		my $src = $_->[3];
		my $targ = $_->[4];

		(
			[ 'instruction',
				[ 'opcode3', 'div' ],
				$src, $targ
			],
			[ 'instruction',
				[ 'opcode5', 'mflo' ],
				$dst
			]
		);

	}
	elsif($op eq 'bgt') {
		my $x = $_->[2];
		my $y = $_->[3];
		my $z = $_->[4];

		(
			[ 'instruction',
				[ 'opcode1', 'slt' ],
				[ 'reg', 'at' ],
				$y, $x
			],
			[ 'instruction',
				[ 'opcode2', 'bne' ],
				[ 'reg', 'at' ],
				[ 'reg', 'zero' ],
				$z
			]
		);

	}
	elsif($op eq 'blt') {
		my $x = $_->[2];
		my $y = $_->[3];
		my $z = $_->[4];

		(
			[ 'instruction',
				[ 'opcode1', 'slt' ],
				[ 'reg', 'at' ],
				$x, $y
			],
			[ 'instruction',
				[ 'opcode2', 'bne' ],
				[ 'reg', 'at' ],
				[ 'reg', 'zero' ],
				$z
			]
		);

	}
	elsif($op eq 'bge') {
		my $x = $_->[2];
		my $y = $_->[3];
		my $z = $_->[4];

		(
			[ 'instruction',
				[ 'opcode1', 'slt' ],
				[ 'reg', 'at' ],
				$x, $y
			],
			[ 'instruction',
				[ 'opcode2', 'beq' ],
				[ 'reg', 'at' ],
				[ 'reg', 'zero' ],
				$z
			]
		);

	}
	elsif($op eq 'ble') {
		my $x = $_->[2];
		my $y = $_->[3];
		my $z = $_->[4];

		(
			[ 'instruction',
				[ 'opcode1', 'slt' ],
				[ 'reg', 'at' ],
				$y, $x
			],
			[ 'instruction',
				[ 'opcode2', 'beq' ],
				[ 'reg', 'at' ],
				[ 'reg', 'zero' ],
				$z
			]
		);

	}
	else {
		$_;
	}
}

sub collect_symbols {

	my $lines = shift;

	$location = 0;

	for(@{$lines}) {

		my $op = $_->[0];

		if($op eq 'directive')  {
			collect_directive_symbol($_);
		}
		elsif($op eq 'label') {
			my $name = $_->[1]->[1];
			die "symbol $name redefinition\n" if defined $symbol{$name};
			$symbol{$name} = { name => $name, value => $location };
		}
		elsif($op eq 'instruction') {
			$location += 2;
		}
		else {
			die "unknown node $op when collecting symbols\n";
		}
	}

	my $undef_exist = 1;

	while($undef_exist) {
		for(values %symbol) {
			if(!defined $_->{value}) {
				$_->{value} = evaluate_expression($_->{expression});
				#delete $_->{expression};
			}
		}

		$undef_exist = 0;

		for(values %symbol) {
			if(!defined $_->{value}) {
				$undef_exist = 1;
			}
			else {
				delete $_->{expression};
			}
		}
	}
}


sub collect_directive_symbol {

	my $node = shift;

#	print Dumper($node);

	my $op = $node->[1];

	#print "$op\n";

	if($op eq '.set') {
		
		my $name = $node->[2]->[1];
		die "symbol $name redefinition\n" if defined $symbol{$name};
		my $expr = $node->[3];
		$symbol{$name} = { name => $name, expression => $expr };
	}
	elsif($op eq '.word') {
		$location += (scalar @{$node->[2]});
	}
	elsif($op eq '.string') {
		my $c = 0;
		for(@{$node->[2]}) {
			#print "$_->[0]\n";
			$c += length($_->[0]);
		}
		$location += $c;
	}
	elsif($op eq '.org') {
		my $result = evaluate_expression($node->[2]) || die ".org expression not constant\n";
#		print "result: $result\n";
		$location = $result;
	}
	elsif($op eq '.align') {
		$location = ( $location + 1 ) & 0xfffe;
	}
	else {
		die "unknown directive $op\n";
	}
}

sub evaluate_expression {

	my $node = shift;

	#print Dumper($node);	

	my $op = $node->[0];

	if($op eq 'expression') {
		return evaluate_expression($node->[1]);
	}
	elsif($op eq 'sum' || $op eq 'prod') {
		my $lhs = evaluate_expression($node->[1]);

		if(!defined $lhs) {
			return undef;
		}

		if(scalar @{$node} == 4) {
			my $oper = $node->[2]->[1];
			my $rhs = evaluate_expression($node->[3]);
			if(!defined $rhs) {
				return undef;
			}

#			print "$lhs $oper $rhs\n";
			
			if($oper eq '*') {
				return $lhs * $rhs;
			}
			elsif($oper eq '/') {
				return $lhs / $rhs;
			}
			elsif($oper eq '%') {
				return $lhs % $rhs;
			}
			elsif($oper eq '<<') {
				return $lhs << $rhs;
			}
			elsif($oper eq '>>') {
				return $lhs >> $rhs;
			}
			elsif($oper eq '+') {
				return $lhs + $rhs;
			}
			elsif($oper eq '-') {
				return $lhs - $rhs;
			}
			elsif($oper eq '&') {
				return $lhs & $rhs;
			}
			elsif($oper eq '^') {
				return $lhs ^ $rhs;
			}
			elsif($oper eq '|') {
				return $lhs | $rhs;
			}
			else {
				die "unknown binop $oper\n";
			}
		}
		
		return $lhs;
	}
	elsif($op eq 'value') {

 		if($node->[1]->[0] eq 'number') {
			my $val = $node->[1]->[1];
			$val = oct($val) if $val =~ m/^0/;
#			print "val: $val\n";
			return $val;
		}
		elsif($node->[1]->[0] eq 'symbol') {
			my $name = $node->[1]->[1];
			my $sym = $symbol{$name};
			if(defined $sym) {
#				print "sym: $name $sym->{value}\n";
				return $sym->{value};
			}
			else {
				return undef;
			}
		}
		elsif($node->[1]->[0] eq 'location') {
			return $location;
		}
		if($node->[1]->[0] eq 'expression') {
			return evaluate_expression($node->[1]->[1]);
		}
		else {
#			print Dumper($node);
			die "unknown value $node->[1]->[0]\n";
		}
	}
	elsif($op eq 'unary') {
		#print Dumper($node);
		if($node->[1]->[0] eq 'unop') {

			my $val = evaluate_expression($node->[2]);
			if(!defined $val) {
				return undef;
			}

		#	print "val: $val\n";

			my $oper = $node->[1]->[1];

			if($oper eq '~') {
				return ~(0+$val);
			}
			elsif($oper eq '-') {
				return -$val;
			}
			else {
				die "unknown unop $oper\n";
			}
		}

		return evaluate_expression($node->[1]);
	}
	else {
		print Dumper($node);
		die "unknown expression op $op\n";
	}

	return undef;
}



use strict;

my %instruction = (
	org => { },
	dw => { },
	align => { },

	add => { code => 0, size => 2, type => 0 },
	addi => { code => 1, size => 2, type => 1 },
	sub => { code => 2, size => 2, type => 0 },
	mul => { code => 3, size => 2, type => 2 },
	div => { code => 4, size => 2, type => 2 },
	sll => { code => 5, size => 2, type => 1 },
	srl => { code => 6, size => 2, type => 1 },
	sra => { code => 7, size => 2, type => 1 },
	sllv => { code => 8, size => 2, type => 0 },
	srlv => { code => 9, size => 2, type => 0 },
	srav => { code => 10, size => 2, type => 0 },
	beq => { code => 11, size => 2, type => 2 },
	bne => { code => 12, size => 2, type => 2 },
	slt => { code => 13, size => 2, type => 0 },
	slti => { code => 14, size => 2, type => 1 },
	and => { code => 15, size => 2, type => 0 },
	andi => { code => 16, size => 2, type => 1 },
	or => { code => 17, size => 2, type => 0 },
	ori => { code => 18, size => 2, type => 1 },
	xor => { code => 19, size => 2, type => 0 },
	nor => { code => 20, size => 2, type => 0 },
	j => { code => 21, size => 2, type => 2 },
	jr => { code => 22, size => 2, type => 2 },
	jal => { code => 23, size => 2, type => 2 },
	jalr => { code => 24, size => 2, type => 2 },
	lw => { code => 25, size => 2, type => 1 },
	sw => { code => 26, size => 2, type => 1 },
	mfhi => { code => 27, size => 2, type => 2 },
	mflo => { code => 28, size => 2, type => 2 },
	halt => { code => 30, size => 2, type => 2 },
);


# symbol:	ins	rd, rs, rt	; comment
#		ins	rd, rs, C

my %symbols = ();

my @lines = <>;
my $address = 0;
my $line = 0;

for my $pass (0..1) {

	$address = 0;
	$line = 0;

	for(@lines) {
		chomp;

		$line++;

		s/;.*$//g;

		next if m/^\s*$/;

		my ($sym, $ins, $ops) = parse($_);

		if($pass == 0) {
			collect_symbol($sym, $ins, $ops);
		}
		else {
			assemble($ins, $ops);
		}
	}
}


print "\n\nsymbols\n-------\n";
for(sort { $symbols{$a} <=> $symbols{$b} } keys %symbols) {
	print sprintf("%s %x\n", $_, $symbols{$_});
}


sub collect_symbol {

	my ($sym, $ins, $ops) = @_;

	if($sym ne '') {
		$symbols{$sym} = $address;
	}

	my $desc = $instruction{$ins};

	if(defined $desc) {

#		print "$address -> ";

		if(defined $desc->{size}) {
			$address += $desc->{size};
		}
		elsif($ins eq 'org') {
			if(scalar @{$ops} == 1 && $ops->[0] =~ m/^[0-9a-f]+$/i) {
				$address = hex $ops->[0];
			}
			else {
				die "line $line invalid origin: ".join(' ', @{$ops})."\n";
			}
		}
		elsif($ins eq 'dw') {
			$address += scalar @{$ops};
		}
		elsif($ins eq 'align') {
			$address = $address % 2 == 0 ? $address : $address+1;
		}

#		print "$address\n";
	}
}


sub assemble {

	my ($ins, $ops) = @_;

	my $desc = $instruction{$ins};

	if(defined $desc) {

		if(defined $desc->{code}) {
			encode_instruction($desc, $ins, $ops);
		}
		elsif($ins eq 'dw') {
			for(@{$ops}) {
				if(m/^[a-z][a-z0-9]*$/i) {
					my $val = lookup_symbol($_);
					output_word($val);
				}
				elsif(m/^-[0-9a-f]+$/i) {
					s/-//;
					my $val = hex;
					output_word(-$val);
				}
				elsif(m/^[0-9a-f]+$/i) {
					my $val = hex;
					output_word($val);
				}
				else {
					die "line $line unknown word value: $_\n";
				}
			}
		}
	}
	else {
		die "line $line unknown instruction: $ins\n";
	}
}

sub encode_instruction {

	my ($desc, $ins, $ops) = @_;

	my $code = 0xcafe;
	my $oper = 0xbabe;


	if($desc->{type} == 0) {
		($code, $oper) = type_1_instruction($desc, $ins, $ops);
	}	

	output_word($code);
	output_word($oper);
}

sub type_1_instruction {

	my ($desc, $ins, $ops) = @_;

	if(scalar @{$ops} != 3) {
		die "line $line expected three operands for: $ins\n";
	}

	my $rd = get_register(shift @{$ops});
	my $rs = get_register(shift @{$ops});
	my $rt = get_register(shift @{$ops});

	my $code = $desc->{code} << 8 | $rd << 4 | $rs;
	my $oper = $rt << 12;

	return ($code, $oper);
}

sub get_register {

	my $reg = shift;

	if($reg =~ m/^r([0-9][0-9]?)$/i) {
		my $val = $1;
		if($val >= 0 && $val <= 15) {
			return $val;
		}
	}

	die "line $line invalid register spec: $reg\n";
}

sub parse {

	my $_ = shift;

	my $sym;

	if(m/^\s*([a-z][a-z0-9]*):/i) {
		$sym = $1;
	}

	#print "s $sym\n";

	my $ins;

	if(m/^\s*([a-z][a-z0-9]*:)?\s*([a-z]+)/i) {
		$ins = $2;
	}

	#print "i $ins\n";

#	my $op1;
#
#	if(m/^\s*([a-z][a-z0-9]*:)?\s*([a-z]+)\s+([a-z0-9]+),?/i) {
#		$op1 = $3;
#	}
#
#	print "1 $op1\n";
#
#	my $op2;
#
#	if(m/^\s*([a-z][a-z0-9]*:)?\s*([a-z]+)\s+([a-z0-9]+,)\s*([a-z0-9]+),?/i) {
#		$op2 = $4;
#	}
#
#	print "2 $op2\n";
#
#	my $op3;
#
#	if(m/^\s*([a-z][a-z0-9]*:)?\s*([a-z]+)\s+([a-z0-9]+,)\s*([a-z0-9]+,)\s*([a-z0-9]+)/i) {
#		$op3 = $5;
#	}
#
#	print "3 $op3\n";

	my @ops = ();

	while(m/([\-a-z0-9]+),/ig) {
		push @ops, $1
	}	

	if(m/,?\s*([\-a-z0-9]+)\s*$/ig) {
		push @ops, $1
	}

#	print "ops ".join(' ', @ops)."\n";

	return ($sym, $ins, \@ops);
}

sub lookup_symbol {

	my $key = shift;

	if(defined $symbols{$key}) {
		return $symbols{$key};
	}

	die "line $line unknown symbol: $key\n";
}


sub output_word {
	
	my $val = shift;

	$val &= 0xffff;

	print sprintf("%04x\n", $val);
	$address++;
}



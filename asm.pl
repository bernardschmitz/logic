
use strict;
#use warnings;
use integer;

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
	halt => { code => 31, size => 2, type => 2 },
);


my %register = (
	r0 => { index => 0 },
	r1 => { index => 1 },
	r2 => { index => 2 },
	r3 => { index => 3 },
	r4 => { index => 4 },
	r5 => { index => 5 },
	r6 => { index => 6 },
	r7 => { index => 7 },
	r8 => { index => 8 },
	r9 => { index => 9 },
	r10 => { index => 10 },
	r11 => { index => 11 },
	r12 => { index => 12 },
	r13 => { index => 13 },
	r14 => { index => 14 },
	r15 => { index => 15 },
	zero => { index => 0 },
	at => { index => 1 },
	v0 => { index => 2 },
	v1 => { index => 3 },
	a0 => { index => 4 },
	a1 => { index => 5 },
	a2 => { index => 6 },
	s0 => { index => 7 },
	s1 => { index => 8 },
	s2 => { index => 9 },
	t0 => { index => 10 },
	t1 => { index => 11 },
	t2 => { index => 12 },
	fp => { index => 13 },
	sp => { index => 14 },
	ra => { index => 15 },
);


# symbol:	ins	rd, rs, rt	; comment
#		ins	rd, rs, C

my %symbols = ();

my @lines = <>;
my $address = 0;
my $line = 0;

print "v2.0 raw\n";

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
			if($ins ne '') {
				print STDERR sprintf("%04x: %s\n", $address, $_);
				assemble($ins, $ops);
			}
		}
	}
}


#print "\n\nsymbols\n-------\n";
#for(sort { $symbols{$a} <=> $symbols{$b} } keys %symbols) {
#	print sprintf("%s %x\n", $_, $symbols{$_});
#}


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
			if(scalar @{$ops} == 1 && $ops->[0] =~ m/^[0-9a-f]+$/i && $ops->[0] >= $address) {
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
					die "line $line unknown word value: '$_'\n";
				}
			}
		}
		elsif($ins eq 'align') {
			if($address % 2 == 1) {
				output_word(0);
			}
		}
		elsif($ins eq 'org') {

			my $org = hex $ops->[0];
			my $count = $org - $address;
			for(1..$count) {
				output_word(0);
			}
			
			$address = $org;
		}
	}
	else {
		die "line $line unknown instruction: '$ins'\n";
	}
}

sub encode_instruction {

	my ($desc, $ins, $ops) = @_;

	my $code = 0xcafe;
	my $oper = 0xbabe;


	if($desc->{type} == 0) {
		($code, $oper) = type_1_instruction($desc, $ins, $ops);
	}	
	elsif($desc->{type} == 1) {
		($code, $oper) = type_2_instruction($desc, $ins, $ops);
	}
	elsif($desc->{type} == 2) {
		($code, $oper) = type_3_instruction($desc, $ins, $ops);
	}

	output_word($code);
	output_word($oper);
}

sub type_1_instruction {

	my ($desc, $ins, $ops) = @_;

	if(scalar @{$ops} != 3) {
		die "line $line expected 3 operands for: '$ins'\n";
	}

	my $rd = get_register(shift @{$ops});
	my $rs = get_register(shift @{$ops});
	my $rt = get_register(shift @{$ops});

	my $code = $desc->{code} << 8 | $rd << 4 | $rs;
	my $oper = $rt << 12;

	return ($code, $oper);
}

sub type_2_instruction {

	my ($desc, $ins, $ops) = @_;

	if(scalar @{$ops} != 3) {
		die "line $line expected 3 operands for: $ins\n";
	}

	my $rd = get_register(shift @{$ops});
	my $rs = get_register(shift @{$ops});
	my $const = get_constant(shift @{$ops});

	my $code = $desc->{code} << 8 | $rd << 4 | $rs;
	my $oper = $const;

	return ($code, $oper);
}

sub type_3_instruction {

	my ($desc, $ins, $ops) = @_;

	if($ins eq 'mul' || $ins eq 'div') {
		return mul_div($desc, $ins, $ops);
	}

	if($ins eq 'mfhi' || $ins eq 'mflo') {
		return mf($desc, $ins, $ops);
	}

	if($ins eq 'beq' || $ins eq 'bne') {
		return branch($desc, $ins, $ops);
	}

	if($ins eq 'j') {
		return j($desc, $ins, $ops);
	}

	if($ins eq 'jr') {
		return jr($desc, $ins, $ops);
	}

	if($ins eq 'jal') {
		return jal($desc, $ins, $ops);
	}

	if($ins eq 'jalr') {
		return jalr($desc, $ins, $ops);
	}

	if($ins eq 'halt') {
		return halt($desc, $ins, $ops);
	}

	die "line $line unknown instruction: $ins\n";
}

sub mul_div {

	my ($desc, $ins, $ops) = @_;

	if(scalar @{$ops} != 2) {
		die "line $line expected 2 operands for: $ins\n";
	}

	my $rs = get_register(shift @{$ops});
	my $rt = get_register(shift @{$ops});

	my $code = $desc->{code} << 8 | $rs;
	my $oper = $rt << 12;

	return ($code, $oper);
}

sub mf {

	my ($desc, $ins, $ops) = @_;

	if(scalar @{$ops} != 1) {
		die "line $line expected 1 operands for: $ins\n";
	}

	my $rd = get_register(shift @{$ops});

	my $code = $desc->{code} << 8 | $rd << 4;
	my $oper = 0;

	return ($code, $oper);
}

sub branch {

	my ($desc, $ins, $ops) = @_;

	if(scalar @{$ops} != 3) {
		die "line $line expected 3 operands for: $ins\n";
	}

	my $rs = get_register(shift @{$ops});
	my $rd = get_register(shift @{$ops});
	my $const = get_constant(shift @{$ops});

	my $disp = $const - ($address+2);

	#print "$address $const $disp\n";

	my $code = $desc->{code} << 8 | $rd << 4 | $rs;
	my $oper = $disp >> 1;

	return ($code, $oper);
}

sub j {

	my ($desc, $ins, $ops) = @_;

	if(scalar @{$ops} != 1) {
		die "line $line expected 1 operands for: $ins\n";
	}

	my $const = get_constant(shift @{$ops});

	my $code = $desc->{code} << 8;
	my $oper = $const;

	return ($code, $oper);
}

sub jr {

	my ($desc, $ins, $ops) = @_;

	if(scalar @{$ops} != 1) {
		die "line $line expected 1 operands for: $ins\n";
	}

	my $rt = get_register(shift @{$ops});

	my $code = $desc->{code} << 8;
	my $oper = $rt << 12;

	return ($code, $oper);
}

sub jal {

	my ($desc, $ins, $ops) = @_;

	if(scalar @{$ops} != 2) {
		die "line $line expected 2 operands for: $ins\n";
	}

	my $rd = get_register(shift @{$ops});
	my $const = get_constant(shift @{$ops});

	my $code = $desc->{code} << 8 | $rd << 4;
	my $oper = $const;

	return ($code, $oper);
}

sub jalr {

	my ($desc, $ins, $ops) = @_;

	if(scalar @{$ops} != 2) {
		die "line $line expected 2 operands for: $ins\n";
	}

	my $rd = get_register(shift @{$ops});
	my $rt = get_register(shift @{$ops});

	my $code = $desc->{code} << 8 | $rd << 4;
	my $oper = $rt << 12;

	return ($code, $oper);
}

sub halt {

	my ($desc, $ins, $ops) = @_;

#	if(scalar @{$ops} != 0) {
#		die "line $line expected 0 operands for: '$ins' '".join(' ', @{$ops})."'\n";
#	}

	my $code = $desc->{code} << 8;
	my $oper = 0;

	return ($code, $oper);
}

sub get_register {

	my $reg = shift;

	$reg =~ s/\s*//g;

	my $desc = $register{$reg};

	if(defined $desc) {
		return $desc->{index};
	}

	die "line $line invalid register spec: '$reg'\n";
}

sub get_constant {

	my $_ = shift;

	if(m/^[a-z][a-z0-9]*$/i) {
		return lookup_symbol($_);
	}
	elsif(m/^-[0-9a-f]+$/i) {
		s/-//;
		my $val = hex;
		return -$val;
	}
	elsif(m/^[0-9a-f]+$/i) {
		return hex;
	}
	else {
		die "line $line unknown word value: $_\n";
	}
}

sub parse {

	my $_ = shift;

	my $sym;

	s/^\s+//g;

#	print "[$_]\n";

	if(m/^([a-z][a-z0-9]*):/i) {
		$sym = $1;
		s/^\s*$sym://i;
#		print "sym $sym [$_]\n";
	}

	my $ins;

	s/^\s+//g;

#	print "[$_]\n";

	#if(m/^\s*([a-z][a-z0-9]*:)?\s*([a-z]+)/i) {
	if(m/^([a-z]+)/i) {
		$ins = $1;
		s/^$ins//i;
#		print "ins $ins [$_]\n";
	}

	my @ops = split(/,/);

	map { s/\s+//g } @ops;

#	my @ops = ();
#
#	while(m/([\-a-z0-9]+),/ig) {
#		push @ops, $1
#	}	
#
#	if(m/,\s*([\-a-z0-9]+)\s*$/ig) {
#		push @ops, $1
#	}
#
#	if(m/^\s*([a-z][a-z0-9]*:)?\s*([a-z]+)\s+([\-a-z0-9]+)\s*$/ig) {
#		push @ops, $3
#	}

#	print "sym: '$sym' ins: '$ins' ops: '".join(' ', @ops)."'\n";

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



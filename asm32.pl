
use strict;
#use warnings;
use integer;

use Data::Dumper;

my %instruction = (
	org => { },
	dw => { },
	align => { },
	equ => { },
	macro => { },
	endm => { },

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

	r16 => { index => 16 },
	r17 => { index => 17 },
	r18 => { index => 18 },
	r19 => { index => 19 },
	r20 => { index => 20 },
	r21 => { index => 21 },
	r22 => { index => 22 },
	r23 => { index => 23 },
	r24 => { index => 24 },
	r25 => { index => 25 },
	r26 => { index => 26 },
	r27 => { index => 27 },
	r28 => { index => 28 },
	r29 => { index => 29 },
	r30 => { index => 30 },
	r31 => { index => 31 },

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

my %macros = ();

my $current_macro;

my $macro_id = 100;

my @lines = <>;
my $address = 0;
my $line = 0;

my @plines = map { process_pseudo_instructions($_); } @lines;

@lines = @plines;

print "v2.0 raw\n";

for my $pass (0..3) {

#print "\npass $pass\n\n";

	$address = 0;
	$line = 0;

	for(@lines) {
		chomp;

		$line++;

		s/;.*$//g;

		next if m/^\s*$/;

#print "[$_]\n";

		my ($sym, $ins, $ops) = parse($_);

# disabling macro processing as it's buggy
# use m4 instead

		if($pass == 0) {
	#		collect_macro($sym, $ins, $ops);
		}
		elsif($pass == 1) {
	#		process_macro($sym, $ins, $ops);
		}
		elsif($pass == 2) {
			collect_symbol($sym, $ins, $ops);
		}
		else {
			if($ins ne '') {
				print STDERR sprintf("%04x: %s\n", $address, $_);
				assemble($ins, $ops);
			}
		}
	}


#	if($pass == 1) {
#
#		for(@lines) {
#			chomp;
#			s/;.*$//g;
#			next if m/^\s*$/;
#			print "\t\t|$_|\n";
#		}
#	}
}


#print "\n\nsymbols\n-------\n";
#for(sort { $symbols{$a} <=> $symbols{$b} } keys %symbols) {
#	print sprintf("%s %x\n", $_, $symbols{$_});
#}

sub process_pseudo_instructions {

	my $_ = shift;	

	s/;.*$//g;

	return if m/^\s*$/;

#	print "[$_]\n";

	s/\bnop\b/add zero, zero, zero/gi;
	s/\binc\s+([a-z0-9]+)/addi \1, \1, 1/gi;
	s/\bdec\s+([a-z0-9]+)/addi \1, \1, -1/gi;
	s/\bjal\s+([a-z0-9]+)/jal ra, \1/gi;
	s/\bjalr\s+([a-z0-9]+)/jalr ra, \1/gi;
	s/\bclear\s+([a-z0-9]+)/add \1, zero, zero/gi;
	s/\bmove\s+([a-z0-9]+),\s*([a-z0-9]+)/add \1, \2, zero/gi;
	s/\bli\s+([a-z0-9]+),\s*([a-z0-9]+)/addi \1, zero, \2/gi;
	s/\bbgt\s+([a-z0-9]+),\s*([a-z0-9]+),\s*([a-z0-9]+)/slt at, \2, \1\nbne at, zero, \3/gi;
	s/\bblt\s+([a-z0-9]+),\s*([a-z0-9]+),\s*([a-z0-9]+)/slt at, \1, \2\nbne at, zero, \3/gi;
	s/\bbge\s+([a-z0-9]+),\s*([a-z0-9]+),\s*([a-z0-9]+)/slt at, \1, \2\nbeq at, zero, \3/gi;
	s/\bble\s+([a-z0-9]+),\s*([a-z0-9]+),\s*([a-z0-9]+)/slt at, \2, \1\nbeq at, zero, \3/gi;
	s/\bmul\s+([a-z0-9]+),\s*([a-z0-9]+),\s*([a-z0-9]+)/mul \2, \3\nmflo \1/gi;
	s/\bdiv\s+([a-z0-9]+),\s*([a-z0-9]+),\s*([a-z0-9]+)/mul \2, \3\nmflo \1/gi;
	s/\bpush\s+([a-z0-9]+)/addi sp, sp, -1\nsw \1, sp, 0/gi;
	s/\bpop\s+([a-z0-9]+)/lw \1, sp, 0\naddi sp, sp, -1/gi;
	s/\bnot\s+([a-z0-9]+)/nor \1, \1, \1/gi;
	s/\bneg\s+([a-z0-9]+)/nor \1, \1, \1\naddi \1, \1, 1/gi;

#	print "[$_]\n";

	return split /\n/;
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

			if(scalar @{$ops} == 1 && $ops->[0] =~ m/^\s*[0-9a-f]+\s*$/i) { # && $ops->[0] >= $address) {
				$address = hex $ops->[0];
			}
			else {
				die "line $line invalid origin: ".join(' ', @{$ops})."\n";
			}
		}
		elsif($ins eq 'dw') {
#			$address += scalar @{$ops};
			for(@{$ops}) {
				if(m/^\s*\"[^\"]*\"\s*$/i) {
					s/\"//g;
					for my $c (split //) {
						$address++;
					}
				}
				else {
					$address++;
				}
			}
		}
		elsif($ins eq 'align') {
			$address = $address % 2 == 0 ? $address : $address+1;
		}
		elsif($ins eq 'equ') {
			if(scalar @{$ops} == 1 && $ops->[0] =~ m/^[0-9a-f]+$/i) {
				$symbols{$sym} = hex $ops->[0];
			}
			else {
				die "line $line invalid equate: ".join(' ', @{$ops})."\n";
			}
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
				if(m/^\s*\"[^\"]*\"\s*$/i) {
					s/\"//g;
					for my $c (split //) {
						output_word(ord $c);
					}
				}
				elsif(m/^[a-z][a-z0-9]*$/i) {
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

	

	print STDERR sprintf("%s %s\n", $ins, join(', ', @{$ops}));

#	output_word($code);
#	output_word($oper);

	output_word($code << 16 |$oper);
}

sub type_1_instruction {

	my ($desc, $ins, $ops) = @_;

	if(scalar @{$ops} != 3) {
		die "line $line expected 3 operands for: '$ins'\n";
	}

	my $rd = get_register(shift @{$ops});
	my $rs = get_register(shift @{$ops});
	my $rt = get_register(shift @{$ops});

	my $code = $desc->{code} << 10 | $rd << 5 | $rs;
	my $oper = $rt << 11;

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

	my $code = $desc->{code} << 10 | $rd << 5 | $rs;
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

	my $code = $desc->{code} << 10 | $rs;
	my $oper = $rt << 11;

	return ($code, $oper);
}

sub mf {

	my ($desc, $ins, $ops) = @_;

	if(scalar @{$ops} != 1) {
		die "line $line expected 1 operands for: $ins\n";
	}

	my $rd = get_register(shift @{$ops});

	my $code = $desc->{code} << 10 | $rd << 5;
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

	my $disp = $const - ($address+1);

	#print "$address $const $disp\n";

	my $code = $desc->{code} << 10 | $rd << 5 | $rs;
	my $oper = $disp;

	return ($code, $oper);
}

sub j {

	my ($desc, $ins, $ops) = @_;

	if(scalar @{$ops} != 1) {
		die "line $line expected 1 operands for: $ins\n";
	}

	my $const = get_constant(shift @{$ops});

	my $code = $desc->{code} << 10;
	my $oper = $const;

	return ($code, $oper);
}

sub jr {

	my ($desc, $ins, $ops) = @_;

	if(scalar @{$ops} != 1) {
		die "line $line expected 1 operands for: $ins\n";
	}

	my $rt = get_register(shift @{$ops});

	my $code = $desc->{code} << 10;
	my $oper = $rt << 11;

	return ($code, $oper);
}

sub jal {

	my ($desc, $ins, $ops) = @_;

	if(scalar @{$ops} != 2) {
		die "line $line expected 2 operands for: $ins\n";
	}

	my $rd = get_register(shift @{$ops});
	my $const = get_constant(shift @{$ops});

	my $code = $desc->{code} << 10 | $rd << 5;
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

	my $code = $desc->{code} << 10 | $rd << 5;
	my $oper = $rt << 11;

	return ($code, $oper);
}

sub halt {

	my ($desc, $ins, $ops) = @_;

#	if(scalar @{$ops} != 0) {
#		die "line $line expected 0 operands for: '$ins' '".join(' ', @{$ops})."'\n";
#	}

	my $code = $desc->{code} << 10;
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

	if(m/^([a-z]+)/i) {
		$ins = $1;
		s/^$ins//i;
#		print "ins $ins [$_]\n";
	}

	my @ops = split(/,/);

	map { s/\s+//g unless m/\"/ } @ops;

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

	$val &= 0xffffffff;

	print sprintf("%08x\n", $val);
	$address++;
}


sub collect_macro {

	my ($sym, $ins, $ops) = @_;

	if($ins eq 'macro') {
		if(defined $current_macro) {
			die "line $line nested macro definition: $ins ".join(' ', @{$ops})."\n";
		}

		$current_macro = { name => shift @{$ops}, parameters => $ops, code => [], start => $line };

		$lines[$line-1] =~ s/^/;/;

#		print "defining ".$current_macro->{name}."\n";
	}	
	elsif($ins eq 'endm') {
		if(!defined $current_macro) {
			die "line $line endm without macro definition\n";
		}

		$current_macro->{end} = $line;

		$macros{$current_macro->{name}} = $current_macro;

#		print "done ".$current_macro->{name}."\n";
		for(@{$current_macro->{code}}) {
#			print "$_\n";
		}

		$lines[$line-1] =~ s/^/;/;

		$current_macro = undef;
	}
	elsif(defined $current_macro) {

		my $l = "";
		if(defined $sym) {
			push @{$current_macro->{symbols}}, $sym;
			$l .= "$sym: ";
		}

		$l .= "$ins ".join(', ', @{$ops});

		push @{$current_macro->{code}}, $l;

		$lines[$line-1] =~ s/^/;/;

#		print "$l\n";
	}

}

sub process_macro {

	my ($sym, $ins, $ops) = @_;

	my $m = $macros{$ins};

	if(defined $m) {

#		print Dumper($m);

#		print "replace ".$m->{name}."\n";
#		for(@{$m->{code}}) {
#			print "$_\n";
#		}

		my $mac = "";

		for(@{$m->{code}}) {
			$mac .= "$_\n";	
		}

		for(@{$m->{parameters}}) {
			my $r = shift @{$ops};
			$mac =~ s/\b$_/$r/g;
		}

		my $id = $macro_id++;

		for(@{$m->{symbols}}) {
#			print "\t$_\n";
			$mac =~ s/\b($_)/\1$id/gi;
		}


#		print "[$mac]\n";
	
		$lines[$line-1] =~ s/^/;/;
		splice(@lines, $line, 0, split('\n', $mac));

	}
}


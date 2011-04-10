
use strict;

my %instruction = (
	add => 0,
	addi => 1,
	sub => 2,
	mul => 3,
	div => 4,
	sll => 5,
	srl => 6,
	sra => 7,
	sllv => 8,
	srlv => 9,
	srav => 10,
	beq => 11,
	bne => 12,
	slt => 13,
	slti => 14,
	and => 15,
	andi => 16,
	or => 17,
	ori => 18,
	xor => 19,
	nor => 20,
	j => 21,
	jr => 22,
	jal => 23,
	jalr => 24,
	lw => 25,
	sw => 26,
	mfhi => 27,
	mflo => 28,
	halt => 30,
);


# symbol:	ins	rd, rs, rt	; comment
#		ins	rd, rs, C

my %symbols = ();

my $address = 0;

my @lines = <>;

for(@lines) {
	chomp;

	s/;.*$//g;

	next if m/^\s*$/;

	my $sym;

	if(m/^\s*([a-z][a-z0-9]*):/i) {
		$sym = $1;
	}

	print "s $sym\n";
	$symbols{$sym} = $address;

	my $ins;

	if(m/^\s*([a-z][a-z0-9]*:)?\s*([a-z]+)/i) {
		$ins = $2;
	}

	print "i $ins\n";

	my $op1;

	if(m/^\s*([a-z][a-z0-9]*:)?\s*([a-z]+)\s+([a-z0-9]+),?/i) {
		$op1 = $3;
	}

	print "1 $op1\n";

	my $op2;

	if(m/^\s*([a-z][a-z0-9]*:)?\s*([a-z]+)\s+([a-z0-9]+,)\s*([a-z0-9]+),?/i) {
		$op2 = $4;
	}

	print "2 $op2\n";

	my $op3;

	if(m/^\s*([a-z][a-z0-9]*:)?\s*([a-z]+)\s+([a-z0-9]+,)\s*([a-z0-9]+,)\s*([a-z0-9]+)/i) {
		$op3 = $5;
	}

	print "3 $op3\n";

#	print "$rest\n";

#	my $sym;
#	my $ins;
#	my $op1;
#	my $op2;
#	my $op3;
#
#	if(m/^\s*([a-z][a-z0-9]*:)?\s*([a-z]+)\s?([a-z0-9]+,)?\s*([a-z0-9]+,)?\s*([a-z0-9]+|[\-0-9]+)?/i) {
#		$sym = $1;
#		$ins = $2;
#		$op1 = $3;
#		$op2 = $4;
#		$op3 = $5;
#
#		print "s $sym\n";
#		print "i $ins\n";
#		print "1 $op1\n";
#		print "2 $op2\n";
#		print "3 $op3\n";
#	}
#	else {
#		print "error: $_\n";
#	}
#

#	my ($sym, $ins, $op1, $op2, $op3) = split /[:\t ,]/;

#	print "s $sym\ni $ins\n1 $op1\n2 $op2\n3 $op3\n";

#	$address++;
}

for(@lines) {
	chomp;
#	print "$_\n";
}


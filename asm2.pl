
use strict;

use Data::Dumper;


my %instruction = (

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
        brk => { code => 29, size => 2, type => 2 },
        halt => { code => 30, size => 2, type => 2 },
);

my %pseudo = (

	nop => {},
	inc => {},
	dec => {},
	clear => {},
	move => {},
	li => {},
	bgt => {},
	blt => {},
	bge => {},
	ble => {},
	mult => {},
	divi => {},
	push => {},
	pop => {},
	not => {},
	neg => {},
	jsr => {},
	ret => {}

);

my %directives = (

	'.org' => {},
	'.align' => {},
	'.word' => {},
	'.string' => {},
	'.set' => {},

);

my %regs = (

	r0 => { },
	r1 => { },
	r2 => { },
	r3 => { },
	r4 => { },
	r5 => { },
	r6 => { },
	r7 => { },
	r8 => { },
	r9 => { },
	r10 => { },
	r11 => { },
	r12 => { },
	r13 => { },
	r14 => { },
	r15 => { },

	zero => { },
	at => { },
	v0 => { },
	v1 => { },
	a0 => { },
	a1 => { },
	a2 => { },
	s0 => { },
	s1 => { },
	s2 => { },
	t0 => { },
	t1 => { },
	t2 => { },
	fp => { },
	sp => { },
	ra => { }

);


my @tokens = ();

my %symbols = ();

my $n = 0;
my $line;

while(<>) {

	chomp;

	$n++;

	s/;.*$//;

	next if m/^\s*$/;

	$line = $_;

	process_line($line);
}


collect_symbols();

my $org = 0;
my @mem = ();

assemble();

#print Dumper(\@tokens);

print Dumper(\%symbols);

#print Dumper(\@mem);

my $i = 0;
for(@mem) {
	printf "%04x %04x\n", $i++, $_;
}

sub next_token {

	return shift @tokens;
}

sub peek_next_token {

	return $tokens[0];
}

sub is_next_token {

	my $code = shift;
	my $tok = peek_next_token();

	return $tok->{code} eq $code;
}

sub expected_token {

	my $code = shift;
	my $tok = next_token();

	die "expected [$code] but got [$tok->{code}] at line $tok->{line}\n" if $tok->{code} ne $code;

	return $tok;
}

sub expected_tokens {

	my @codes = @_;
	my $tok = next_token();

	for(@codes) {
		if($tok->{code} eq $_) {
			return $tok;
		}
	}

	die "expected one of [".join(' or ', @codes)."] but got [$tok->{code}] at line $tok->{line}\n";
}

sub assemble {

	while(my $tok = next_token()) {

		directive($tok) if $tok->{code} eq 'dir';
	}
}


sub directive {

	my $tok = shift;

	my $dir = $tok->{token};

	printf "%04x %s\n", $org, $dir;

	if($dir eq '.org') {
		my $t = expected_token('number');
		$org = $t->{value};
	}
	elsif($dir eq '.set') {
		my $t = expected_token('symbol');
		expected_token('comma');
		my $n = expected_token('number');
		$symbols{$t->{token}}->{value} = $n->{value};	
	}
	elsif($dir eq '.word') {

		while(1) {

			my $t = expected_tokens('number', 'symbol');

			if($t->{code} eq 'number') {
				write_mem($org++, $t->{value});
			}
			else {
				if(defined $symbols{$t->{token}}->{value}) {
					write_mem($org++, $symbols{$t->{token}}->{value});
				}
				else {
					push @{$symbols{$t->{token}}->{references}}, $org;
					$org++;
				}
			}
			

			if(!is_next_token('comma')) {
				return;
			}

			expected_token('comma');
		}
	}
}


sub write_mem {

	my ($addr, $value) = @_;

	$mem[$addr] = $value & 0xffff;
}

sub collect_symbols {


	for(@tokens) {

		next if $_->{code} !~ m/symbol|label/;

		my $code = $_->{code};
		my $token = $_->{token};

		$token =~ s/:$// if $code eq 'label';

#		print "$token $code\n";
		$symbols{$token} = { token => $token, references => [] };
	}
}



sub process_line {

	my $line = shift;


#	printf "%05d  %s\n", $n, $line;


	my @chars = split(//, $line);
	my $i = 0;
	my $tok = '';
	my $col = 0;
	my $str = 0;
	my $targ = '';

	while($i <= $#chars) {

		my $ch = $chars[$i];
	
		$i++;

		if($str) {
			$tok .= $ch;
			if($ch eq $targ) {
				$str = 0;
				token($tok);
			}
		}
		elsif($ch =~ m/\s/) {
			if($col) {
				token($tok);
				$col = 0;
			}
		}
		elsif($ch =~ m/[a-zA-Z0-9_-]/) {

			if($col) {
				$tok .= $ch;
			}
			else {
				$col = 1;
				$tok = $ch;
			}
		}
		elsif($ch eq '.') {
			if($col) {
				token($tok);
			}

			$col = 1;
			$tok = $ch;
		}
		elsif($ch eq ':') {
			if($col) {
				$tok .= $ch;
				token($tok);
				$col = 0;
			}
		}
		elsif($ch =~ m/[,\$+\/\*-]/) {

			if($col) {
				token($tok);
				$col = 0;
			}

			token($ch);
		}
		elsif($ch =~ m/['"]/) {

			$str = 1;
			$targ = $ch;
			$tok = $ch;
		}
		else {
			print "$col $str $ch $tok\n";
			die "unexpected char [$ch] at line $n\n";
		}
	}

	#print "EOL\n";

	if($col) {
		token($tok);
	}

	if($str) {
		die;
	}

}

sub token {

	my $token = shift;

	my $code = '';

	if($instruction{$token}) {
		$code = 'ins';
	}
	elsif($regs{$token}) {
		$code = 'reg';
	}
	elsif($pseudo{$token}) {
		$code = 'pseudo';
	}
	elsif($directives{$token}) {
		$code = 'dir';
	}
	elsif($token =~ m/^[a-zA-Z_][a-zA-Z0-9_-]*:$/) {
		$code = 'label'
	}
	elsif($token eq ',') {
		$code = 'comma';
	}
	elsif($token eq '$') {
		$code = 'address';
	}
	elsif($token eq '+') {
		$code = 'plus';
	}
	elsif($token eq '-') {
		$code = 'minus';
	}
	elsif($token eq '/') {
		$code = 'divide';
	}
	elsif($token eq '*') {
		$code = 'multiply';
	}
	elsif($token =~ m/^['"].*['"]$/) {
		$code = 'string';
	}
	elsif($token =~ m/^-?0[0-7]+$/) {
		$code = 'number';
	}
	elsif($token =~ m/^-?0x[0-9a-fA-F]+$/) {
		$code = 'number';
	}
	elsif($token =~ m/^-?0b[01]+$/) {
		$code = 'number';
	}
	elsif($token =~ m/^-?[0-9]+$/) {
		$code = 'number';
	}
	elsif($token =~ m/^[a-zA-Z_][a-zA-Z0-9_-]*/) {
		$code = 'symbol';
	}
	else {
		die "$line\n\n\tunknown symbol '$token' at line $n\n\n";
	}

	my $value = undef;
	if($code eq 'number') {
		$value = $token;
		$value =~ s/^-//;
		$value = oct($value) if $value =~ m/^0/;
		$value = -$value if $token =~ m/^-/;
	}

#	print "token: [$token] $code $value\n";

	push @tokens,  { token => $token, code => $code, value => $value, line => $n };
}



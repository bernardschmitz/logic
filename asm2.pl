
use strict;
use warnings;

use Data::Dumper;


my %instructions = (

        add => { op => 0, size => 2, type => 0, mnemonic => 'add' },
        addi => { op => 1, size => 2, type => 1, mnemonic => 'addi' },
        sub => { op => 2, size => 2, type => 0, mnemonic => 'sub' },
        mul => { op => 3, size => 2, type => 2, mnemonic => 'mul' },
        div => { op => 4, size => 2, type => 2, mnemonic => 'div' },
        sll => { op => 5, size => 2, type => 1, mnemonic => 'sll' },
        srl => { op => 6, size => 2, type => 1, mnemonic => 'srl' },
        sra => { op => 7, size => 2, type => 1, mnemonic => 'sra' },
        sllv => { op => 8, size => 2, type => 0, mnemonic => 'sllv' },
        srlv => { op => 9, size => 2, type => 0, mnemonic => 'srlv' },
        srav => { op => 10, size => 2, type => 0, mnemonic => 'srav' },
        beq => { op => 11, size => 2, type => 2, mnemonic => 'beq' },
        bne => { op => 12, size => 2, type => 2, mnemonic => 'bne' },
        slt => { op => 13, size => 2, type => 0, mnemonic => 'slt' },
        slti => { op => 14, size => 2, type => 1, mnemonic => 'slti' },
        and => { op => 15, size => 2, type => 0, mnemonic => 'and' },
        andi => { op => 16, size => 2, type => 1, mnemonic => 'andi' },
        or => { op => 17, size => 2, type => 0, mnemonic => 'or' },
        ori => { op => 18, size => 2, type => 1, mnemonic => 'ori' },
        xor => { op => 19, size => 2, type => 0, mnemonic => 'xor' },
        nor => { op => 20, size => 2, type => 0, mnemonic => 'nor' },
        j => { op => 21, size => 2, type => 2, mnemonic => 'j' },
        jr => { op => 22, size => 2, type => 2, mnemonic => 'jr' },
        jal => { op => 23, size => 2, type => 2, mnemonic => 'jal' },
        jalr => { op => 24, size => 2, type => 2, mnemonic => 'jalr' },
        lw => { op => 25, size => 2, type => 1, mnemonic => 'lw' },
        sw => { op => 26, size => 2, type => 1, mnemonic => 'sw' },
        mfhi => { op => 27, size => 2, type => 2, mnemonic => 'mfhi' },
        mflo => { op => 28, size => 2, type => 2, mnemonic => 'mflo' },
        brk => { op => 29, size => 2, type => 2, mnemonic => 'brk' },
        halt => { op => 30, size => 2, type => 2, mnemonic => 'halt' },
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


my @tokens = ();

my %symbols = ();

my $ln = 0;

my $line;

while(<>) {

	chomp;

	$ln++;

	s/;.*$//;

	next if m/^\s*$/;

	$line = $_;

	process_line($line);
}


collect_symbols();

my $org = 0;
my @mem = ();

assemble();

resolve_symbols();

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

	return defined $tok && $tok->{code} eq $code;
}

#sub expected_token {
#
#	my $code = shift;
#	my $tok = next_token();
#
#	die "expected [$code] but got [$tok->{code}] at line $tok->{line}\n" if $tok->{code} ne $code;
#
#	return $tok;
#}

sub expected_token {

	my @codes = @_;
	my $tok = next_token();

	for(@codes) {
		if($tok->{code} eq $_) {
			return $tok;
		}
	}

	if(scalar @codes == 1) {
		die "$tok->{line}\n\texpected [$codes[0]] but got [$tok->{code}] at line $tok->{ln}\n";
	}

	die "$tok->{line}\n\texpected one of [".join(' or ', @codes)."] but got [$tok->{code}] at line $tok->{ln}\n";
}

sub assemble {

	while(my $tok = next_token()) {

		#printf "%04x %s %s\n", $org, $tok->{code}, $tok->{token};

		my $code = $tok->{code};

		if($code eq 'symbol') {
			label($tok);
		}
		elsif($code eq 'dir') {
			directive($tok);
		}
		elsif($code eq 'ins') {
			instruction($tok);
		}
		elsif($code eq 'pseudo') {
			pseudo($tok);
		}
		else {
			die "$tok->{line}\n\tunexpected token [$tok->{token}] at line $tok->{ln}\n";
		}
	}
}

sub pseudo {

	my $tok = shift;

	my $ps = $pseudo{$tok->{token}};

	if($ps->{mnemonic} eq 'move') {

		print "move\n";
	}	
}

sub instruction {

	my $tok = shift;

	my $ins = $instructions{$tok->{token}};
	
	my $ir = $ins->{op} << 8;
	my $op = 0;

	if($ins->{type} == 0) {

		my $r = expected_token('reg');
		$ir = $ir | ( $regs{$r->{token}}->{index} << 4);
		expected_token('comma');
	
		$r = expected_token('reg');
		$ir = $ir | $regs{$r->{token}}->{index} ;
		expected_token('comma');

		$r = expected_token('reg');
		$op = $op | ($regs{$r->{token}}->{index} << 12);

		write_mem($org++, $ir);
		write_mem($org++, $op);
	}
	elsif($ins->{type} == 1) {

		my $r = expected_token('reg');
		$ir = $ir | ( $regs{$r->{token}}->{index} << 4);
		expected_token('comma');
	
		$r = expected_token('reg');
		$ir = $ir | $regs{$r->{token}}->{index} ;
		expected_token('comma');

		$r = expected_token('number', 'symbol');
		$op = $r->{value};
		if($r->{code} eq 'symbol') {
			push @{$symbols{$r->{token}}->{references}}, $org+1;
		}

		write_mem($org++, $ir);
		write_mem($org++, $op);
	}
	elsif($ins->{type} == 2) {
	
		if($ins->{mnemonic} eq 'j') {

			my $r = expected_token('number', 'symbol');
			$op = $r->{value};
			if($r->{code} eq 'symbol') {
				push @{$symbols{$r->{token}}->{references}}, $org+1;
			}

			write_mem($org++, $ir);
			write_mem($org++, $op);
		}
		elsif($ins->{mnemonic} eq 'jr') {

			my $r = expected_token('reg');
			$op = $regs{$r->{token}}->{index} << 12;

			write_mem($org++, $ir);
			write_mem($org++, $op);
		}
		elsif($ins->{mnemonic} eq 'jal') {

			my $r = expected_token('reg');
			$ir = $ir | ($regs{$r->{token}}->{index} << 4);

			expected_token('comma');

			$r = expected_token('number', 'symbol');
			$op = $r->{value};
			if($r->{code} eq 'symbol') {
				push @{$symbols{$r->{token}}->{references}}, $org+1;
			}

			write_mem($org++, $ir);
			write_mem($org++, $op);
		}
		elsif($ins->{mnemonic} eq 'jalr') {

			my $r = expected_token('reg');
			$ir = $ir | ($regs{$r->{token}}->{index} << 4);

			expected_token('comma');

			$r = expected_token('reg');
			$ir = $ir | $regs{$r->{token}}->{index};

			write_mem($org++, $ir);
			write_mem($org++, $op);
		}
		elsif($ins->{mnemonic} =~ m/mul|div/) {

			my $r = expected_token('reg');
			$ir = $ir | $regs{$r->{token}}->{index};

			expected_token('comma');

			$r = expected_token('reg');
			$op = $regs{$r->{token}}->{index} << 12;

			write_mem($org++, $ir);
			write_mem($org++, $op);
		}
		elsif($ins->{mnemonic} =~ m/bne|beq/) {

			my $r = expected_token('reg');
			$ir = $ir | ($regs{$r->{token}}->{index} << 4);

			expected_token('comma');

			$r = expected_token('reg');
			$ir = $ir | $regs{$r->{token}}->{index};

			expected_token('comma');

			$r = expected_token('number', 'symbol');
			$op = $r->{value};
			if($r->{code} eq 'symbol') {
				push @{$symbols{$r->{token}}->{references}}, $org+1;
			}

			write_mem($org++, $ir);
			write_mem($org++, $op);
		}
		elsif($ins->{mnemonic} =~ m/mfhi|mflo/) {

			my $r = expected_token('reg');
			$ir = $ir | ($regs{$r->{token}}->{index} << 4);

			write_mem($org++, $ir);
			write_mem($org++, $op);
		}
		elsif($ins->{mnemonic} =~ m/brk|halt/) {

			write_mem($org++, $ir);
			write_mem($org++, $op);
		}
	}
	else {
		die "internal failure\n";
	}
	
}

sub label {

	my $tok = shift;

	$symbols{$tok->{token}}->{value} = $org;
}


sub directive {

	my $tok = shift;

	my $dir = $tok->{token};

#	printf "%04x %s\n", $org, $dir;

	if($dir eq '.org') {
		my $t = expected_token('number');
		$org = $t->{value};
	}
	elsif($dir eq '.align') {
		$org = ($org + 1) & 0xfffe;
	}
	elsif($dir eq '.set') {
		my $t = expected_token('symbol');
		expected_token('comma');
		my $n = expected_token('number');
		$symbols{$t->{token}}->{value} = $n->{value};	
	}
	elsif($dir eq '.word') {

		while(1) {

			my $t = expected_token('number', 'symbol');

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
	elsif($dir eq '.string') {
		while(1) {
			my $t = expected_token('string');

			for(split(//, $t->{value})) {
				write_mem($org++, ord $_);
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

	return if !defined $value;

	$mem[$addr] = $value & 0xffff;
}

sub collect_symbols {


	for(@tokens) {

		#next if $_->{code} !~ m/symbol|label/;
		next if $_->{code} ne 'symbol';

		my $code = $_->{code};
		my $token = $_->{token};
		my $ln = $_->{ln};
		my $line = $_->{line};

#		$token = $_->{value} if $code eq 'label';

#		print "$token $code\n";
		$symbols{$token} = { token => $token, references => [], ln => $ln, line => $line, value => undef };
	}
}

sub resolve_symbols {

	for(values %symbols) {

		if(!defined $_->{value}) {
			die "$_->{line}\n\tundefined symbol [$_->{token}] at $_->{ln}\n";
		}
		else {
			my $val = $_->{value};
			for(@{$_->{references}}) {
				write_mem($_, $val);
			}
		}
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
#			print "$col $str $ch $tok\n";
			die "$line\n\tunexpected char [$ch] at line $ln\n";
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

	if($instructions{$token}) {
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
#	elsif($token =~ m/^[a-zA-Z_][a-zA-Z0-9_-]*:$/) {
#		$code = 'label'
#	}
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
	elsif($token =~ m/^[a-zA-Z_][a-zA-Z0-9_-]*:?$/) {
		$code = 'symbol';
	}
	else {
		die "$line\n\n\tunknown symbol '$token' at line $ln\n\n";
	}

	my $value = undef;
	if($code eq 'number') {
		$value = $token;
		$value =~ s/^-//;
		$value = oct($value) if $value =~ m/^0/;
		$value = -$value if $token =~ m/^-/;
	}

	if($code eq 'string') {
		$value = $token;
		$value =~ s/[']//g if $token =~ m/^'/;
		$value =~ s/["]//g if $token =~ m/^"/;
	}

	if($code eq 'symbol') {
		$token =~ s/:$//;
	}

#	print "token: [$token] $code $value\n";

	push @tokens,  { token => $token, code => $code, value => $value, ln => $ln, line => $line };
}



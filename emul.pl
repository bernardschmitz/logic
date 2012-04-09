
use strict;

use Term::ReadKey;
use Time::HiRes qw(usleep);

my @mem = ();


print "$ARGV[0]\n";

open IN, "<$ARGV[0]" or die "$!";

my @bin = <IN>;

close IN;

shift @bin;

for(@bin) {
	chomp;
	push @mem, hex $_;
}

for(0..1024) {
	push @mem, 0x1f00;
	push @mem, 0x0000;
}



#for(@mem) {
#	print sprintf("%04x\n", $_);
#}

$| = 1;

srand(0xcafebabe);

my $pc = 0;

my @reg = ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );

my $op = 0;
my $ir = 0;

my $result = 0;
my $hi = 0;
my $lo = 0;

my $clock = 0;

my $timer_lo = 0xf000;
my $timer_hi = 0xf001;
my $random = 0xf002;
my $buffer_clear = 0xfffb;
my $char_ready = 0xfffc;
my $char_in = 0xfffd;
my $char_out = 0xfffe;
my $screen_clear = 0xffff;

my %instruction = ();

my $ins = 0;
my $rd = 0;
my $rs = 0;
my $rt = 0;

my %read_memory = ();
my %written_memory = ();

my $keyboard_buf = '';

init();

my $halt = 0;


while(!$halt) {

	$ir = read_mem($pc);
	$pc++;
	$clock += 2;

	$op = read_mem($pc);
	$pc++;
	$clock += 2;

	$ins = ($ir >> 8) & 0x1f;
	$rd = ($ir >> 4) & 0xf;
	$rs = $ir & 0xf;
	$rt = ($op >> 12) & 0xf;

	printf STDERR "%04x %02x %01x %01x %01x %04x %08x\n", $pc-2, $ins, $rd, $rs, $rt, $op, $clock;

	if(!defined $instruction{$ins}) {
		die "invalid instruction";
	}

	$instruction{$ins}();

	$reg[0] = 0;

	for(@reg) {
		$_ &= 0xffff;
	}

	for(@reg) {
		printf STDERR "%04x ", $_;
	}
	print STDERR  "\n";

	$pc &= 0xffff;
	printf STDERR "%04x\n", $pc;


	ReadMode 3;
	my $char = ReadKey(-1);
	ReadMode 0;

	if(defined $char) {
		$keyboard_buf .= $char;
#print "\nkb: $keyboard_buf\n";
	}


	usleep(100);
}


print STDERR "\nread mem\n";

for(sort { $a <=> $b } keys %read_memory) {
	printf STDERR "%04x %08x %04x\n", $_, $read_memory{$_}, $mem[$_];
}

print "\n";

print STDERR "\nwrite mem\n";
for(sort { $a <=> $b } keys %written_memory) {
	printf STDERR "%04x %08x %04x\n", $_, $written_memory{$_}, $mem[$_];
}

print "\n";




sub read_mem($) {

	my $addr = shift;

	$addr &= 0xffff;
	$read_memory{$addr}++;	

	if($addr == $random) {
		return int(rand(0x10000));
	}
	elsif($addr == $timer_lo) {
		return $clock & 0xffff;
	}
	elsif($addr == $timer_hi) {
		return ($clock >> 16) & 0xffff;
	}
	elsif($addr == $char_in) {

#print "char in\n";

		if($keyboard_buf eq '') {
			ReadMode 3;
			my $char = ReadKey(-1);
			ReadMode 0;
			return $char;
		}

		my $ch = substr($keyboard_buf, 0, 1);
	 	$keyboard_buf = substr($keyboard_buf, 1);
#print "ch: $ch\n";
		return ord $ch;
	}
	elsif($addr == $char_ready) {

#print "char rdy\n";

		if($keyboard_buf eq '') {
			return 0;
		}

		return 1;
	}

	return $mem[$addr];
}

sub write_mem($ $) {

	my ($addr, $x) = @_;

	$addr &= 0xffff;
	$written_memory{$addr}++;	

	if($addr == $char_out) {
#print "char: $x\n";
		print chr($x & 0x7f);
		return;
	}
	elsif($addr == $buffer_clear) {
		$keyboard_buf = '';
		return;
	}
	elsif($addr == $screen_clear) {
		for(0..20) {
			print "\n";
		}
		return;
	}

	$mem[$addr] = $x;
}


sub init() {

	$instruction{0x00} = sub() {
		print STDERR "add\n";	
		$reg[$rd] = $reg[$rs] + $reg[$rt];
		$clock += 2;
	};

	$instruction{0x01} = sub() {
		print STDERR "addi\n";	
		$reg[$rd] = $reg[$rs] + $op;
		$clock += 2;
	};

	$instruction{0x02} = sub() {
		print STDERR "sub\n";	
		$reg[$rd] = $reg[$rs] - $reg[$rt];
		$clock += 2;
	};

	$instruction{0x03} = sub() {
		print STDERR "mul\n";	
		$result = $reg[$rs] * $reg[$rt];
		$hi = ($result >> 16) & 0xffff;
		$lo = $result & 0xffff;
		$clock++;
	};

	$instruction{0x04} = sub() {
		print STDERR "div\n";	

		if($reg[$rt] == 0) {
			$hi = 0;
			$lo = $reg[$rs];
		}
		else {
			$lo = int($reg[$rs] / $reg[$rt]) & 0xffff;
			$hi = int($reg[$rs] % $reg[$rt]) & 0xffff;
		}
		$clock++;
	};

	$instruction{0x05} = sub() {
		print STDERR "sll\n";
		$reg[$rd] = $reg[$rs] << ($op & 0xf);	
		$clock += 2;	
	};

	$instruction{0x06} = sub() {
		print STDERR "srl\n";
		$reg[$rd] = $reg[$rs] >> ($op & 0xf);	
		$clock += 2;	
	};

	$instruction{0x07} = sub() {
		print STDERR "sra\n";
		$reg[$rd] = $reg[$rs] >> ($op & 0xf);	
		my $mask = 0xffff >> ($op & 0xf);
		$reg[$rd] &= $mask;
		$clock += 2;	
	};

	$instruction{0x08} = sub() {
		print STDERR "sllv\n";	
		$reg[$rd] = $reg[$rs] << ($reg[$rt] & 0xf);
		$clock += 2;
	};

	$instruction{0x09} = sub() {
		print STDERR "srlv\n";	
		$reg[$rd] = $reg[$rs] >> ($reg[$rt] & 0xf);
		$clock += 2;
	};

	$instruction{0x0a} = sub() {
		print STDERR "srav\n";
		$reg[$rd] = $reg[$rs] >> ($reg[$rt] & 0xf);	
		my $mask = 0xffff >> ($op & 0xf);
		$reg[$rd] &= $mask;
		$clock += 2;	
	};

	$instruction{0x0b} = sub() {
		print STDERR "beq\n";	
		if($reg[$rs] == $reg[$rd]) {
			$pc += ($op << 1);
		}
		$clock += 2;


	};

	$instruction{0x0c} = sub() {
		print STDERR "bne\n";	
		if($reg[$rs] != $reg[$rd]) {
			$pc += ($op << 1);
		}
		$clock += 2;
	};

	$instruction{0x0d} = sub() {
		print STDERR "slt\n";	
		if($reg[$rs] < $reg[$rt]) {
			$reg[$rd] = 1;
		}
		else {
			$reg[$rd] = 0;
		}
		$clock += 2;
	};

	$instruction{0x0e} = sub() {
		print STDERR "slti\n";	
		if($reg[$rs] < $op) {
			$reg[$rd] = 1;
		}
		else {
			$reg[$rd] = 0;
		}
		$clock += 2;
	};


	$instruction{0x0f} = sub() {
		print STDERR "and\n";	
		$reg[$rd] = $reg[$rs] & $reg[$rt];
		$clock += 2;
	};

	$instruction{0x10} = sub() {
		print STDERR "andi\n";	
		$reg[$rd] = $reg[$rs] & $op;
		$clock += 2;
	};

	$instruction{0x11} = sub() {
		print STDERR "or\n";	
		$reg[$rd] = $reg[$rs] | $reg[$rt];
		$clock += 2;
	};

	$instruction{0x12} = sub() {
		print STDERR "ori\n";	
		$reg[$rd] = $reg[$rs] | $op;
		$clock += 2;
	};

	$instruction{0x13} = sub() {
		print STDERR "xor\n";	
		$reg[$rd] = $reg[$rs] ^ $reg[$rt];
		$clock += 2;
	};

	$instruction{0x14} = sub() {
		print STDERR "nor\n";	
		$reg[$rd] = ~($reg[$rs] | $reg[$rt]);
		$clock += 2;
	};


	$instruction{0x15} = sub() {
		print STDERR "j\n";	
		$pc = $op;
		$clock++;
	};

	$instruction{0x16} = sub() {
		print STDERR "jr\n";	
		$pc = $reg[$rt];
		$clock++;
	};

	$instruction{0x17} = sub() {
		print STDERR "jal\n";	
		$reg[$rd] = $pc;
		$pc = $op;
		$clock += 2;
	};

	$instruction{0x18} = sub() {
		print STDERR "jalr\n";	
		$reg[$rd] = $pc;
		$pc = $reg[$rt];
		$clock += 2;
	};

	$instruction{0x19} = sub() {
		print STDERR "lw\n";	
		$reg[$rd] = read_mem($reg[$rs]+$op);
		$clock += 2;
	};

	$instruction{0x1a} = sub() {
		print STDERR "sw\n";	
		write_mem($reg[$rs]+$op, $reg[$rd]);
		$clock += 2;
	};
 
	$instruction{0x1b} = sub() {
		print STDERR "mfhi\n";	
		$reg[$rd] = $hi;
		$clock++;
	};
 
	$instruction{0x1c} = sub() {
		print STDERR "mflo\n";	
		$reg[$rd] = $lo;
		$clock++;
	};
 
	$instruction{0x1f} = sub() {
		print STDERR "halt\n";	
		$halt = 1;
	};
 

}



use strict;

my @mem = ();

my @bin = <>;

shift @bin;

for(@bin) {
	chomp;
	push @mem, hex $_;

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

init();


while(1) {

	$ir = read_mem($pc);
	$pc++;
	$clock++;

	$op = read_mem($pc);
	$pc++;
	$clock++;

	$ins = ($ir >> 8) & 0x1f;
	$rd = ($ir >> 4) & 0xf;
	$rs = $ir & 0xf;
	$rt = ($op >> 12) & 0xf;


	printf STDERR "%04x %08x %02x %01x %01x %01x %04x\n", $pc, $clock, $ins, $rd, $rs, $rt, $op;

	if(!defined $instruction{$ins}) {
		die "invalid instruction";
	}

	$instruction{$ins}();

	$reg[0] = 0;

	for(@reg) {
		printf STDERR "%04x ", $_;
	}
	print STDERR  "\n";

}

sub read_mem($) {

	my $addr = shift;

	if($addr == $random) {
		return int(rand(0x10000));
	}

	return $mem[$addr];
}

sub write_mem($ $) {

	my ($addr, $x) = @_;

	if($addr == $char_out) {
		print chr($x & 0x7f);
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

	$instruction{0x10} = sub() {
		print STDERR "andi\n";	
		$reg[$rd] = $reg[$rs] & $op;
		$clock += 2;
	};

	$instruction{0x15} = sub() {
		print STDERR "j\n";	
		$pc = $op;
		$clock++;
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


}


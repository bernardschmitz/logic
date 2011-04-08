
use strict;

my $op_t = 4;

my %microcode = (
	add => [
		{ fetch => 0, op => 0, t => $op_t }, [ { reg_src2_src => 0, alu_op => 0, result => 1 }, { reg_wrt => 1, reg_src => 0, t_reset => 1, fetch => 1 } ]
	],

	fetch => [
		{ fetch => 1, op => 0, t => 0 }, [
			{ fetch => 1, mar_src => 0, ir_wrt => 1 },
			{ fetch => 1, pc_src => 0, pc_wrt => 1 },
			{ fetch => 1, mar_src => 0, op_wrt => 1 },
			{ fetch => 0, pc_src => 0, pc_wrt => 1 },
		]
	],
);



for my $ins (keys %microcode) {

	print "$ins\n";

	my $addr_desc = $microcode{$ins}->[0];
	my $ins_desc = $microcode{$ins}->[1];

	my $address = $addr_desc->{fetch} << 9 | $addr_desc->{op} << 4 | $addr_desc->{t} ;

	
	for(@{$ins_desc}) {

		my $code = $_->{halt} << 23 | $_->{t_reset} << 22 | $_->{fetch} << 21 ;

		print sprintf("%03x %06x\n", $address, $code);	
	}


}



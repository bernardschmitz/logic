
use strict;

my $op_t = 4;

my %microcode = (

	fetch => [
		{ fetch => 1, op => 0, t => 0 }, [
			{ fetch => 1, mar_src => 0, ir_wrt => 1 },
			{ fetch => 1, pc_src => 0, pc_wrt => 1 },
			{ fetch => 1, mar_src => 0, op_wrt => 1 },
			{ fetch => 0, pc_src => 0, pc_wrt => 1 },
		]
	],

	add => [
		{ fetch => 0, op => 0, t => $op_t }, [ 
			{ alu_b_src => 0, alu_op => 0, result_wrt => 1 }, 
			{ reg_wrt => 1, reg_src => 0, t_reset => 1, fetch => 1 } 
		]
	],

	addi => [
		{ fetch => 0, op => 1, t => $op_t }, [ 
			{ alu_b_src => 1, alu_op => 0, result_wrt => 1 }, 
			{ reg_wrt => 1, reg_src => 0, t_reset => 1, fetch => 1 } 
		]
	],

	j => [
		{ fetch => 0, op => 0x15, t => $op_t }, [ 
			{ pc_src => 2, pc_wrt => 1, t_reset => 1, fetch => 1 } 
		]
	],

	slt => [
		{ fetch => 0, op => 0xd, t => $op_t }, [ 
			{ alu_b_src => 0, alu_op => 0, result_wrt => 0 }, 
			{ reg_wrt => 1, reg_src => 1, t_reset => 1, fetch => 1 } 
		]
	],

	beq => [
		{ fetch => 0, op => 0xb, t => $op_t }, [ 
			{ alu_b_src => 0, reg_src2_src => 1, alu_op => 0, result_wrt => 0 }, 
			{ pc_src => 1, pc_wrt => 2, t_reset => 1, fetch => 1 } 
		]
	],

	lw => [
		{ fetch => 0, op => 0x19, t => $op_t }, [ 
			{ alu_b_src => 1, alu_op => 0, result_wrt => 1 }, 
			{ mar_src => 1, reg_wrt => 1, reg_src => 5, t_reset => 1, fetch => 1 } 
		]
	],

 
);



for my $ins (keys %microcode) {

	print "$ins\n";

	my $addr_desc = $microcode{$ins}->[0];
	my $ins_desc = $microcode{$ins}->[1];

	my $address = $addr_desc->{fetch} << 9 | $addr_desc->{op} << 4 | $addr_desc->{t} ;

	
	for(@{$ins_desc}) {

		my $code = $_->{halt} << 23 | $_->{t_reset} << 22 | $_->{fetch} << 21 | $_->{pc_src} << 19 |
				$_->{pc_wrt} << 17 | $_->{mar_src} << 16 | $_->{mem_wrt} << 15 | $_->{ir_wrt} << 14 |
				$_->{op_wrt} << 13 | $_->{reg_src} << 10 | $_->{reg_wrt} << 9 | $_->{alu_b_src} << 8 |
				$_->{reg_src2_src} << 7 | $_->{alu_op} << 3 | $_->{result_wrt} << 2 | $_->{lo_wrt} << 1 |
				$_->{hi_wrt};

		print sprintf("%03x %06x\n", $address, $code);	

		$address++;
	}


}



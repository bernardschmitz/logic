
use strict;

my $op_t = 4;

my $reg_src2_src_rt = 0;
my $reg_src2_src_rd = 1;

my $mar_src_pc = 0;
my $mar_src_result = 1;

my $alu_b_src_reg2 = 0;
my $alu_b_src_op = 1;

my $pc_wrt_0 = 0;
my $pc_wrt_1 = 1;
my $pc_wrt_alu_eq = 2;
my $pc_wrt_not_alu_eq = 3;

my $pc_src_pc_inc = 0;
my $pc_src_pc_op = 1;
my $pc_src_op = 2;
my $pc_src_reg2 = 3;

my $reg_src_result = 0;
my $reg_src_alu_lt = 1;
my $reg_src_pc = 2;
my $reg_src_hi = 3;
my $reg_src_lo = 4;
my $reg_src_mem = 5;

my $alu_op_add = 0;
my $alu_op_sub = 1;
my $alu_op_sll = 2;
my $alu_op_srl = 3;
my $alu_op_sra = 4;
my $alu_op_and = 5;
my $alu_op_or = 6;
my $alu_op_nor = 7;
my $alu_op_xor = 8;
my $alu_op_mul = 9;
my $alu_op_div = 10;

my $ins_add = 0;
my $ins_addi = 1;
my $ins_sub = 2;
my $ins_mul = 3;
my $ins_div = 4;
my $ins_sll = 5;
my $ins_srl = 6;
my $ins_sra = 7;
my $ins_sllv = 8;
my $ins_srlv = 9;
my $ins_srav = 10;
my $ins_beq = 11;
my $ins_bne = 12;
my $ins_slt = 13;
my $ins_slti = 14;
my $ins_and = 15;
my $ins_andi = 16;
my $ins_or = 17;
my $ins_ori = 18;
my $ins_xor = 19;
my $ins_nor = 20;
my $ins_j = 21;
my $ins_jr = 22;
my $ins_jal = 23;
my $ins_jalr = 24;
my $ins_lw = 25;
my $ins_sw = 26;
my $ins_mfhi = 27;
my $ins_mflo = 28;
my $ins_unused = 29;
my $ins_halt = 30;


my %microcode = (

	fetch => [
		{ fetch => 1, op => 0, t => 0 }, [
			{ fetch => 1, mar_src => $mar_src_pc, ir_wrt => 1 },
			{ fetch => 1, pc_src => $pc_src_pc_inc, pc_wrt => $pc_wrt_1 },
			{ fetch => 1, mar_src => $mar_src_pc, op_wrt => 1 },
			{ fetch => 0, pc_src => $pc_src_pc_inc, pc_wrt => $pc_wrt_1 },
		]
	],

	add => [
		{ fetch => 0, op => $ins_add, t => $op_t }, [ 
			{ alu_b_src => $alu_b_src_reg2, alu_op => $alu_op_add, result_wrt => 1 }, 
			{ reg_wrt => 1, reg_src => $reg_src_result, t_reset => 1, fetch => 1 } 
		]
	],

	addi => [
		{ fetch => 0, op => $ins_addi, t => $op_t }, [ 
			{ alu_b_src => $alu_b_src_op, alu_op => $alu_op_add, result_wrt => 1 }, 
			{ reg_wrt => 1, reg_src => $reg_src_result, t_reset => 1, fetch => 1 } 
		]
	],

	j => [
		{ fetch => 0, op => $ins_j, t => $op_t }, [ 
			{ pc_src => $pc_src_op, pc_wrt => $pc_wrt_1, t_reset => 1, fetch => 1 } 
		]
	],

	slt => [
		{ fetch => 0, op => $ins_slt, t => $op_t }, [ 
			{ alu_b_src => $alu_b_src_reg2, alu_op => $alu_op_add, result_wrt => 0 }, 
			{ reg_wrt => 1, reg_src => $reg_src_alu_lt, t_reset => 1, fetch => 1 } 
		]
	],

	beq => [
		{ fetch => 0, op => $ins_beq, t => $op_t }, [ 
			{ alu_b_src => $alu_b_src_reg2, reg_src2_src => $reg_src2_src_rd, alu_op => $alu_op_add, result_wrt => 0 }, 
			{ pc_src => $pc_src_pc_op, pc_wrt => $pc_wrt_alu_eq, t_reset => 1, fetch => 1 } 
		]
	],

	lw => [
		{ fetch => 0, op => $ins_lw, t => $op_t }, [ 
			{ alu_b_src => $alu_b_src_op, alu_op => $alu_op_add, result_wrt => 1 }, 
			{ mar_src => $mar_src_result, reg_wrt => 1, reg_src => $reg_src_mem, t_reset => 1, fetch => 1 } 
		]
	],

	sw => [
		{ fetch => 0, op => $ins_sw, t => $op_t }, [ 
			{ alu_b_src => $alu_b_src_op, alu_op => $alu_op_add, result_wrt => 1 }, 
			{ mar_src => $mar_src_result, reg_src2_src => $reg_src2_src_rd, mem_wrt => 1, t_reset => 1, fetch => 1 } 
		]
	],

	halt => [
		{ fetch => 0, op => $ins_halt, t => $op_t }, [ 
			{ halt => 1 }
		]
	],

	jalr => [
		{ fetch => 0, op => $ins_jalr, t => $op_t }, [ 
			{ reg_src => $reg_src_pc, reg_wrt => 1 }, 
			{ pc_src => $pc_src_reg2, pc_wrt => $pc_wrt_1, t_reset => 1, fetch => 1 } 
		]
	],

	mul => [
		{ fetch => 0, op => $ins_mul, t => $op_t }, [ 
			{ alu_b_src => $alu_b_src_reg2, alu_op => $alu_op_mul, lo_wrt => 1, hi_wrt => 1, t_reset => 1, fetch => 1 } 
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



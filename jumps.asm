


		

start:
		addi	r1, r0, 1	
		j		l1
		halt		
l2:
		addi	r1, r1, 1	
		jr		r11
		halt		
l1:
		addi	r1, r1, 1	
		addi	r10, r0, l3
		jr			r10	
		halt			
l3:	
		addi	r1, r1, 1
		jal		r11, l2			
		addi	r1, r1, 1
		addi	r13, r0, l4
		jalr	r12, r13
		addi	r1, r1, 1 ; r1=7
		halt		
l4:
		addi	r1, r1, 1	
		jr		r12
		halt		
		
		
		

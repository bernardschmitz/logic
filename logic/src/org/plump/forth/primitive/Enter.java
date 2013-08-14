package org.plump.forth.primitive;


public  class Enter implements Primitive {

	@Override
	public void exec() {
		// System.err.println("Enter");
		int ip = Forth.memory[Forth.instructionAddr];
		Forth.pushRs(ip);
		int w = Forth.memory[Forth.wordAddr];
		Forth.memory[Forth.instructionAddr] = Forth.memory[w + 1];
	}
}
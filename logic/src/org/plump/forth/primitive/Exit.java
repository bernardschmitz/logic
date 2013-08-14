package org.plump.forth.primitive;


public  class Exit implements Primitive {

	@Override
	public void exec() {
		// System.err.println("Exit");
		int ip = Forth.popRs();
		Forth.memory[Forth.instructionAddr] = ip;
	}
}
package org.plump.forth.primitive;


public  class Halt implements Primitive {
	@Override
	public void exec() {
		// System.err.println("Halt");
		System.exit(1);
	}
}
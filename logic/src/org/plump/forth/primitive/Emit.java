package org.plump.forth.primitive;

import org.plump.forth.Context;



public  class Emit implements Primitive {

	private final Context context;
	
	
	public Emit(Context context) {
		super();
		this.context = context;
	}


	@Override
	public void exec() {
		// System.err.println("Emit");
		System.out.print((char)(int)context.getDataStack().pop());
	}
}
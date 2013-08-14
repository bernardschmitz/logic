package org.plump.forth.primitive;

import org.plump.forth.Context;


public  class Lit implements Primitive {

	private final Context context;
	



	public Lit(Context context) {
		super();
		this.context = context;
	}




	@Override
	public void exec() {
		// System.err.println("Lit");
		context.getDataStack().push( context.getMemory().get(context.getIp()));
		context.setIp(context.getIp()+1);
	}
}
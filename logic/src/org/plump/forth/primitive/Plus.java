package org.plump.forth.primitive;

import java.util.Deque;


public  class Plus implements Primitive {
	
	private final Deque<Integer> stack;

	public Plus(Deque<Integer> stack) {
		super();
		this.stack=stack;
	}

	@Override
	public void exec() {
		// System.err.println("Plus");
		
		int a = stack.pop();
		int b = stack.pop();
		stack.push(a + b);
	}
}
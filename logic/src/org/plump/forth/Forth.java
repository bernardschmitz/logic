
package org.plump.forth;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.LinkedList;

import org.plump.forth.primitive.Emit;
import org.plump.forth.primitive.Enter;
import org.plump.forth.primitive.Exit;
import org.plump.forth.primitive.Halt;
import org.plump.forth.primitive.Lit;
import org.plump.forth.primitive.Plus;
import org.plump.forth.primitive.Primitive;

public class Forth {

	Context context = new Context();

	public static void main(final String[] args) {

		new Forth().init();
	}

	public Forth() {
		super();
	}

	private Header defcode(String name, boolean immediate, Primitive code) {

		return new Header(name, immediate, false, code);
	}

	private void init() {

		Header lit = defcode("lit", false, new Lit(context));
		context.getDictionary().add(lit);
		Header emit = defcode("emit", false, new Emit(context));
		context.getDictionary().add(emit);
		Header halt = defcode("halt", false, new Halt());
		context.getDictionary().add(halt);
		
		context.getMemory().add(0);
		context.getMemory().add(42);
		context.getMemory().add(1);
		context.getMemory().add(2);

		loop();
	}

	private void loop() {

		while (true) {
			this.context.next();
		}
	}




}

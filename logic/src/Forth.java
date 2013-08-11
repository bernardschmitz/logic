import java.util.ArrayList;
import java.util.List;

public class Forth {

	private static final int MEMORY_SIZE = 2000;
	private static final int RETURN_SIZE = 32;

	private final int memory[] = new int[MEMORY_SIZE];

	private final List<String> strings = new ArrayList<String>();

	private final int returnStackAddr = 0;
	private final int dataStackAddr = 1;
	private final int instructionAddr = 2;
	private final int wordAddr = 3;
	private final int execAddr = 4;

	private final List<Primitive> primitives = new ArrayList<Primitive>();

	public static void main(final String[] args) {

		new Forth().init();
	}

	public Forth() {
		super();
	}

	private int[] defcode(int prev, int here, String name, int flags,
			Primitive code) {

		int back = here;
		memory[here++] = prev;
		memory[here++] = flags;
		strings.add(name);
		memory[here++] = strings.size() - 1;
		// memory[here++] = back;

		int cfa = here;
		// memory[here] = here + 1;
		// here++;
		primitives.add(code);
		memory[here++] = primitives.size() - 1;

		return new int[] { back, cfa, here };
	}

	private void init() {

		this.memory[this.returnStackAddr] = MEMORY_SIZE - 1;
		this.memory[this.dataStackAddr] = MEMORY_SIZE - RETURN_SIZE;
		this.memory[this.instructionAddr] = 100;

		int[] code = defcode(0, 10, "lit", 0, new Lit());
		int LIT = code[1];
		code = defcode(code[0], code[2], "emit", 0, new Emit());
		int EMIT = code[1];
		code = defcode(code[0], code[2], "+", 0, new Plus());
		int PLUS = code[1];
		code = defcode(code[0], code[2], "halt", 0, new Halt());
		int HALT = code[1];

		this.memory[100] = LIT;
		this.memory[101] = '*';
		this.memory[102] = EMIT;
		this.memory[103] = LIT;
		this.memory[104] = 1;
		this.memory[105] = LIT;
		this.memory[106] = 2;
		this.memory[107] = PLUS;
		this.memory[108] = HALT;

		loop();
	}

	private void loop() {

		while (true) {
			this.next();
		}
	}

	private void next() {

		int ip = this.memory[this.instructionAddr];
		final int w = this.memory[ip];
		ip++;
		this.memory[this.instructionAddr] = ip;
		this.memory[this.wordAddr] = w;
		final int x = this.memory[w];
		this.memory[this.execAddr] = x;
		this.primitives.get(x).exec();
	}

	private void pushRs(final int v) {
		final int sp = this.memory[this.returnStackAddr] - 1;
		this.memory[this.returnStackAddr] = sp;
		this.memory[sp] = v;
	}

	private int popRs() {
		final int sp = this.memory[this.returnStackAddr];
		final int v = this.memory[sp];
		this.memory[this.returnStackAddr] = sp + 1;
		return v;
	}

	private void pushDs(final int v) {
		final int sp = this.memory[this.dataStackAddr] - 1;
		this.memory[this.dataStackAddr] = sp;
		this.memory[sp] = v;
	}

	private int popDs() {
		final int sp = this.memory[this.dataStackAddr];
		final int v = this.memory[sp];
		this.memory[this.dataStackAddr] = sp + 1;
		return v;
	}

	interface Primitive {

		void exec();
	}

	private final class Lit implements Primitive {

		@Override
		public void exec() {
			System.err.println("Lit");
			int ip = Forth.this.memory[Forth.this.instructionAddr];
			final int v = Forth.this.memory[ip];
			Forth.this.pushDs(v);
			ip++;
			Forth.this.memory[Forth.this.instructionAddr] = ip;
		}
	}

	private final class Emit implements Primitive {

		@Override
		public void exec() {
			System.err.println("Emit");
			final int v = Forth.this.popDs();
			System.out.print((char) v);
		}
	}

	private final class Halt implements Primitive {
		@Override
		public void exec() {
			System.err.println("Halt");
			System.exit(1);
		}
	}

	private final class Plus implements Primitive {

		@Override
		public void exec() {
			System.err.println("Plus");
			int a = popDs();
			int b = popDs();
			pushDs(a + b);
		}
	}

}

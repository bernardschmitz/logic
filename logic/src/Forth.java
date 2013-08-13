import java.util.ArrayList;
import java.util.List;

public class Forth {

	private static final int MEMORY_SIZE = 2000;
	private static final int RETURN_SIZE = 32;

	private final static int memory[] = new int[MEMORY_SIZE];

	private static final List<String> strings = new ArrayList<String>();

	static final List<Primitive> primitives = new ArrayList<Primitive>();

	private final static int returnStackAddr = 0;
	private final static int dataStackAddr = 1;
	private final static int instructionAddr = 2;
	private final static int wordAddr = 3;
	private final static int execAddr = 4;

	private static int here = 1000;
	private final static int prev = 0;
	

	static final int ENTER = defcode("enter", 0, new Enter());
	static final int EXIT = defcode("exit", 0, new Exit());
	static final int LIT = defcode("lit", 0, new Lit());
	static final int EMIT = defcode("emit", 0, new Emit());
	static final int PLUS = defcode("+", 0, new Plus());
//	static final int DEFINE = defcode("define", 0, new Define());
	
	static final int HALT = defcode("halt", 0, new Halt());

	static final int STAR = defword("star", 0, LIT, '*', EMIT, EXIT);
	static final int K = defword("k", 0, STAR, STAR, STAR, STAR, EXIT);

	public static void main(final String[] args) {

		new Forth().init();
	}

	public Forth() {
		super();
	}

	private static int defcode(String name, int flags, Primitive code) {

		// int back = here;
		
		memory[here++] = prev;
		memory[here++] = flags;
		strings.add(name);
		memory[here++] = strings.size() - 1;

//		memory[here++] = name.length();
//		for (int i=0; i<name.length();i++) {
//			memory[here++] = name.charAt(i);
//		}
		
		// memory[here++] = back;

		int cfa = here;
		primitives.add(code);
		memory[here++] = primitives.size() - 1;

		return cfa;
	}

	private static int defword(String name, int flags, int... words) {

		// int back = here;
		memory[here++] = prev;
		memory[here++] = flags;
		strings.add(name);
		memory[here++] = strings.size() - 1;

//		memory[here++] = name.length();
//		for (int i=0; i<name.length();i++) {
//			memory[here++] = name.charAt(i);
//		}

		
		// memory[here++] = back;

		int cfa = here;

		memory[here++] = 0;  // ENTER primitive
		memory[here] = here + 1;
		here++;

		for (int i : words) {
			memory[here++] = i;
		}

		return cfa;
	}

	private void init() {

		Forth.memory[Forth.returnStackAddr] = MEMORY_SIZE - 1;
		Forth.memory[Forth.dataStackAddr] = MEMORY_SIZE - RETURN_SIZE;
		Forth.memory[Forth.instructionAddr] = 100;

		Forth.memory[100] = STAR;
		Forth.memory[101] = LIT;
		Forth.memory[102] = 1;
		Forth.memory[103] = LIT;
		Forth.memory[104] = 2;
		Forth.memory[105] = PLUS;
		Forth.memory[106] = K;
		Forth.memory[107] = HALT;

		loop();
	}

	private void loop() {

		while (true) {
			this.next();
		}
	}

	private void next() {

		int ip = Forth.memory[Forth.instructionAddr];
		final int w = Forth.memory[ip];
		ip++;
		Forth.memory[Forth.instructionAddr] = ip;
		Forth.memory[Forth.wordAddr] = w;
		final int x = Forth.memory[w];
		Forth.memory[Forth.execAddr] = x;
		Forth.primitives.get(x).exec();
	}

	private static void pushRs(final int v) {
		final int sp = Forth.memory[Forth.returnStackAddr] - 1;
		Forth.memory[Forth.returnStackAddr] = sp;
		Forth.memory[sp] = v;
	}

	private static int popRs() {
		final int sp = Forth.memory[Forth.returnStackAddr];
		final int v = Forth.memory[sp];
		Forth.memory[Forth.returnStackAddr] = sp + 1;
		return v;
	}

	private static void pushDs(final int v) {
		final int sp = memory[dataStackAddr] - 1;
		memory[dataStackAddr] = sp;
		memory[sp] = v;
	}

	private static int popDs() {
		final int sp = Forth.memory[Forth.dataStackAddr];
		final int v = Forth.memory[sp];
		Forth.memory[Forth.dataStackAddr] = sp + 1;
		return v;
	}

	public interface Primitive {

		void exec();
	}

	public static final class Lit implements Primitive {

		@Override
		public void exec() {
			// System.err.println("Lit");
			int ip = memory[instructionAddr];
			final int v = memory[ip];
			pushDs(v);
			ip++;
			memory[instructionAddr] = ip;
		}
	}

	public static final class Emit implements Primitive {

		@Override
		public void exec() {
			// System.err.println("Emit");
			final int v = popDs();
			System.out.print((char) v);
		}
	}

	public static final class Halt implements Primitive {
		@Override
		public void exec() {
			// System.err.println("Halt");
			System.exit(1);
		}
	}

	public static final class Plus implements Primitive {

		@Override
		public void exec() {
			// System.err.println("Plus");
			int a = popDs();
			int b = popDs();
			pushDs(a + b);
		}
	}

	public static final class Enter implements Primitive {

		@Override
		public void exec() {
			// System.err.println("Enter");
			int ip = memory[instructionAddr];
			pushRs(ip);
			int w = memory[wordAddr];
			memory[instructionAddr] = memory[w + 1];
		}
	}

	public static final class Exit implements Primitive {

		@Override
		public void exec() {
			// System.err.println("Exit");
			int ip = popRs();
			memory[instructionAddr] = ip;
		}
	}

	public static final class Define implements Primitive {

		@Override
		public void exec() {
			// System.err.println("Exit");
	
		}
	}

}

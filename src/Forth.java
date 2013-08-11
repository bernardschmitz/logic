public class Forth {

	private static final int MEMORY_SIZE = 2000;
	private static final int RETURN_SIZE = 32;

	private final int memory[] = new int[MEMORY_SIZE];

	private final int returnStackAddr = 0;
	private final int dataStackAddr = 1;
	private final int instructionAddr = 2;
	private final int wordAddr = 3;
	private final int execAddr = 4;

	private final Primitive primitives[] = new Primitive[20];

	{
		this.primitives[0] = new Lit();
		this.primitives[1] = new Emit();
		this.primitives[2] = new Halt();
	}

	{
		this.memory[10] = 0;
		this.memory[11] = 1;
		this.memory[12] = 2;

		this.memory[100] = 10;
		this.memory[101] = '*';
		this.memory[102] = 11;
		this.memory[103] = 12;
	}

	public static void main(final String[] args) {

		new Forth().init();
	}

	public Forth() {
		super();
	}

	private void init() {

		this.memory[this.returnStackAddr] = MEMORY_SIZE - 1;
		this.memory[this.dataStackAddr] = MEMORY_SIZE - RETURN_SIZE;
		this.memory[this.instructionAddr] = 100;

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
		this.primitives[x].exec();
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

}

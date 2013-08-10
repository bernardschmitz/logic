public class Forth {

	private static final int MEMORY_SIZE = 2000;
	private static final int RETURN_SIZE = 40;

	private final int memory[] = new int[MEMORY_SIZE];

	private final int returnStackAddr = 0;
	private final int dataStackAddr = 1;
	private final int instructionAddr = 2;
	private final int wordAddr = 3;
	private final int execAddr = 4;

	private final Primitive primitives[] = new Primitive[20];

	{
		this.primitives[0] = new Code();
		this.primitives[5] = new Emit();
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
	}

	private void exec() {

	}

	private void push(final int v) {
		final int dsp = this.memory[this.dataStackAddr] - 1;
		this.memory[this.dataStackAddr] = dsp;
		this.memory[dsp] = v;
	}

	private int pop() {
		final int dsp = this.memory[this.dataStackAddr];
		final int v = this.memory[dsp];
		this.memory[this.dataStackAddr] = dsp + 1;
		return v;
	}

	interface Primitive {

		void exec();
	}

	class Code implements Primitive {

		@Override
		public void exec() {
			int ip = Forth.this.memory[Forth.this.instructionAddr];
			final int i = Forth.this.memory[ip];
			ip++;
			Forth.this.memory[Forth.this.instructionAddr] = ip;
			Forth.this.primitives[i].exec();
		}
	}

	class Emit implements Primitive {

		@Override
		public void exec() {
			final int v = Forth.this.pop();
			System.out.print((char) v);
		}

	}

}

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class Emul {

	private final short[] mem = new short[0xffff];

	private short pc = 0;

	private boolean halt;

	private short ir;

	private int clock;

	private short op;

	private short ins;

	private short rd;

	private short rs;

	private short rt;

	private final short[] reg = new short[16];

	private int result;

	private short hi;

	private short lo;

	private final List<Character> keyboard_buf = new ArrayList<Character>(32);

	static final short INS_ADD = 0x00;
	static final short INS_ADDI = 0x01;
	static final short INS_SUB = 0x02;
	static final short INS_MUL = 0x03;
	static final short INS_DIV = 0x04;
	static final short INS_SLL = 0x05;
	static final short INS_SRL = 0x06;
	static final short INS_SRA = 0x07;
	static final short INS_SLLV = 0x08;
	static final short INS_SRLV = 0x09;
	static final short INS_SRAV = 0x0a;
	static final short INS_BEQ = 0x0b;
	static final short INS_BNE = 0x0c;
	static final short INS_SLT = 0x0d;
	static final short INS_SLTI = 0x0e;
	static final short INS_AND = 0x0f;
	static final short INS_ANDI = 0x10;
	static final short INS_OR = 0x11;
	static final short INS_ORI = 0x12;
	static final short INS_XOR = 0x13;
	static final short INS_NOR = 0x14;
	static final short INS_J = 0x15;
	static final short INS_JR = 0x16;
	static final short INS_JAL = 0x17;
	static final short INS_JALR = 0x18;
	static final short INS_LW = 0x19;
	static final short INS_SW = 0x1a;
	static final short INS_MFHI = 0x1b;
	static final short INS_MFLO = 0x1c;
	static final short INS_BRK = 0x1d;
	// static final short INS_UNDEF = 0x1e;
	static final short INS_HALT = 0x1f;

	private static final short TIMER_LO = (short) 0xf000;
	private static final short TIMER_HI = (short) 0xf001;
	private static final short RANDOM = (short) 0xf002;
	private static final short BUFFER_CLEAR = (short) 0xfffb;
	private static final short CHAR_READY = (short) 0xfffc;
	private static final short CHAR_IN = (short) 0xfffd;
	private static final short CHAR_OUT = (short) 0xfffe;
	private static final short SCREEN_CLEAR = (short) 0xffff;

	private final Random rand = new Random(0xcafebabe);

	public static void main(final String[] args) throws IOException {

		new Emul("bsforth.bin").start();
		// new Emul("rand.bin").start();
	}

	public Emul(final String filename) throws IOException {
		super();

		System.out.println(filename);

		final BufferedReader reader = new BufferedReader(new FileReader(
				new File(filename)));
		String line = reader.readLine();
		if (!line.equals("v2.0 raw")) {
			throw new IllegalArgumentException("invalid bin file");
		}
		int i = 0;
		while ((line = reader.readLine()) != null) {
			final short x = (short) Integer.parseInt(line, 16);
			this.mem[i++] = x;
			// System.out.println(line + " " + x);
		}
	}

	private void start() throws IOException {

		// final Reader reader = System.console().reader();
		final Reader reader = new BufferedReader(new InputStreamReader(
				System.in));

		while (!this.halt) {
			this.ir = this.read_mem(this.pc, true);
			this.pc++;
			this.clock += 2;

			this.op = this.read_mem(this.pc, true);
			this.pc++;
			this.clock++;

			this.ins = (short) (this.ir >> 8 & 0x1f);
			this.rd = (short) (this.ir >> 4 & 0xf);
			this.rs = (short) (this.ir & 0xf);
			this.rt = (short) (this.op >> 12 & 0xf);

			this.execute();

			this.reg[0] = 0;

			if (reader.ready()) {
				final int ch = reader.read();
				this.keyboard_buf.add((char) ch);
			}
		}
	}

	private void execute() {

		// System.err.printf("%04x %s r%d, r%d, r%d %04x %04x \n", this.pc,
		// this.ins, this.rd, this.rs, this.rt, this.op, this.ir);

		int mask;
		switch (this.ins) {

		case INS_ADD:
			this.reg[this.rd] = (short) (this.reg[this.rs] + this.reg[this.rt]);
			this.clock += 2;
			break;

		case INS_ADDI:
			this.reg[this.rd] = (short) (this.reg[this.rs] + this.op);
			this.clock += 2;

			break;

		case INS_SUB:
			this.reg[this.rd] = (short) (this.reg[this.rs] - this.reg[this.rt]);
			this.clock += 2;
			break;

		case INS_MUL:
			this.result = this.reg[this.rs] * this.reg[this.rt];
			this.hi = (short) (this.result >> 16 & 0xffff);
			this.result = this.result & 0xffff;
			this.lo = (short) this.result;
			this.clock++;
			break;

		case INS_DIV:
			if (this.reg[this.rt] == 0) {
				this.result = this.reg[this.rs];
				this.hi = 0;
			} else {
				this.result = (this.reg[this.rs] & 0x0000ffff)
						/ (this.reg[this.rt] & 0x0000ffff) & 0xffff;
				this.hi = (short) ((this.reg[this.rs] & 0x0000ffff)
						% (this.reg[this.rt] & 0x0000ffff) & 0xffff);

			}
			this.lo = (short) this.result;
			this.clock++;

			// System.err.printf("%04x %s r%d, r%d, r%d %04x %04x \n", this.pc,
			// this.ins, this.rd, this.rs, this.rt, this.op, this.ir);
			// System.err.printf("%04x %s %04x, %04x, %04x, %04x, %04x \n",
			// this.pc, this.ins, this.reg[this.rd], this.reg[this.rs],
			// this.reg[this.rt], this.hi, this.lo);

			break;

		case INS_SLL:
			this.reg[this.rd] = (short) (this.reg[this.rs] << (this.op & 0xf));
			this.clock += 2;
			break;

		case INS_SRL:
			this.reg[this.rd] = (short) (this.reg[this.rs] >> (this.op & 0xf));
			this.clock += 2;
			break;

		case INS_SRA:
			this.reg[this.rd] = (short) (this.reg[this.rs] >> (this.op & 0xf));
			mask = 0xffff >> (this.op & 0xf);
			this.reg[this.rd] &= mask;
			this.clock += 2;
			break;

		case INS_SLLV:
			this.reg[this.rd] = (short) (this.reg[this.rs] << (this.reg[this.rt] & 0xf));
			this.clock += 2;
			break;

		case INS_SRLV:
			this.reg[this.rd] = (short) (this.reg[this.rs] >> (this.reg[this.rt] & 0xf));
			this.clock += 2;
			break;

		case INS_SRAV:
			this.reg[this.rd] = (short) (this.reg[this.rs] >> (this.reg[this.rt] & 0xf));
			mask = 0xffff >> (this.reg[this.rt] & 0xf);
			this.reg[this.rd] &= mask;
			this.clock += 2;
			break;

		case INS_BEQ:
			if (this.reg[this.rs] == this.reg[this.rd]) {
				this.pc += this.op << 1;
			}
			this.clock += 2;
			break;

		case INS_BNE:
			if (this.reg[this.rs] != this.reg[this.rd]) {
				this.pc += this.op << 1;
			}
			this.clock += 2;
			break;

		case INS_SLT:
			this.reg[this.rd] = (short) ((this.reg[this.rs] - this.reg[this.rt] & 0x8000) >> 15);
			this.clock += 2;
			break;

		case INS_SLTI:
			this.reg[this.rd] = (short) ((this.reg[this.rs] - this.op & 0x8000) >> 15);
			this.clock += 2;
			break;

		case INS_AND:
			this.reg[this.rd] = (short) (this.reg[this.rs] & this.reg[this.rt]);
			this.clock += 2;
			break;

		case INS_ANDI:
			this.reg[this.rd] = (short) (this.reg[this.rs] & this.op);
			this.clock += 2;
			break;

		case INS_OR:
			this.reg[this.rd] = (short) (this.reg[this.rs] | this.reg[this.rt]);
			this.clock += 2;
			break;

		case INS_ORI:
			this.reg[this.rd] = (short) (this.reg[this.rs] | this.op);
			this.clock += 2;
			break;

		case INS_XOR:
			this.reg[this.rd] = (short) (this.reg[this.rs] ^ this.reg[this.rt]);
			this.clock += 2;
			break;

		case INS_NOR:
			this.reg[this.rd] = (short) ~(this.reg[this.rs] | this.reg[this.rt]);
			this.clock += 2;
			break;

		case INS_J:
			this.pc = this.op;
			this.clock += 2;
			break;

		case INS_JR:
			this.pc = this.reg[this.rt];
			this.clock += 2;
			break;

		case INS_JAL:
			this.reg[this.rd] = this.pc;
			this.pc = this.op;
			this.clock += 3;
			break;

		case INS_JALR:
			this.reg[this.rd] = this.pc;
			this.pc = this.reg[this.rt];
			this.clock += 3;
			break;

		case INS_LW:
			this.reg[this.rd] = this.read_mem(
					(short) (this.reg[this.rs] + this.op), false);
			this.clock += 2;
			break;

		case INS_SW:
			this.write_mem((short) (this.reg[this.rs] + this.op),
					this.reg[this.rd]);
			this.clock += 2;
			break;

		case INS_MFHI:
			this.reg[this.rd] = this.hi;
			this.clock++;
			break;

		case INS_MFLO:
			this.reg[this.rd] = this.lo;
			this.clock++;
			break;

		case INS_BRK:
			break;

		case INS_HALT:
			this.halt = true;
			break;

		default:
			System.err.printf("invalid instruction %04x at pc %04x\n",
					this.ins, this.pc - 2);
			System.exit(1);
		}

		// System.err.printf("\t%04x %s r%d, r%d, r%d %04x %04x \n", this.pc,
		// this.ins, this.rd, this.rs, this.rt, this.op, this.ir);

	}

	private void write_mem(int address, final short word) {

		// System.out.printf("%04x %04x\n", address, word);

		switch (address) {
		case CHAR_OUT:
			System.out.print((char) (word & 0x7f));
			break;
		case BUFFER_CLEAR:
			this.keyboard_buf.clear();
			break;
		case SCREEN_CLEAR:
			for (int i = 0; i < 25; i++) {
				System.out.println();
			}
			break;
		default:

			if (address < 0) {
				address += 0x10000;
			}

			this.mem[address] = word;
		}

	}

	private short read_mem(int address, final boolean fetch) {

		switch (address) {

		case RANDOM:
			return (short) (this.rand.nextInt() & 0xffff);

		case TIMER_LO:
			return (short) (this.clock & 0xffff);

		case TIMER_HI:
			return (short) (this.clock >> 16 & 0xffff);

		case CHAR_IN:
			if (this.keyboard_buf.size() == 0) {
				return 0;
			}

			return (short) this.keyboard_buf.remove(0).charValue();

		case CHAR_READY:
			if (this.keyboard_buf.isEmpty()) {
				return 0;
			}
			return 1;

		default:
			if (address < 0) {
				address += 0x10000;
			}
			return this.mem[address];
		}
	}
}

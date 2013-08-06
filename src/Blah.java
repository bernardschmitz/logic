import java.math.BigInteger;

public class Blah {

	public static void main(final String[] args) {

		final BigInteger a = new BigInteger("123");
		final BigInteger b = new BigInteger("5");

		final BigInteger c;

		c = a.add(b);

		System.out.printf("%d + %d = %d\n", a, b, c);
	}
}

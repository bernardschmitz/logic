package org.plump.forth;

import java.util.ArrayList;
import java.util.List;

import org.plump.forth.primitive.Primitive;

public class Header {

	private final String name;
	private boolean immediate;
	private boolean hidden;
	private Primitive cfa;
	private List<Header> dfa = new ArrayList<Header>();
	
	
	public Header(String name, boolean immediate, boolean hidden) {
		super();
		this.name = name;
		this.immediate = immediate;
		this.hidden = hidden;
	}

	public Header(String name, boolean immediate, boolean hidden, Primitive code) {
		this(name, immediate, hidden);
		this.cfa = code;
	}
	
	public boolean isImmediate() {
		return immediate;
	}

	public void setImmediate(boolean immediate) {
		this.immediate = immediate;
	}

	public boolean isHidden() {
		return hidden;
	}

	public void setHidden(boolean hidden) {
		this.hidden = hidden;
	}

	public String getName() {
		return name;
	}

	public Primitive getCfa() {
		return cfa;
	}

	public void setCfa(Primitive cfa) {
		this.cfa = cfa;
	}

	public List<Header> getDfa() {
		return dfa;
	}

	public void setDfa(List<Header> dfa) {
		this.dfa = dfa;
	}
	
	
	
}

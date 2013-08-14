package org.plump.forth;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.List;

public class Context {
	
	private final List<Header> dictionary = new ArrayList<Header>();
	private final Deque<Integer> dataStack = new ArrayDeque<Integer>();
	private final Deque<Integer> returnStack = new ArrayDeque<Integer>();
	private final List<Integer> memory = new ArrayList<Integer>();
	private  int ip = 0;
	private  int w = 0;
	private  int x = 0;

	public Context() {
		super();
	}
	
	public void next() {

		w = memory.get(ip++);
		x = memory.get(w);
		dictionary.get(x).getCfa().exec();
	}


	public List<Header> getDictionary() {
		return dictionary;
	}

	public Deque<Integer> getDataStack() {
		return dataStack;
	}

	public Deque<Integer> getReturnStack() {
		return returnStack;
	}

	public List<Integer> getMemory() {
		return memory;
	}

	public int getIp() {
		return ip;
	}

	public int getW() {
		return w;
	}

	public int getX() {
		return x;
	}

	public void setIp(int ip) {
		this.ip = ip;
	}

	public void setW(int w) {
		this.w = w;
	}

	public void setX(int x) {
		this.x = x;
	}
	
	
}
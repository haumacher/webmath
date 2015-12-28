shared dynamic Document satisfies Node & EventTarget {
	
	shared formal Element documentElement;
	shared formal Element? getElementById(String id);
	shared formal Element createElement(String tagName);
	
}
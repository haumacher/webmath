shared dynamic EventTarget {
	
	shared formal void addEventListener(String type, Anything(Event) listener, Boolean useCapture = false);
	
}
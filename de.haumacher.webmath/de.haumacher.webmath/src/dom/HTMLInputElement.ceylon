
shared dynamic HTMLInputElement satisfies Element {
	
	shared formal variable String \ivalue;
	
}

// FIXME: Workaround because cast to dynamic type produces assertion failure.
shared HTMLInputElement toInput(Element element) {
	dynamic {
		dynamic foo = element;
		return foo;
	}
}

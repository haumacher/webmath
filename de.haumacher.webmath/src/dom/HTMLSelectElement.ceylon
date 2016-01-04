shared dynamic HTMLSelectElement satisfies Element {
	
	"Sets or returns whether the drop-down list is disabled, or not."
	shared formal variable Boolean disabled;
	
	"Returns a reference to the form that contains the drop-down list."
	shared formal variable Element form;
	
	"Returns the number of <option> elements in a drop-down list."
	shared formal variable Integer length;
	
	"Sets or returns whether more than one option can be selected from the drop-down list."
	shared formal variable Boolean multiple;
	
	"Sets or returns the value of the name attribute of a drop-down list."
	shared formal variable String name;
	
	"Sets or returns the index of the selected option in a drop-down list."
	shared formal variable Integer selectedIndex;
	
	"Sets or returns the value of the size of a drop-down list."
	shared formal variable Integer size;
	
	"Returns which type of form element a drop-down list is."
	shared formal variable String type;
	
	"Sets or returns the value of the selected option in a drop-down list."
	shared formal variable String \ivalue;
	
}

// FIXME: Workaround because cast to dynamic type produces assertion failure.
shared HTMLSelectElement toSelect(Element element) {
	dynamic {
		dynamic foo = element;
		return foo;
	}
}

import widget {
	PropertyObservable,
	PropertyValue,
	Property
}

class Foo() extends PropertyObservable() {
	
	variable Integer _x = 0;
	
	shared Integer x => _x;
	
	assign x {
		Integer before = _x;
		_x = x;
		notifyChange(`Foo.x`, before, x);
	}
	
}

shared void testListenerCalled() {
	variable Boolean handlerCalled = false;

    value foo = Foo();
    void listener(Object self, Property attr, PropertyValue before, PropertyValue after) {
        handlerCalled = true;
    }
    value subscription = foo.addPropertyListener(`Foo.x`, listener);
    
    assert (!handlerCalled);
    foo.x = 13;
    assert (handlerCalled);

    subscription.cancel();
    handlerCalled = false;
    
    foo.x = 42;
    assert (!handlerCalled);
}
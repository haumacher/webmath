import widget {
	PropertyObservable,
	PropertyValue,
	Property,
	PropertyListener
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
    PropertyListener listener = object satisfies PropertyListener {
    	shared actual void notifyChanged(PropertyObservable observable, Property property, PropertyValue before, PropertyValue after) {
	        handlerCalled = true;
    	}
    };
    PropertyListener listener2 = object satisfies PropertyListener {
    	shared actual void notifyChanged(PropertyObservable observable, Property property, PropertyValue before, PropertyValue after) {
	        assert (false);
    	}
    };
    
    assert (foo.addPropertyListener(`Foo.x`, listener2));
    assert (foo.addPropertyListener(`Foo.x`, listener));
    assert (!foo.addPropertyListener(`Foo.x`, listener));
    assert (!foo.addPropertyListener(`Foo.x`, listener2));
    assert (foo.removePropertyListener(`Foo.x`, listener2));
    assert (!foo.removePropertyListener(`Foo.x`, listener2));
    
    assert (!handlerCalled);
    foo.x = 13;
    assert (handlerCalled);

    assert(foo.removePropertyListener(`Foo.x`, listener));
    assert(!foo.removePropertyListener(`Foo.x`, listener));
    handlerCalled = false;
    
    foo.x = 42;
    assert (!handlerCalled);
}
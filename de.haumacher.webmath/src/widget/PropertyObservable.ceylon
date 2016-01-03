import ceylon.collection {
	MutableMap,
	HashMap
}
import ceylon.language.meta.model {
	Attribute
}

shared alias PropertyValue => Anything;
shared alias Property => Attribute<Nothing,PropertyValue,Nothing>;
shared alias PropertHandler => Anything(Object, Property, PropertyValue, PropertyValue);

shared interface Subscription {
	shared formal void cancel();
}

// FIXME: Directly using the meta model attribute as key in the map does not work. The handlers are not found during notification (at least in the JavaScript version.
alias HandlerKey => String;
HandlerKey key(Property attr) => attr.string;

shared abstract class PropertyObservable() {
	alias HandlerList => Assignment[];
	alias Handlers => Assignment|HandlerList;
	alias HandlerCollection => MutableMap<HandlerKey, Handlers>;
	
	variable HandlerCollection? lazyHandlers = null;
	
	Boolean noHandlers() => ! lazyHandlers exists;
	
	HandlerCollection mkHandlers() {
		if (exists existing = lazyHandlers) {
			return existing;
		}
		
		value allocation = HashMap<HandlerKey, Handlers>();
		lazyHandlers = allocation;
		return allocation;
	}
	
	shared Subscription addPropertyListener(Property attr, PropertHandler handler) {
		value assignment = Assignment(attr, handler);
		
		value handlers = mkHandlers();
		value propertyKey = key(attr);
		value clash = handlers.put(propertyKey, assignment);
		if (exists clash) {
			if (is Assignment clash) {
				handlers.put(propertyKey, [clash, assignment]);
			} else {
				handlers.put(propertyKey, clash.append([assignment]));
			}
		}
		return assignment;
	}
	
	void removePropertyListener(Property attr, Assignment assignment) {
		if (noHandlers()) {
			return;
		}
		value handlers = mkHandlers();
		value propertyKey = key(attr);
		value before = handlers.remove(propertyKey);
		if (exists before) {
			if (is Assignment before) {
				if (before == assignment) {
					return;
				}
			} else {
				if (before.contains(assignment)) {
					if (before.size == 2) {
						assert (exists first = before.first);
						assert (exists last = before.last);
						if (assignment.equals(first)) {
							handlers.put(propertyKey, last);
						} else {
							handlers.put(propertyKey, first);
						}
					} else {
						handlers.put(propertyKey, [for (h in before) if (!assignment.equals(h)) h]);
					}
					return;
				}
			}
			handlers.put(propertyKey, before);
		}
		return;
	}
	
	shared void notifyChange(Property attr, PropertyValue before, PropertyValue after) {
		if (noHandlers()) {
			return;
		}
		
		value propertyKey = key(attr);
		Handlers? handler = mkHandlers().get(propertyKey);
		if (exists handler) {
			if (is Assignment handler) {
				handler.invoke(before, after);
			} else {
				handler.each((h) => h.invoke(before, after));
			}
		}
	}
	
	class Assignment(Property attr, shared PropertHandler handler) 
			satisfies Subscription 
	{
		shared actual void cancel() {
			outer.removePropertyListener(attr, this);
		}
		
		shared void invoke(PropertyValue before, PropertyValue after) {
			handler(outer, attr, before, after);
		}
	}
}
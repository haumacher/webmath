import ceylon.collection {
	MutableMap,
	HashMap
}
import ceylon.language.meta.model {
	Attribute
}

shared alias PropertyValue => Anything;
shared alias Property => Attribute<Nothing,PropertyValue,Nothing>;

// FIXME: Directly using the meta model attribute as key in the map does not work. The handlers are not found during notification (at least in the JavaScript version.
alias ListenerKey => String;
ListenerKey key(Property attr) => attr.string;

"
 Listener interface being informed about property changes.
 
 Note: It is not possible to register plain functions directly, because the Ceylon 
 function type is not [[Identifiable]]. Therefore plain function references cannot 
 be removed as listeners.
 "
shared interface PropertyListener satisfies Identifiable {
	"Callbak being invoked upon property changes."
	shared formal void notifyChanged(
		"The observable whose property has changed."
		PropertyObservable observable, 
		"The property whose value was updated."
		Property property, 
		"The property value before the change."
		PropertyValue before, 
		"The actual/new value of the property."
		PropertyValue after);
}

shared abstract class PropertyObservable() {
	alias ListenerList => PropertyListener[];
	alias Listeners => PropertyListener|ListenerList;
	alias ListenerCollection => MutableMap<ListenerKey, Listeners>;
	
	variable ListenerCollection? lazyListeners = null;
	
	Boolean noListeners() => ! lazyListeners exists;
	
	ListenerCollection mkListenerCollection() {
		if (exists existing = lazyListeners) {
			return existing;
		}
		
		value allocation = HashMap<ListenerKey, Listeners>();
		lazyListeners = allocation;
		return allocation;
	}
	
	shared Boolean addPropertyListener(Property attr, PropertyListener listener) {
		value listeners = mkListenerCollection();
		value propertyKey = key(attr);
		value clash = listeners.put(propertyKey, listener);
		if (exists clash) {
			if (is PropertyListener clash) {
				if (clash == listener) {
					return false;
				}
				listeners.put(propertyKey, [clash, listener]);
			} else {
				if (clash.contains(listener)) {
					// Revert change.
					listeners.put(propertyKey, clash);
					return false;
				}
				listeners.put(propertyKey, clash.append([listener]));
			}
		}
		return true;
	}
	
	shared Boolean removePropertyListener(Property attr, PropertyListener listener) {
		if (noListeners()) {
			return false;
		}
		value listeners = mkListenerCollection();
		value propertyKey = key(attr);
		value before = listeners.remove(propertyKey);
		if (exists before) {
			if (is PropertyListener before) {
				if (before == listener) {
					return true;
				}
			} else {
				if (before.contains(listener)) {
					if (before.size == 2) {
						assert (exists first = before.first);
						assert (exists last = before.last);
						if (listener.equals(first)) {
							listeners.put(propertyKey, last);
						} else {
							listeners.put(propertyKey, first);
						}
					} else {
						listeners.put(propertyKey, [for (h in before) if (!listener.equals(h)) h]);
					}
					return true;
				}
			}
			// Revert change.
			listeners.put(propertyKey, before);
		}
		return false;
	}
	
	shared void notifyChange(Property attr, PropertyValue before, PropertyValue after) {
		if (noListeners()) {
			return;
		}
		
		value propertyKey = key(attr);
		Listeners? listener = mkListenerCollection().get(propertyKey);
		if (exists listener) {
			if (is PropertyListener listener) {
				listener.notifyChanged(this, attr, before, after);
			} else {
				listener.each((h) => h.notifyChanged(this, attr, before, after));
			}
		}
	}
}
import dom {
	Element,
	toInput,
	Event
}

shared class IntegerField(Page page) extends Widget(page) {
	
	shared variable Boolean _disabled = false;
	
	variable String classes = "";
	
	variable String currentRaw = "";
	variable Integer? _current = null;
	
	shared variable Anything(IntegerField, Integer?)? onUpdate = null;
	
	shared actual void _display(TagOutput output) {
		output.tag("input").attribute("id", id).attribute("value", currentRaw);
		if (disabled) {
			output.attribute("disabled", "disabled");
		}
		if (!classes.empty) {
			output.attribute("class", classes);
		}
		output.endEmpty();
	}
	
	shared Boolean disabled => _disabled;
	
	assign disabled {
		_disabled = disabled;
		invalidate();
	}
	
	shared void notifyChange(Boolean fromUI) {
		if (exists handler = onUpdate) {
			handler(this, _current);
		}
		if (fromUI) {
			invalidate();
		}
	}
	
	shared actual void onChange(Event event) {
		Element? element = page.document.getElementById(id);
		assert (exists element);
		
		currentRaw = toInput(element).\ivalue;
		_current = parseInteger(currentRaw);
		
		notifyChange(true);
	}
	
	shared Integer? getValue() => _current;
	
	shared void setValue(Integer? newValue) {
		// FIXME: Absurd construct with the meaning "if (newValue == _current) {return;}"
		if (exists newValue) {
			if (exists current = _current) {
				if (newValue == current) {
					return;
				}
			}
		} else {
			if (!_current exists) {
				return;
			}
		}
		
		_current = newValue;
		currentRaw = if (exists newValue) then newValue.string else "";
		
		notifyChange(false);
	}
	
	void invalidate() {
		page.requestRepaint(this);
	}

	shared void addClass(String newClass) {
		if (classes.empty) {
			classes = newClass;
		} else {
			// Check whether this is a NOOP.
			if (classes.split(' '.equals).contains(newClass)) {
				return;
			}
			
			classes += " " + newClass;
		}
		
		invalidate();
	}
	
}
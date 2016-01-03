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
	
	shared void notifyValueChange(Integer? before, Integer? after) {
		notifyChange(`IntegerField.intValue`, before, after);
	}
	
	shared actual void onChange(Event event) {
		Element? element = page.document.getElementById(id);
		assert (exists element);
		
		Integer? before = _current;
		currentRaw = toInput(element).\ivalue;
		Integer? after = parseInteger(currentRaw);
		_current = after;
		
		notifyValueChange(before, after);
	}
	
	shared Integer? intValue => _current;
	
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
		
		Integer? before = _current;
		_current = newValue;
		currentRaw = if (exists newValue) then newValue.string else "";
		
		notifyValueChange(before, newValue);
		invalidate();
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
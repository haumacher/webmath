import dom {
	Element,
	toInput,
	Event
}

shared class IntegerField(Page page) extends Field(page) {
	
	variable String currentRaw = "";
	variable Integer? _current = null;
	
	shared actual String typeClass() => "wInt";
	
	shared actual void _display(TagOutput output) {
		switch (mode) 
		case (editing | disabled) {
			output.tag("input").attribute("id", id).attribute("value", currentRaw);
			if (isDisabled()) {
				output.attribute("disabled", "disabled");
			}
			writeClasses(output);
			output.endEmpty();
		}
		case (displaying|hidden) {
			output.tag("span").attribute("id", id);
			writeClasses(output);
			if (!isHidden()) {
				output.text(currentRaw);
			}
			output.end("span");
		}
	}
	
	void notifyValueChange(Integer? before, Integer? after) {
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
	
	observable shared Integer? intValue => _current;
	
	assign intValue {
		setValue(intValue);
	}
	
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
		
		// TODO: Use incremental update.
		invalidate();
	}
	
}
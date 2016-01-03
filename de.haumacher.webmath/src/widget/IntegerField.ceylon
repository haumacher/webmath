import dom {
	Element,
	toInput,
	Event
}

shared class IntegerField(Page page) extends Widget(page) {
	
	shared variable DisplayMode _mode = editing;
	
	variable String classes = "";
	
	variable String currentRaw = "";
	variable Integer? _current = null;
	
	
	shared void enable() => mode = editing;
	shared void disable() => mode = disabled;
	shared void displayOnly() => mode = displaying;
	shared void hide() => mode = hidden;
	
	shared Boolean isEnabled() => mode == editing;
	shared Boolean isDisabled() => mode == disabled;
	shared Boolean isImmutable() => mode == displaying;
	shared Boolean isHidden() => mode == hidden;
	
	shared DisplayMode mode => _mode;
	
	assign mode {
		if (mode == _mode) {
			return;
		}
		_mode = mode;
		invalidate();
	}
	
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
	
	void writeClasses(TagOutput output) {
		output.openAttribute("class");

		output.attributeValue("wInt");
		
		output.attributeValue(" ");
		switch (mode)
		case (hidden) {
			output.attributeValue("mHidden");
		}
		case (displaying) {
			output.attributeValue("mDisplay");
		}
		case (disabled) {
			output.attributeValue("mDisabled");
		}
		case (editing) {
			output.attributeValue("mEdit");
		}
		
		if (!classes.empty) {
			output.attributeValue(" ");
			output.attributeValue(classes);
		}
		
		output.closeAttribute();
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
import dom {
	Element,
	toSelect,
	Event
}

shared class SelectField<T>(Page page, T[] options) extends Field(page) 
	given T satisfies Object
{
	
	variable Integer _selectedIndex = -1;
	
	shared variable String(T) label = (T x) => x.string;
	
	observable shared T? selected => if (_selectedIndex < 0) then null else options[_selectedIndex];
	
	assign selected {
		Integer newIndex;
		if (exists selected) {
			value index = options.firstIndexWhere((T element) => element == selected);
			assert (exists index);
			
			newIndex = index;
		} else {
			newIndex = -1;
		}
		
		selectedIndex = newIndex;
	}
	
	shared Integer selectedIndex => _selectedIndex;
	
	assign selectedIndex {
		if (selectedIndex == _selectedIndex) {
			return;
		}
	
		T? before = selected;
		_selectedIndex = selectedIndex;
		T? after = selected;
		
		notifyChange(`selected`, before, after);
	
		// TODO: Use incremental update.
		invalidate();
	}
	
	shared actual String typeClass() => "wSelect";
	
	shared actual void _display(TagOutput output) {
		switch (mode) 
		case (editing | disabled) {
			output.tag("select").attribute("id", id);
			if (isDisabled()) {
				output.attribute("disabled", "disabled");
			}
			writeClasses(output);
			
			if (_selectedIndex < 0) {
				output.tag("option");
				output.attribute("selected", "selected");
				output.attribute("value", "-1");
				output.end("option");
			}
			variable Integer index = 0;
			for (T option in options) {
				output.tag("option");
				if (index == _selectedIndex) {
					output.attribute("selected", "selected");
				}
				output.attribute("value", (index++).string);
				output.text(label(option));
				output.end("option");
			}
			
			output.end("select");
		}
		case (displaying|hidden) {
			output.tag("span").attribute("id", id);
			writeClasses(output);
			if (!isHidden()) {
				if (exists current = selected) {
					output.text(label(current));
				} else {
					output.text("-");
				}
			}
			output.end("span");
		}
	}
	
	shared actual void onChange(Event event) {
		Element? element = page.document.getElementById(id);
		assert (exists element);
		
		
		assert (exists selectedValue = parseInteger(toSelect(element).\ivalue));
		selectedIndex = selectedValue;
	}
	
}
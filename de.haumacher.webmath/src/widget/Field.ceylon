shared abstract class Field(Page page) extends StyledWidget(page) {
	
	shared variable DisplayMode _mode = editing;
	
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
	
	shared actual void writeClassesContent(TagOutput output) {
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
	}
	
}
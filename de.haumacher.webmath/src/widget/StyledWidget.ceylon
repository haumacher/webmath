shared abstract class StyledWidget(Page page) extends Widget(page) {
	
	variable String classes = "";
	
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
	
	shared formal String typeClass();
	
	shared void writeClasses(TagOutput output) {
		output.openAttribute("class");
		
		output.attributeValue(typeClass());
		
		writeClassesContent(output);
		
		if (!classes.empty) {
			output.attributeValue(" ");
			output.attributeValue(classes);
		}
		
		output.closeAttribute();
	}
	
	shared default void writeClassesContent(TagOutput output) {
		// Hook for sub-classes.
	}
	
}
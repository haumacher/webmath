import ceylon.collection {
	MutableList,
	ArrayList
}

shared class TagOutput() {
	
	MutableList<String> openTags = ArrayList<String>();
	
	StringBuilder buffer = StringBuilder();
	
	variable Boolean tagOpen = false;
	
	shared actual String string => buffer.string;
	
	shared TagOutput tag(String tagName) {
		closeStart();
		buffer.append("<");
		buffer.append(tagName);
		openTags.add(tagName);
		tagOpen = true;
		return this;
	}
	
	shared TagOutput attribute(String name, String? val) {
		assert (tagOpen);

		if (exists val) {
			buffer.append(" ");
			buffer.append(name);
			buffer.append("=");
			buffer.append("\"");
			buffer.append(val);
			buffer.append("\"");
		}
		return this;
	}
	
	shared TagOutput end(String? expectedTagName = null) {
		String? tagName = openTags.deleteLast();
		assert (exists tagName);
		
		if (exists expectedTagName) {
			assert (tagName.equals(expectedTagName));
		}
		
		closeStart();
		buffer.append("</");
		buffer.append(tagName);
		buffer.append(">");
		return this;
	}
	
	shared TagOutput endEmpty() {
		assert (tagOpen);
		
		String? tagName = openTags.deleteLast();
		assert (exists tagName);
		
		buffer.append("/>");
		tagOpen = false;
		return this;
	}
	
	shared void text(String text) {
		closeStart();
		buffer.append(text);
	}
	
	void closeStart() {
		if (tagOpen) {
			buffer.append(">");
			tagOpen = false;
		}
	}
}
import ceylon.collection {
	MutableList,
	ArrayList
}

interface State of elementContent | tagOpen | attributeOpen {}

object elementContent satisfies State {}
object tagOpen satisfies State {}
object attributeOpen satisfies State {}
	
shared class TagOutput() {
	
	variable State state = elementContent;
	
	MutableList<String> openTags = ArrayList<String>();
	
	StringBuilder buffer = StringBuilder();
	
	shared actual String string => buffer.string;
	
	shared TagOutput tag(String tagName) {
		closeStart();
		buffer.append("<");
		buffer.append(tagName);
		openTags.add(tagName);
		
		state = tagOpen;
		return this;
	}
	
	shared TagOutput openAttribute(String name) {
		assert (state == tagOpen);

		buffer.append(" ");
		buffer.append(name);
		buffer.append("=\"");
		
		state = attributeOpen;
		return this;
	}
	
	shared TagOutput closeAttribute() {
		assert (state == attributeOpen);
		
		buffer.append("\"");
		
		state = tagOpen;
		return this;
	}
	
	shared TagOutput attribute(String name, String? val) {
		assert (state == tagOpen);

		if (exists val) {
			openAttribute(name);
			attributeValue(val);
			closeAttribute();
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
		assert (state == tagOpen);
		
		String? tagName = openTags.deleteLast();
		assert (exists tagName);
		
		buffer.append("/>");
		
		state = elementContent;
		return this;
	}
	
	shared TagOutput text(String text) {
		closeStart();
		quoteText(text);
		
		return this;
	}
	
	void closeStart() {
		switch (state) 
		case (elementContent) {
			// Ignore
		}
		case (tagOpen) {
			buffer.append(">");
			state = elementContent;
		}
		case (attributeOpen) {
			"Missing call to `closeAttribute`."
			assert (false);
		}
	}
	
	void quoteText(String val) {
		val.each((ch) {
			switch (ch)
			case ('<') {
				buffer.append("&lt;");
			}
			case ('>') {
				buffer.append("&gt;");
			}
			case ('&') {
				buffer.append("&amp;");
			}
			// FIXME: Workaround for direct unicode character output using '\{DOT OPERATOR}' is not working.
			case ('*') {
				buffer.append("&#x22C5;");
			}
			else {
				buffer.appendCharacter(ch);
			}
		});
	}
	
	shared TagOutput attributeValue(String val) {
		assert (state == attributeOpen);
		
		val.each((ch) {
			switch (ch)
			case ('<') {
				buffer.append("&lt;");
			}
			case ('>') {
				buffer.append("&gt;");
			}
			case ('&') {
				buffer.append("&amp;");
			}
			case ('"') {
				buffer.append("&quot;");
			}
			else {
				buffer.appendCharacter(ch);
			}
		});
		
		return this;
	}

}
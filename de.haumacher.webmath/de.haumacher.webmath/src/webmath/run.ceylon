
import dom {

	Document
}
import widget {

	Page
}

Document document() {
	dynamic {
		return window.document;
	}
}

"Run the module `webmath`."
shared void run() {
	value page = Page(document());
	page.init();
	
	AdditionConfig addConfig = AdditionConfig();
	value addition = Addition(page, addConfig);
	
	page.append(addition);
	
}


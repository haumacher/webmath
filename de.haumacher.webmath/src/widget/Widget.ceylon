import dom {
	Event
}
import ceylon.collection {
	MutableList,
	ArrayList
}

shared abstract class Widget(shared Page page) satisfies Part {
	
	shared actual String id = page.createId();
	
	variable MutableList<Widget>? _contents = null;
	
	shared void render(TagOutput output) {
		if (exists contents = _contents) {
			contents.clear();
		}
		page.start(this);
		_display(output);
		page.end(this);
	}
	
	shared formal void _display(TagOutput output);
	
	shared void add(Widget widget) {
		MutableList<Widget> updatableContents;
		if (exists contents = _contents) {
			updatableContents = contents;
		} else {
			updatableContents = ArrayList<Widget>();
			_contents = updatableContents;
		}
		updatableContents.add(widget);
	}
	
	shared List<Widget> getContents() {
		if (exists contents = _contents) {
			return contents;
		} else {
			return empty;
		}
	}
	
	shared default void onChange(Event event) {
		// Hook for subclasses.
	}
	
}
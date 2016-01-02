import dom {
	Document,
	Element,
	Event
}
import ceylon.collection {
	MutableMap,
	HashMap,
	MutableList,
	ArrayList
}

shared class Page(shared Document document, shared Element root) {
	
	MutableList<Widget> openWidgets = ArrayList<Widget>();
	
	MutableMap<String, Widget> widgetsById = HashMap<String, Widget>();
	
	MutableMap<String, Widget> repaintsById = HashMap<String, Widget>();
	
	variable Integer nextId = 0;
	
	shared String createId() {
		return "c" + (nextId++).string;
	}
	
	shared void init() {
		document.addEventListener("change", onChange);
	}
	
	void onChange(Event event) {
		variable Element target = event.target;
		
		while (true) {
			if (exists id = target.id) {
				if (exists widget = widgetsById.get(id)) {
					widget.onChange(event);
					break;
				}
			}
			
			if (exists parent = target.parentNode) {
				target = parent;
			} else {
				break;
			}
		}
		
		revalidate();
	}
	
	shared void append(Widget widget) => appendElement(root, widget);
	
	shared void update(Widget widget) {
		Element? element = document.getElementById(widget.id);
		assert (exists element);
		
		remove(widget);
		
		assert (exists parent = element.parentNode);
		parent.replaceChild(createElement(widget), element);
	}
	
	void appendElement(Element rootElement, Widget widget) {
		rootElement.appendChild(createElement(widget));
	}
	
	Element createElement(Widget widget) {
		value buffer = render(widget);
		value element = document.createElement("div");
		element.innerHTML = buffer.string;
		value widgetElement = element.firstChild;
		assert (exists widgetElement);
		return widgetElement;
	}
	
	TagOutput render(Widget widget) {
		assert (openWidgets.empty);
		
		value buffer = TagOutput();
		widget.render(buffer);
		
		assert (openWidgets.empty);
		
		return buffer;
	}
	
	shared void start(Widget widget) {
		insert(widget);
		
		value last = openWidgets.last;
		if (exists last) {
			last.add(widget);
		}
		openWidgets.add(widget);
	}
	
	shared void end(Widget widget) {
		value last = openWidgets.deleteLast();
		assert (exists last);
		assert (last == widget);
	}
	
	void insert(Widget widget) {
		value clash = widgetsById.get(widget.id);
		assert (!(clash exists));
		widgetsById.put(widget.id, widget);
	}
	
	void remove(Widget widget) {
		widgetsById.remove(widget.id);
		
		widget.getContents().each((content) => remove(content));
	}
	
	shared void requestRepaint(Widget widget) {
		if (widgetsById.defines(widget.id)) {
			repaintsById.put(widget.id, widget);
			widget.getContents().each(dropRepaint);
		}
	}
	
	void dropRepaint(Widget widget) {
		repaintsById.remove(widget.id);
		widget.getContents().each(dropRepaint);
	}

	void revalidate() {
		repaintsById.each((entry) => update(entry.item));
		repaintsById.clear();
	}
}
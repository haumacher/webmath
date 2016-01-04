import widget {
	Page,
	Widget,
	TagOutput
}

shared class Text extends Widget {
	variable String _text;
	
	shared new (Page page, String text) extends Widget(page) {
		_text = text;
	}
	
	shared actual void _display(TagOutput output) {
		output.tag("span").attribute("id", id).text(_text).end();
	}
	
	shared String text => _text;
	
	assign text {
		_text = text;
		invalidate();
	}
}
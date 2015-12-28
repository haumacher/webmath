shared dynamic Node {

	// FIXME: Declared Element instead of Node, because casting is hard/impossible.
	shared formal Element? parentNode;
	
	shared formal Element? firstChild;
	shared formal Element? lastChild;
	shared formal Element? nextSibling;
	
	shared formal void appendChild(Node newChild);
	shared formal void replaceChild(Node newChild, Node oldChild);
	shared formal void insertBefore(Node newNode, Node referenceNode);
	
}
shared dynamic Event {
	"A boolean indicating whether the event bubbles up through the DOM or not."
	shared formal Boolean bubbles;
	
	"A boolean indicating whether the event is cancelable."
	shared formal Boolean cancelable;
	
	"Identifies the current target for the event, as the event traverses the DOM. It always refers to the element the event handler has been attached to as opposed to event.target which identifies the element on which the event occurred."
	shared formal Element currentTarget;
	
	"Returns a boolean indicating whether or not event.preventDefault() was called on the event."
	shared formal Boolean defaultPrevented;
	
	"Indicates which phase of the event flow is being processed."
	shared formal Integer eventPhase;
	
	"A reference to the object that dispatched the event. It is different from event.currentTarget when the event handler is called during the bubbling or capturing phase of the event."
	shared formal Element target;
	
	"Returns the time (in milliseconds since the epoch) at which the event was created."
	shared formal Integer timeStamp;
	
	"The Event.type read-only property returns a string containing the type of event. It is set when the event is constructed and is the name commonly used to refer to the specific event."
	shared formal String type;
}
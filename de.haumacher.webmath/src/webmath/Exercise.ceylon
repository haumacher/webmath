import ceylon.collection {
	HashSet,
	MutableSet
}

import widget {
	Widget,
	Page,
	IntegerField,
	TagOutput,
	Property,
	PropertyValue,
	PropertyListener,
	PropertyObservable
}

shared class TypeConfig(
	shared variable ExerciseType type,
	shared variable Float probability = 1.0
) {}

shared class ExerciseConfig
satisfies Factory<ExerciseType.Exercise> 
{
	TypeConfig[] _types;
	Float[] _probabilitySum;
	Float _probabilityTotal;
	
	shared new(TypeConfig[] types) {
		_types = types;
		
		variable Float sum = 0.0;
		Float sumOfPrefix(Float x) {
			sum += x;
			return sum;
		}
		_probabilitySum = [for (type in types) sumOfPrefix(type.probability)];
		_probabilityTotal = sum;
	}
	
	shared actual ExerciseType.Exercise create() {
		Float rnd = randomUnit() * _probabilityTotal;
		
		assert (exists index = _probabilitySum.indexesWhere((sum) => rnd <= sum).first);
		assert (exists config = _types[index]);
		return config.type.create();
	}
	
	shared ExerciseType.Exercise[] createExercises(Integer cnt) {
		MutableSet<String> ids = HashSet<String>();
		ExerciseType.Exercise createExerciseWithNewId() {
			while (true) {
				ExerciseType.Exercise task = create(); 
				if (ids.add(task.id())) {
					return task;
				}
			}
		}
		return [for (n in 0..cnt) createExerciseWithNewId()];
	}
	
}

shared void finalizeField(IntegerField field, Boolean correct) {
	field.displayOnly();
	if (correct) {
		field.addClass("resultOk");
	} else {
		field.addClass("resultWrong");
	}
}

shared abstract class State() of open | failed | success {}object open extends State() {}
object success extends State() {}
object failed extends State() {}

shared interface ExerciseDisplay {
	
	shared formal State state;
	
}

shared abstract class ExerciseType() {
	
	shared formal class Exercise() {
		
		shared formal String id();
		
		shared Display display(Page page) { value display = Display(page); display.init(); return display; }
			
		shared formal class Display(Page page) extends Widget(page) satisfies ExerciseDisplay {
			variable State _state = open;
			
			shared actual State state => _state;
			
			shared default void init() {
				// Hook for sub-classes.
			}
			
			shared void finish(Boolean successful) {
				value before = _state;
				value after = if (successful) then success else failed;
				_state = after;
				notifyChange(`ExerciseDisplay.state`, before, after);
			}
			
			shared actual void _display(TagOutput output) {
				output.tag("div").attribute("id", id).attribute("class", "exercise");
				_displayContents(output);
				output.end("div");
			}
			
			shared formal void _displayContents(TagOutput output);
		}
	}
	
	shared Exercise create() => Exercise();
	
}

shared abstract class SingleResultType() extends ExerciseType() {
	
	shared actual abstract default class Exercise() extends super.Exercise() {
		shared formal Integer result;
		
		shared actual abstract default class Display(Page page) extends super.Display(page) {
			
			IntegerField createResultField() {
				value field = IntegerField(page);
				PropertyListener check = object satisfies PropertyListener {
					shared actual void notifyChanged(PropertyObservable observable, Property property, PropertyValue before, PropertyValue after) {
						if (exists after) {
							assert (is IntegerField observable);
							finalizeField(observable, after == result);
						}
					}
				};
				field.addPropertyListener(`IntegerField.intValue`, check);
				return field;
			}
			
			shared IntegerField resultField = createResultField();
		}
		
	}
}

shared abstract class BinaryOperandType() extends SingleResultType() {

	shared actual abstract default class Exercise() extends super.Exercise() {
		shared formal Integer left;
		shared formal Integer right;
		
		shared actual abstract default class Display(Page page) extends super.Display(page) {
			
			shared formal String operator();
			
			shared actual void _displayContents(TagOutput output) {
				output.text(left.string);
				output.text(" ");
				output.text(operator());
				output.text(" ");
				output.text(right.string);
				output.text(" = ");
				resultField.render(output);
			}
			
		}
	}
}

class ExercisesDisplay(Page page, Widget[] widgets) extends Widget(page) {
	shared actual void _display(TagOutput output) {
		output.tag("div").attribute("id", id).attribute("class", "exercises");
		widgets.each((x) => x.render(output));
		output.end("div");
	}
}

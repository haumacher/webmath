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
	PropertyObservable,
	observable
}

shared class TypeConfig(
	shared variable ExerciseType type,
	shared variable Float probability = 1.0
) {}

shared class ExerciseConfig(Integer cnt, TypeConfig[] types)
satisfies Factory<ExerciseType.Exercise> 
{
	Float[] _probabilitySum;
	Float _probabilityTotal;
	
	if (true) {
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
		assert (exists config = types[index]);
		return config.type.create();
	}
	
	shared ExerciseType.Exercise[] createExercises() {
		MutableSet<String> ids = HashSet<String>();
		ExerciseType.Exercise createExerciseWithNewId() {
			while (true) {
				ExerciseType.Exercise task = create(); 
				if (ids.add(task.id())) {
					return task;
				}
			}
		}
		return [for (n in 1..cnt) createExerciseWithNewId()];
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
			
			shared IntegerField resultField = IntegerField(page);
			
			shared actual void init() {
				super.init();
				
				PropertyListener check = object satisfies PropertyListener {
					shared actual void notifyChanged(PropertyObservable observable, Property property, PropertyValue before, PropertyValue after) {
						if (exists after) {
							assert (is IntegerField observable);
							value successful = after == result;
							finalizeField(observable, successful);
							finish(successful);
						}
					}
				};
				resultField.addPropertyListener(`IntegerField.intValue`, check);
			}
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

class ExercisesDisplay(Page page) extends Widget(page) {
	
	variable ExerciseConfig? _config = null;
	
	shared variable ExerciseType.Exercise[] exercises = [];
	observable shared variable <ExerciseDisplay&Widget>[] exerciseDisplays = [];

	void init() {
		if (exists config = _config) {
			exercises = config.createExercises();
			exerciseDisplays = [for (x in exercises) x.display(page)];
		}
	}
	
	init();
	
	observable shared ExerciseConfig? config => _config;
	
	assign config {
		PropertyValue before = _config;
		_config = config;
		notifyChange(`ExercisesDisplay.config`, before, config);
		
		update();
	}
	
	void update() {
		PropertyValue before = exerciseDisplays;
		init();
		notifyChange(`exerciseDisplays`, before, exerciseDisplays);
		invalidate();
	}
	
	shared actual void _display(TagOutput output) {
		output.tag("div").attribute("id", id).attribute("class", "exercises");
		exerciseDisplays.each((x) => x.render(output));
		output.end("div");
	}
}

class ResultDisplay(Page page, ExercisesDisplay display) extends Widget(page) {
	Text time = Text(page, "");
	IntegerField correctCntDisplay = IntegerField(page);
	IntegerField wrongCntDisplay = IntegerField(page);
	
	correctCntDisplay.displayOnly();
	correctCntDisplay.addClass("resultOk");
	wrongCntDisplay.displayOnly();
	wrongCntDisplay.addClass("resultWrong");
	
	variable Integer start = 0;
	variable Integer correctCnt = 0;
	variable Integer wrongCnt = 0;
	
	void init() {
		time.text = "0 Minuten";
		correctCnt = 0;
		wrongCnt = 0;
		start = system.milliseconds;
		correctCntDisplay.intValue = correctCnt;
		wrongCntDisplay.intValue = wrongCnt;
	}
	
	PropertyListener counter = object satisfies PropertyListener {
		shared actual void notifyChanged(PropertyObservable observable, Property property, PropertyValue before, PropertyValue after) {
			Integer elapsed = (system.milliseconds - start) / 1000;
			Integer minutes = elapsed / 60;
			Integer seconds = elapsed % 60;
			
			value minutesString = if (minutes > 0) then minutes.string + " Minuten und " else "";
			time.text = minutesString + seconds.string + " Sekunden";
			
			assert (is State after);
			switch (after) 
			case (open) {}
			case (success) {
				correctCnt++;
				correctCntDisplay.intValue = correctCnt;
			}
			case (failed) {
				wrongCnt++;
				wrongCntDisplay.intValue = wrongCnt;
			}
		}
	};
	
	class Update() satisfies PropertyListener {
		shared void attach() {
			init();
			
			display.exerciseDisplays.each((display) => display.addPropertyListener(`ExerciseDisplay.state`, counter));
			display.addPropertyListener(`ExercisesDisplay.exerciseDisplays`, this);
		}
		
		shared actual void notifyChanged(PropertyObservable observable, Property property, PropertyValue before, PropertyValue after) {
			assert (is <ExerciseDisplay&Widget>[] before);
			before.each((display) => display.removePropertyListener(`ExerciseDisplay.state`, counter));
			
			attach();
		}
	}
	
	Update update = Update();
	update.attach();
	
	shared actual void _display(TagOutput output) {
		output.tag("div").attribute("id", id);
		output.text("Von " + display.exercises.size.string + " Aufgaben hast Du in ");
		time.render(output);
		output.text(" ");
		correctCntDisplay.render(output);
		output.text(" richtig und ");
		wrongCntDisplay.render(output);
		output.text(" falsch gelöst.");
		output.end("div");
	}
}

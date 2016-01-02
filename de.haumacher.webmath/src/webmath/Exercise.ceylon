import widget {
	Widget,
	Page,
	IntegerField,
	TagOutput
}
import ceylon.collection {

	HashSet,
	MutableSet
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
	field.disabled = true;
	if (correct) {
		field.addClass("resultOk");
	} else {
		field.addClass("resultWrong");
	}
}

shared abstract class ExerciseType() {
	
	shared formal class Exercise() {
		
		shared formal String id();
		
		shared Display display(Page page) => Display(page);
			
		shared formal class Display(Page page) extends Widget(page) {
			
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
				field.onUpdate = (IntegerField self, Integer? val) {
					if (exists val) {
						finalizeField(self, val == result);
					}
				};
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
			
			shared actual void _display(TagOutput output) {
				output.tag("div").attribute("id", id);
				output.text(left.string);
				output.text(" ");
				output.text(operator());
				output.text(" ");
				output.text(right.string);
				output.text(" = ");
				resultField.render(output);
				output.end("div");
			}
			
		}
	}
}

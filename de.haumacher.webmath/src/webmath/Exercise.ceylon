import widget {
	Widget,
	Page,
	IntegerField,
	TagOutput
}

shared class TypeConfig(
	shared variable ExerciseType type,
	shared variable Float probability = 1.0
) {}

shared class ExerciseConfig
satisfies Factory<Exercise> 
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
	
	shared actual Exercise create() {
		Float rnd = randomUnit() * _probabilityTotal;
		
		assert (exists index = _probabilitySum.indexesWhere((sum) => rnd <= sum).first);
		assert (exists config = _types[index]);
		return config.type.create();
	}
	
}

shared abstract class Display(Page page) extends Widget(page) {
	
}

shared abstract class Exercise() {
	
	shared formal String id();
	
	shared formal Display display(Page page);
}

shared abstract class SingleResultExercise() extends Exercise() {
	shared formal Integer result;
}

shared abstract class SingleResultDisplay<E> extends Display 
	given E satisfies SingleResultExercise
{
	
	E _exercise;
	IntegerField _resultField;
	
	shared new (Page page, E exercise) extends Display(page) {
		_exercise = exercise;
		
		value resultField = IntegerField(page);
		
		_resultField = resultField;
		_resultField.onUpdate = (Integer? val) {
			if (exists val) {
				// FIXME: Workaround for compiler bug that produces an uninitialized outer$ reference, if directly accessing the member _resultField.
				resultField.disabled = true;
				if (val == exercise.result) {
					resultField.addClass("resultOk");
				} else {
					resultField.addClass("resultWrong");
				}
			}
		};
	}
	
	shared IntegerField resultField => _resultField;
	shared E exercise => _exercise;
}

shared abstract class BinaryOperandExercise() extends SingleResultExercise() {
	shared formal Integer left;
	shared formal Integer right;
}


shared abstract class BinaryOperandDisplay<E>(Page page, E exercise) extends SingleResultDisplay<E>(page, exercise) 
	given E satisfies BinaryOperandExercise
{
	
	shared formal String operator();
	
	shared actual void _display(TagOutput output) {
		output.tag("div").attribute("id", id);
		output.text(exercise.left.string);
		output.text(" ");
		output.text(operator());
		output.text(" ");
		output.text(exercise.right.string);
		output.text(" = ");
		resultField.render(output);
		output.end("div");
	}
	
}

shared abstract class ExerciseType() satisfies Factory<Exercise> {
	
}

shared class OperandConfig(
	shared variable Range operandRange,
	shared variable Range resultRange
) {
	shared Integer randomOperand() => operandRange.randomValue();
	shared Boolean acceptResult(Integer result) => resultRange.contains(result);
}

shared class AdditionConfig(
	Range operandRange = Range(1, 100),
	Range resultRange = Range(1, 100),
	shared variable Float carryProbability = 0.8
) extends OperandConfig(operandRange, resultRange) {
	shared Boolean randomCarry() => randomBoolean(carryProbability);
}

shared class AdditionType(
	AdditionConfig config
) extends ExerciseType() {
	shared actual Addition create() => Addition(config);
}

shared class Addition extends BinaryOperandExercise {
	
	shared actual Integer left;
	shared actual Integer right;
	shared actual Integer result;
	
	shared new(AdditionConfig config) extends BinaryOperandExercise() {
		Boolean carry = config.randomCarry();
		while (true) {
			Integer leftTry = config.randomOperand();
			Integer rightTry = config.randomOperand();
			Integer resultTry = leftTry + rightTry;
			
			if (!config.acceptResult(resultTry)) {
				continue;
			}
			
			value hasCarry = (leftTry % 10) + (rightTry % 10) >= 10;
			// FIXME: Use XOR operator, exists?
			if (!(carry && hasCarry || (!carry && !hasCarry))) {
				continue;
			}
			
			left = leftTry;
			right = rightTry;
			result = resultTry;
			break;
		}
	}
	
	shared actual String id() => max{left, right}.string + "+" + min{left, right}.string;
	
	shared actual Display display(Page page) => AdditionDisplay(page, this);
}

shared class AdditionDisplay(Page page, Addition exercise) extends BinaryOperandDisplay<Addition>(page, exercise) {

	shared actual String operator() => "+";
	
}

shared class SubstractionConfig(
	shared variable Range baseRange = Range(1, 100),
	Range operandRange = Range(1, 100),
	Range resultRange = Range(1, 100),
	Float carryProbability = 0.8
) 
	extends AdditionConfig(operandRange, resultRange, carryProbability)
{
	shared Integer randomBase() => baseRange.randomValue();
}

shared class SubstractionType(
	SubstractionConfig config
) extends ExerciseType() {
	shared actual Substraction create() => Substraction(config);
}

shared class Substraction extends BinaryOperandExercise {
	
	shared actual Integer left;
	shared actual Integer right;
	shared actual Integer result;
	
	shared new(SubstractionConfig config) extends BinaryOperandExercise() {
		Boolean carry = config.randomCarry();
		while (true) {
			Integer leftTry = config.randomBase();
			Integer rightTry = config.randomOperand();
			Integer resultTry = leftTry - rightTry;
			
			if (!config.acceptResult(resultTry)) {
				continue;
			}
			
			value hasCarry = (leftTry % 10) < (rightTry % 10);
			// FIXME: Use XOR operator, exists?
			if (!(carry && hasCarry || (!carry && !hasCarry))) {
				continue;
			}
			
			left = leftTry;
			right = rightTry;
			result = resultTry;
			break;
		}
	}
	
	shared actual String id() => left.string + "-" + right.string;
	
	shared actual Display display(Page page) => SubstractionDisplay(page, this);
}

shared class SubstractionDisplay(Page page, Substraction exercise) extends BinaryOperandDisplay<Substraction>(page, exercise) {
	
	shared actual String operator() => "-";
	
}

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
				field.onUpdate = (Integer? val) {
					if (exists val) {
						field.disabled = true;
						if (val == result) {
							field.addClass("resultOk");
						} else {
							field.addClass("resultWrong");
						}
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

shared class Addition(
	AdditionConfig config
) extends BinaryOperandType() {
	
	shared actual class Exercise() extends super.Exercise() {
		
		shared actual Integer left;
		shared actual Integer right;
		shared actual Integer result;
		
		// FIXME: Move to an initializer with its own scope. E.g. the variable carry should not be a member of Exercise, but a local variable of the initializer.
		// {
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
		// }
		
		shared actual String id() => max{left, right}.string + "+" + min{left, right}.string;
		
		shared actual class Display(Page page) extends super.Display(page) {
			shared actual String operator() => "+";
		}
	}
	
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

shared class Substraction(
	SubstractionConfig config
) extends BinaryOperandType() {
	
	shared actual class Exercise() extends super.Exercise() {
		
		shared actual Integer left;
		shared actual Integer right;
		shared actual Integer result;
		
		// FIXME: Move to an initializer with its own scope. E.g. the variable carry should not be a member of Exercise, but a local variable of the initializer.
		// {
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
		// }
		
		shared actual String id() => left.string + "-" + right.string;
		
		shared actual class Display(Page page) extends super.Display(page) {
			shared actual String operator() => "-";
		}
	}

}


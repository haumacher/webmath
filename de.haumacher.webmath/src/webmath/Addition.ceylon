import widget {
	Page
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
		if (true) {
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
		
		shared actual class Display(Page page) extends super.Display(page) {
			shared actual String operator() => "+";
		}
	}
	
}
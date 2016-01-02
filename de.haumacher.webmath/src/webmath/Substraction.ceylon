import widget {
	Page
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
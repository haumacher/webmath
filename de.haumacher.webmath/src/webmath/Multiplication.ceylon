import widget {
	Page
}

shared class MultiplicationConfig(
	Range operandRange = Range(1, 10),
	Range resultRange = Range(1, 100)
) 
{
	shared Integer randomOperand() => operandRange.randomValue();
	shared Boolean acceptResult(Integer x) => resultRange.contains(x);
}

shared class Multiplication(
	MultiplicationConfig config
) extends BinaryOperandType() {
	
	shared actual class Exercise() extends super.Exercise() {
		
		shared actual Integer left;
		shared actual Integer right;
		shared actual Integer result;
		
		while (true) {
			Integer leftTry = config.randomOperand();
			Integer rightTry = config.randomOperand();
			Integer resultTry = leftTry * rightTry;
			
			if (!config.acceptResult(resultTry)) {
				continue;
			}
			
			left = leftTry;
			right = rightTry;
			result = resultTry;
			break;
		}
		
		shared actual String id() => left.string + "*" + right.string;
		
		shared actual class Display(Page page) extends super.Display(page) {
			shared actual String operator() => "*";
		}
	}

}
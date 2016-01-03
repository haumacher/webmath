import widget {
	Page,
	TagOutput,
	IntegerField,
	Property,
	PropertyValue
}

shared class DivisionConfig(
	shared Range baseRange = Range(1, 100),
	shared Range operandRange = Range(2, 10),
	shared Range resultRange = Range(1, 10),
	shared Float remainderProbability = 0.5
) {
	shared Integer randomBase() => baseRange.randomValue();
	shared Integer randomOperand() => operandRange.randomValue();
	shared Boolean randomRemainder() => randomBoolean(remainderProbability);
	shared Boolean acceptResult(Integer result) => resultRange.contains(result);
}

shared class Division(
	DivisionConfig config = DivisionConfig()
) extends ExerciseType() {
	
	shared actual class Exercise() extends super.Exercise() {
		
		shared Integer left;
		shared Integer right;
		shared Integer result;
		shared Integer remainder;
		
		// FIXME: Move to an initializer with its own scope. E.g. the variable carry should not be a member of Exercise, but a local variable of the initializer.
		if (true) {
			Boolean remainderRequired = config.randomRemainder();
			while (true) {
				Integer leftTry = config.randomBase();
				Integer rightTry = config.randomOperand();
				Integer resultTry = leftTry / rightTry;
				
				if (!config.acceptResult(resultTry)) {
					continue;
				}
				
				Integer remainderTry = leftTry % rightTry;
				
				value hasRemainder = (remainderTry > 0);
				// FIXME: Use XOR operator, exists?
				if (!(remainderRequired && hasRemainder || (!remainderRequired && !hasRemainder))) {
					continue;
				}
				
				left = leftTry;
				right = rightTry;
				result = resultTry;
				remainder = remainderTry;
				break;
			}
		}
		
		shared actual String id() => left.string + "-" + right.string;
		
		shared Boolean hasRemainder() => remainder > 0;
		
		shared actual class Display(Page page) extends super.Display(page) {
			
			IntegerField createResultField() {
				value field = IntegerField(page);
				return field;
			}
			
			IntegerField createRemainderField() {
				value field = IntegerField(page);
				if (!hasRemainder()) {
					// Initialize field, since it is not displayed, but the update logic of 
					// the result field depends on the remainder value being initialized.
					field.setValue(0);
				}
				return field;
			}
			
			IntegerField resultField = createResultField();
			IntegerField remainderField = createRemainderField();
			
			shared actual void init() {
				resultField.addPropertyListener(`IntegerField.intValue`, updateFields);
				remainderField.addPropertyListener(`IntegerField.intValue`, updateFields);
			}
			
			void updateFields(Object self, Property attr, PropertyValue before, PropertyValue after) { 
				if (exists resultInput = resultField.intValue, exists remainderInput = remainderField.intValue) {
					value resultOk = resultInput == result;
					finalizeField(resultField, resultOk);
					value remainderOk = remainderInput == remainder;
					finalizeField(remainderField, remainderOk);
					
					finish(resultOk && remainderOk);
				}
			}
			
			shared actual void _displayContents(TagOutput output) {
				output.text(left.string);
				output.text(" : ");
				output.text(right.string);
				output.text(" = ");
				resultField.render(output);
				if (hasRemainder()) {
					output.text(" R ");
					remainderField.render(output);
				}
			}
			
		}
	}

}
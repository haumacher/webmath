import widget {
	Widget,
	Page,
	IntegerField,
	TagOutput
}

shared class AdditionConfig() {
	shared variable Range operandRange = Range(0, 100);
	shared variable Range resultRange = Range(0, 100);
	shared variable Float carryProbability = 0.5;
	
	shared Integer randomOperand() => operandRange.randomValue();
	shared Boolean acceptResult(Integer result) => resultRange.contains(result);
	shared Boolean randomCarry() => randomBoolean(carryProbability);
}

shared class Addition {
	
	Integer _left;
	Integer _right;
	Integer _result;
	
	shared new(AdditionConfig config) {
		Boolean carry = config.randomCarry();
		while (true) {
			Integer left = config.randomOperand();
			Integer right = config.randomOperand();
			Integer result = left + right;
			
			if (!config.acceptResult(result)) {
				continue;
			}
			
			value hasCarry = (left % 10) + (right % 10) >= 10;
			if (!(carry && hasCarry || (!carry && !hasCarry))) {
				continue;
			}
			
			_left = left;
			_right = right;
			_result = result;
			break;
		}
	}
	
	shared Integer left => _left;
	shared Integer right => _right;
	shared Integer result => _result;
	
}

shared class AdditionDisplay extends Widget {
	IntegerField _resultField;
	
	Addition _addition;
	
	shared new (Page page, Addition addition) extends Widget(page) {
		_addition = addition;
		
		value resultField = IntegerField(page);
		_resultField = resultField;
		_resultField.onUpdate = (Integer? val) {
			if (exists val) {
				resultField.disabled = true;
				if (val == addition.result) {
					resultField.addClass("resultOk");
				} else {
					resultField.addClass("resultWrong");
				}
			}
		};
	}
	
	shared actual void _display(TagOutput output) {
		output.tag("div").attribute("id", id);
		output.text(_addition.left.string);
		output.text(" + ");
		output.text(_addition.right.string);
		output.text(" = ");
		_resultField.render(output);
		output.end("div");
	}
	
}


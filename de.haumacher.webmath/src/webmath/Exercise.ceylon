import widget {
	Widget,
	Page,
	IntegerField,
	TagOutput
}

shared class Range(shared Integer min, shared Integer max) {
	shared Boolean contains(Integer val) => val >= min && val <= max;
	shared Integer randomValue() => randomRange(min, max);
}

shared class AdditionConfig() {
	shared variable Range operandRange = Range(0, 100);
	shared variable Range resultRange = Range(0, 100);
	shared variable Float carryProbability = 0.5;
	
	shared Integer randomOperand() => operandRange.randomValue();
	shared Boolean acceptResult(Integer result) => resultRange.contains(result);
	shared Boolean randomCarry() => randomBoolean(carryProbability);
}

shared class Addition extends Widget {
	Integer _left;
	Integer _right;
	IntegerField _resultField;
	
	shared new (Page page, AdditionConfig config) extends Widget(page) {
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
			value resultField = IntegerField(page);
			_resultField = resultField;
			_resultField.onUpdate = (Integer? val) {
				if (exists val) {
					resultField.disabled = true;
					if (val == result) {
						resultField.addClass("resultOk");
					} else {
						resultField.addClass("resultWrong");
					}
				}
			};
			
			break;
		}
		
	}
	
	shared actual void _display(TagOutput output) {
		output.tag("div").attribute("id", id);
		output.text(_left.string);
		output.text(" + ");
		output.text(_right.string);
		output.text(" = ");
		_resultField.render(output);
		output.end("div");
	}
	
}

Boolean randomBoolean(Float probability) {
	return randomUnit() < probability;
}

Integer randomInt(Integer limit) {
	return (randomUnit() * limit).integer;
}

Integer randomRange(Integer min, Integer max) {
	return min + (randomUnit() * (max - min + 1)).integer;
}

Float randomUnit() {
	Float rnd;
	dynamic {
		rnd = Math.random();
	}
	return rnd;
}

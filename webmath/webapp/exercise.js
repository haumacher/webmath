exerciseCount = 20;
columnCount = 3;

exerciseTypes = [
	Addition, 
	Substraction, 
	Multiplication,
	Division,
	RestDivision
];

maxNumner = 20;
maxOperand = 10;
minOperand = 1;

additionConfig = {
	probability: 1,
	inverseProbability: 0,
	maxBase: maxNumner,
	maxOperand: maxOperand,
	minOperand: minOperand,
	maxResult: maxNumner
};

substractionConfig = {
	probability: 1,
	maxBase: maxNumner,
	maxOperand: maxOperand,
	minOperand: minOperand
};

multiplicationConfig = {
	probability: 0,
	inverseProbability: 0,
	minOperand: 2,
	maxOperand: 10
};

divisionConfig = {
	probability: 0,
	maxOperand: 10,
	maxResult: 10
};

restDivisionConfig = {
	probability: 0,
	maxOperand: 10,
	maxResult: 10
};

function extend(sub, base) {
	var origProto = sub.prototype;
	sub.prototype = Object.create(base.prototype);
	for ( var key in origProto) {
		sub.prototype[key] = origProto[key];
	}
	sub.prototype.constructor = sub;
	Object.defineProperty(sub.prototype, 'constructor', {
		enumerable : false,
		value : sub
	});
}

function randomInt(limit) {
	return Math.floor((Math.random() * limit)) | 0
}

function randomBoolean(trueProbability) {
	return Math.random() <= trueProbability;
}

var nextId = 1;
function newId() {
	return "c" + (nextId++);
}

function makeExercise() {
	var exercise;
	do {
		var sumProbability = 0.0;
		for (var n = 0, cnt = exerciseTypes.length; n < cnt; n++) {
			var exerciseType = exerciseTypes[n];
			sumProbability += exerciseType.prototype.getProbability();
		}

		var operationChoice = Math.random() * sumProbability;
		for (var n = 0, cnt = exerciseTypes.length; n < cnt; n++) {
			var exerciseType = exerciseTypes[n];
			
			operationChoice -= exerciseType.prototype.getProbability();
			if (operationChoice < 0.0 || n + 1 == cnt) {
				exercise = exerciseType.prototype.createExercise();
				break;
			}
		}

	} while (!exercise.isOk());
	
	return exercise;
}

function Input(expected) {
	this.id = newId();
	this.expected = "" + expected;
}

Input.prototype = {

	isCorrect: function() {
		return document.getElementById(this.id).value == this.expected;
	},
	
	print: function() {
		document.write('<input class="eingabe" type="text" id="' + this.id + '" autocomplete="off"/>');
	},
	
	getElement: function() {
		return document.getElementById(this.id);
	},
	
	hasValue: function() {
		return this.getElement().value != "";
	},
	
	disable: function() {
		this.getElement().disabled = true;
	}
}

function Exercise(inputCnt) {
	this.okId = newId();
	this.input = 2;
	this.inputIds = [];
}

Exercise.prototype = {
	createExercise: function() {
		throw new Error("Abstract method: createExercise()");
	},
	
	addInput: function(expected) {
		this.inputIds.push(new Input(expected));
	},
	
	getProbability: function() {
		return this.config.probability;
	},

	createDisplay : function() {
		this.print();
		this.init();
	},
	
	print : function() {
		document.write('<div class="aufgabe">');
		document.write('<div id="' + this.okId + '">');

		this.printExercise();
		this.printFeedback();

		document.write('</div>');
		document.write('</div>');
	},
	
	printExercise: function() {
		this.printPart(0);
		this.printOperator(this.operator);
		this.printPart(1);
		document.write(' = ');
		this.printPart(2);
	},
	
	printOperator(operator) {
		document.write(' ' + operator + ' ');
	},

	printPart : function(index) {
		if (index == this.input) {
			this.inputIds[0].print();
		} else {
			this.printValue(this.getValue(index));
		}
	},
	
	printValue: function(value) {
		document.write('<span>');
		document.write(value);
		document.write('</span>');
	},
	
	printFeedback: function() {
		document.write('<span class="result">');
		document.write('<span class="passed">');
		document.write('&#x2713;');
		document.write('</span>');
		document.write('<span class="failed">');
		document.write('&#x274C;');
		document.write('</span>');
		document.write('</span>');
	},

	init: function() {
		var expected = this.getValue(this.input);

		for (var n = 0, cnt = this.inputIds.length; n < cnt; n++) {
			var input = this.inputIds[n];
			var element = input.getElement();
			element.addEventListener("focus", function() {
				if (doneCnt == 0) {
					startTime = new Date().getTime();
					document.getElementById("timing").style.visibility = "visible";
				}
			});
			
			var self = this;
			element.addEventListener("change", function() {
				self.checkInputs();
			});
		}
	},
	
	checkInputs: function() {
		var ok = true;
		for (var n = 0, cnt = this.inputIds.length; n < cnt; n++) {
			var input = this.inputIds[n];
			if (!input.hasValue()) {
				return;
			}
			ok = ok && input.isCorrect();
		}
		
		this.markResult(ok);
	},
	
	markResult: function(ok) {
		var okMarker = document.getElementById(this.okId);
		if (ok) {
			okMarker.className = "passed"
			countPassed();
		} else {
			okMarker.className = "failed"
			countFailed();
		}
		this.disableInput();
	},
	
	disableInput: function() {
		for (var n = 0, cnt = this.inputIds.length; n < cnt; n++) {
			var input = this.inputIds[n];
			input.disable();
		}
	},
	
	getValue : function(index) {
		switch (index) {
		case 0:
			return this.left;
		case 1:
			return this.right;
		case 2:
			return this.result;
		}
	}
}

function Multiplication() {
	Exercise.call(this);

	this.operator = "&#x00b7;";

	var inverse = randomBoolean(multiplicationConfig.inverseProbability);
	if (inverse) {
		this.input = randomInt(2);
	}
	
	this.left = randomInt(multiplicationConfig.maxOperand + 1);
	this.right = randomInt(multiplicationConfig.maxOperand + 1);
	this.result = this.left * this.right;
	
	this.addInput(this.result);
	
	this.key = "M" + Math.max(this.left, this.right) + "_" + Math.min(this.left, this.right);
}

Multiplication.prototype = {
	config: multiplicationConfig,
	
	createExercise: function() {
		return new Multiplication();
	},
	
	isOk : function() {
		if (this.result == 0) {
			// Not unique.
			return false;
		}
		
		if (this.left < multiplicationConfig.minOperand) {
			return false
		}

		if (this.right < multiplicationConfig.minOperand) {
			return false
		}
		
		if (this.result % 10 == 0) {
			return randomBoolean(0.1);
		}
		
		return true;
	}
}

extend(Multiplication, Exercise);

function Division() {
	Exercise.call(this);
	
	this.operator = ":";
	
	this.right = randomInt(divisionConfig.maxOperand + 1);
	this.result = randomInt(divisionConfig.maxResult + 1);
	this.left = this.right * this.result;
	
	this.addInput(this.result);

	this.key = "D" + this.left + "_" + this.right;
}

Division.prototype = {
	config: divisionConfig,
	
	createExercise: function() {
		return new Division();
	},
	
	isOk : function() {
		if (this.right < 2) {
			return false;
		}
		
		if (this.result < 2) {
			return false;
		}
		
		if (this.left % 10 == 0 || this.right % 10 == 0 || this.result % 10 == 0) {
			return randomBoolean(0.1);
		}
		
		return true;
	}
	
}

extend(Division, Exercise);

function RestDivision() {
	Exercise.call(this, 2);
	
	this.right = randomInt(divisionConfig.maxOperand + 1);
	this.result = randomInt(divisionConfig.maxResult + 1);
	this.rest = randomInt(this.right);
	this.left = this.right * this.result + this.rest;
	
	this.addInput(this.result);
	this.addInput(this.rest);
	
	this.key = "R" + this.left + "_" + this.right + "_" + this.rest;
}

RestDivision.prototype = {
	config: restDivisionConfig,
	
	createExercise: function() {
		return new RestDivision();
	},
	
	isOk : function() {
		if (this.right < 2) {
			return false;
		}
		
		if (this.result < 2) {
			return false;
		}
		
		if (this.rest == 0) {
			return false;
		}
		
		if (this.left % 10 == 0 || this.right % 10 == 0 || this.result % 10 == 0) {
			return randomBoolean(0.1);
		}
		
		return true;
	},
	
	printExercise: function() {
		this.printValue(this.left);
		this.printOperator(":");
		this.printValue(this.right);
		document.write(' = ');
		this.inputIds[0].print();
		document.write(' Rest ');
		this.inputIds[1].print();
	}
}

extend(RestDivision, Exercise);

function Addition() {
	Exercise.call(this);

	this.operator = "+";

	var inverse = randomBoolean(additionConfig.inverseProbability);
	if (inverse) {
		this.input = randomInt(2);
	}
	
	this.left = randomInt(additionConfig.maxBase + 1);
	this.right = additionConfig.minOperand + randomInt(additionConfig.maxOperand - additionConfig.minOperand + 1);
	this.result = this.left + this.right;
	
	this.addInput(this.result);

	this.key = "A" + Math.max(this.left, this.right) + "_" + Math.min(this.left, this.right);
}

Addition.prototype = {
	config: additionConfig,
	
	createExercise: function() {
		return new Addition();
	},
	
	isOk : function() {
		if (this.result < 0) {
			return false;
		}

		if (this.result > additionConfig.maxResult) {
			return false;
		}
		
		if (this.left == 0) {
			return false;
		}

		if (this.right == 0) {
			return false;
		}
		
		if (this.result == 0) {
			return false;
		}
		
		return true;
	}
}

extend(Addition, Exercise);

function Substraction() {
	Exercise.call(this);
	
	this.operator = "-";
	
	this.left = randomInt(substractionConfig.maxBase + 1);
	this.right = substractionConfig.minOperand + randomInt(substractionConfig.maxOperand - substractionConfig.minOperand + 1);
	this.result = this.left - this.right;
	
	this.addInput(this.result);

	this.key = "S" + this.left + "_" + this.right;
}

Substraction.prototype = {
	config: substractionConfig,
	
	createExercise: function() {
		return new Substraction();
	},
	
	isOk : function() {
		if (this.result < 0) {
			return false;
		}
		
		if (this.left == 0) {
			return false;
		}
		
		if (this.right == 0) {
			return false;
		}
		
		if (this.result == 0) {
			return false;
		}
		
		return true;
	}
}

extend(Substraction, Exercise);

var startTime = 0;
var elapsedTime = 0;
var doneCnt = 0;
var passedCnt = 0;
var failedCnt = 0;

function updateDone() {
	document.getElementById("doneCnt").innerHTML = "" + doneCnt;
}

function updateElapsed() {
	var elapsedMinutes = Math.floor(elapsedTime / 1000 / 60);
	var elapsedSeconds = Math.floor((elapsedTime - elapsedMinutes * 1000 * 60) / 1000);

	document.getElementById("elapsedMinutes").innerHTML = "" + (elapsedMinutes);
	document.getElementById("elapsedSeconds").innerHTML = "" + (elapsedSeconds);
}

function updatePassed() {
	document.getElementById("passedCnt").innerHTML = "" + passedCnt;
}

function updateFailed() {
	document.getElementById("failedCnt").innerHTML = "" + failedCnt;
}

function countPassed() {
	countDone();

	passedCnt++;
	updatePassed();
}

function countFailed() {
	countDone();

	failedCnt++;
	updateFailed();
}

function countDone() {
	doneCnt++;
	updateDone();

	elapsedTime = new Date().getTime() - startTime;
	updateElapsed();
}

var exercises = [];

function printExercises() {
	var keys = {};
	
	document.write('<div class="exercises">');
	document.write('<div class="row">');
	for (var n = 0, column = 0; n < exerciseCount; n++, column++) {
		var exercise;
		var failed = 0;
		while (true) {
			exercise = makeExercise();
			if (keys[exercise.key] == null) {
				keys[exercise.key] = exercise;
				break;
			}
			
			failed++;
			if (failed > 100) {
				// There are probably no more unique exercises.
				exercise = null;
				break;
			}
		}
		
		if (exercise == null) {
			break;
		}

		if (column == columnCount) {
			column = 0;
			document.write('</div>');
			document.write('<div class="row">');
		}
		exercises.push(exercise);
		exercise.createDisplay();
	}
	document.write('</div>');
	document.write('</div>');
}

function initExercises() {
	updateDone();
	updateElapsed();
	updatePassed();
	updateFailed();
}
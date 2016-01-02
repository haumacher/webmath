
import dom {
	Document,
	Element
}

import widget {
	Page
}

Document document() {
	dynamic {
		return window.document;
	}
}

Page createPage(String? rootId) {
	Element root;
	if (exists rootId) {
		assert (exists specifiedRoot = document().getElementById(rootId));
		root = specifiedRoot;
	} else {
		root = document().documentElement;
	}
	value page = Page(document(), root);
	page.init();
	return page;
}

"Run the module `webmath`."
shared void run(String? rootId) {
	value config = 
		ExerciseConfig([
			TypeConfig { 
				probability = 1.0;
				type = Addition( 
					AdditionConfig {
						operandRange = Range(11,200);
						resultRange = Range(41,200);
						carryProbability = 0.9;
					}
				); 
			},
			TypeConfig { 
				probability = 2.0;
				type = Substraction(
					SubstractionConfig {
						baseRange = Range(100,200);
						operandRange = Range(11,200);
						resultRange = Range(21,200);
						carryProbability = 0.9;
					}
				); 
			},
			TypeConfig { 
				probability = 0.5;
				type = Multiplication(
					MultiplicationConfig {
						operandRange = Range(2,10);
					}
				); 
			},
			TypeConfig { 
				probability = 2.0;
				type = Division(
					DivisionConfig {
						operandRange = Range(2,10);
						remainderProbability = 0.7;
						resultRange = Range(1,10);
					}
				); 
			}
		]);
		
	value exercises = config.createExercises(60);
	
	value page = createPage(rootId);
	
	exercises.each((ExerciseType.Exercise exercise) {page.append(exercise.display(page));});
}


import dom {

	Document
}
import widget {

	Page
}
import ceylon.collection {
	HashSet,
	MutableSet
}

Document document() {
	dynamic {
		return window.document;
	}
}

"Run the module `webmath`."
shared void run() {
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
			}
		]);
		
	MutableSet<String> ids = HashSet<String>();
	ExerciseType.Exercise createTaskWithNewId() {
		while (true) {
			ExerciseType.Exercise task = config.create(); 
			if (ids.add(task.id())) {
				return task;
			}
		}
	}
	ExerciseType.Exercise[] tasks = [for (n in 0..9) createTaskWithNewId()];
	
	value page = Page(document());
	page.init();
	
	tasks.each((ExerciseType.Exercise task) {page.append(task.display(page));});
}

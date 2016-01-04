
import dom {
	Document,
	Element
}

import widget {
	Page,
	PropertyListener,
	PropertyObservable,
	PropertyValue,
	Property,
	SelectField
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
		ExerciseConfig(60, [
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
						operandRange = Range(2,9);
						resultRange = Range(20, 100);
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
		
	value configSimple = 
		ExerciseConfig(60, [
			TypeConfig { 
				probability = 1.0;
				type = Addition( 
					AdditionConfig {
						operandRange = Range(2,10);
						resultRange = Range(1,20);
						carryProbability = 0.3;
					}
				); 
			},
			TypeConfig { 
				probability = 2.0;
				type = Substraction(
					SubstractionConfig {
						baseRange = Range(1,20);
						operandRange = Range(1,10);
						resultRange = Range(1,100);
						carryProbability = 0.3;
					}
				); 
			},
			TypeConfig { 
				probability = 1.0;
				type = Multiplication(
					MultiplicationConfig {
						operandRange = Range(2,4);
						resultRange = Range(1, 100);
					}
				); 
			},
			TypeConfig { 
				probability = 1.0;
				type = Division(
					DivisionConfig {
						baseRange = Range(2, 20);
						operandRange = Range(2, 3);
						remainderProbability = 0.0;
						resultRange = Range(1,10);
					}
				); 
			}
		]);
		
	value page = createPage(rootId);
		
	value display = ExercisesDisplay(page);
	
	value select= SelectField<String->ExerciseConfig>(page, [
		"1. Klasse" -> configSimple,
		"3. Klasse" -> config
	]);
	select.label = (Entry<String, Object> entry) => entry.key;
	PropertyListener update = object satisfies PropertyListener {
		shared actual void notifyChanged(PropertyObservable observable, Property property, PropertyValue before, PropertyValue after) {
			if (exists entry = select.selected) {
				display.config = entry.item;
			}
		}
	};
	select.addPropertyListener(`SelectField<String->ExerciseConfig>.selected`, update);
	select.selectedIndex = 0;
	
	page.append(select);
	page.append(display);
	page.append(ResultDisplay(page, display));

}

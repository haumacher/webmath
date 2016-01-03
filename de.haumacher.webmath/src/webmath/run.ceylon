
import dom {
	Document,
	Element
}

import widget {
	Page,
	Widget,
	TagOutput,
	PropertyListener,
	PropertyObservable,
	PropertyValue,
	Property,
	IntegerField
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
		
	value exercises = config.createExercises(60);
	
	value page = createPage(rootId);
	
	value exerciseDisplays = [for (x in exercises) x.display(page)];
	
	page.append(ExercisesDisplay(page, exerciseDisplays));
	
	class Block(Page page, Widget[] contents) extends Widget(page) {
		shared actual void _display(TagOutput output) {
			output.tag("div").attribute("id", id);
			contents.each((c) => c.render(output));
			output.end("div");
		}
	}
	
	class Text extends Widget {
		variable String _text;
		
		shared new (Page page, String text) extends Widget(page) {
			_text = text;
		}

		shared actual void _display(TagOutput output) {
			output.tag("span").attribute("id", id).text(_text).end();
		}

		shared String text => _text;
		
		assign text {
			_text = text;
			invalidate();
		}
	}
	
	variable Text time;
	variable IntegerField correctCntDisplay;
	variable IntegerField wrongCntDisplay;
	
	Block result = Block(page, [
		Text(page, "Von " + exercises.size.string + " Aufgaben hast Du in "),
		time = Text(page, "0 Minuten"),
		Text(page, " "),
		correctCntDisplay = IntegerField(page),
		Text(page, " richtig und "),
		wrongCntDisplay = IntegerField(page),
		Text(page, " falsch gelöst.")
	]);
	
	correctCntDisplay.displayOnly();
	correctCntDisplay.addClass("resultOk");
	wrongCntDisplay.displayOnly();
	wrongCntDisplay.addClass("resultWrong");
	
	PropertyListener counter = object satisfies PropertyListener {
		
		Integer start = system.milliseconds;
		
		variable Integer correctCnt = 0;
		variable Integer wrongCnt = 0;
		
		correctCntDisplay.intValue = correctCnt;
		wrongCntDisplay.intValue = wrongCnt;
		
		shared actual void notifyChanged(PropertyObservable observable, Property property, PropertyValue before, PropertyValue after) {
			Integer elapsed = (system.milliseconds - start) / 1000;
			Integer minutes = elapsed / 60;
			Integer seconds = elapsed % 60;
			
			value minutesString = if (minutes > 0) then minutes.string + " Minuten und " else "";
			time.text = minutesString + seconds.string + " Sekunden";
			
			assert (is State after);
			switch (after) 
			case (open) {}
			case (success) {
				correctCnt++;
				correctCntDisplay.intValue = correctCnt;
			}
			case (failed) {
				wrongCnt++;
				wrongCntDisplay.intValue = wrongCnt;
			}
		}
	};
	exerciseDisplays.each((display) => display.addPropertyListener(`ExerciseDisplay.state`, counter));
	
	page.append(result);

}

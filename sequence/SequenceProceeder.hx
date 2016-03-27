package sequence ;

import openfl.display.Sprite;
import input.KeyInput;

/**
 * ...
 * @author peperontium
 */

class SequenceProceeder {

	private var _currentSequence: ISequence;
	private var _mainScreen : Sprite;

	public function new(display:Sprite) {
		_mainScreen = display;
//		_currentSequence = new Title();
	}
	
	public function proceed() {
		
		_mainScreen.graphics.clear();
		KeyInput.get.update();
		
		var nextSeq = _currentSequence.proceed();
		_currentSequence.render(_mainScreen);
		
		switch(nextSeq) {
			case SequenceName.CONTINUE:
				null;
				
			case SequenceName.END:
			#if (system)
			Sys.exit(0);
			#end
		};
	}
	
}
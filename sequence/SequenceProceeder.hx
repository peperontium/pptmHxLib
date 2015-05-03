package sequence ;

import openfl.display.Sprite;

/**
 * ...
 * @author peperontium
 */

class SequenceProceeder {

	private var _currentSequence: ISequence;
	private var _mainScreen : Sprite;
//	public var _sharedData	: SequenceSharedData;

	public function new(display:Sprite) {
		_mainScreen = display;
		_currentSequence = new GameMain();
	}
	
	public function Proceed() {
		switch(_nowSequence.Proceed()) {
			case SequenceName.GAMEMAIN:
				_currentSequence.release(_mainScreen);
//				_currentSequence = new GameMain();
			
			case SequenceName.CONTINUE:
				null;
				
			case SequenceName.END:
			#if (!flash)
			Sys.exit(0);
			#end
		};
	}
	
}
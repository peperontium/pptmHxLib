package sequence ;
import openfl.display.Sprite;

/**
 * ...
 * @author peperontium
 */

interface ISequence{
	public function Proceed():SequenceName;
	
	public function Release() : Void;
}
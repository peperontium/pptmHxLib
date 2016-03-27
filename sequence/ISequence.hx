package sequence ;
import openfl.display.Sprite;

/**
 * ...
 * @author peperontium
 */

interface ISequence{
	public function proceed():SequenceName;
	public function render(screen:Sprite):Void;
}
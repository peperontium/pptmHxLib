package input;


/**
 * ...
 * @author peperontium
 */


//	OpenFL
import openfl.Vector;
//import openfl._v2.Vector;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;

//	メイン画面にキーフォーカスをあてるために
import openfl.Lib;


class KeyInput{
	
	static public var get(default, never) = new KeyInput();
	
	private var _keyState:Vector<Vector<Bool>>;
			var _stateCode:Int; 
			var _isInited:Bool;
	
	//	イベントリスナ
	function _OnKeyDown(event:KeyboardEvent) {
		_keyState[_stateCode][event.keyCode] = true;
	}
	
	function _OnKeyUp(event:KeyboardEvent) {
		_keyState[_stateCode][event.keyCode] = false;
	}
	
	function _DeActivate(e:Event) {
		for(i in 0..._keyState[_stateCode].length){
			_keyState[_stateCode].set(i,false);
			_keyState[(_stateCode+1) % 2].set(i,false);
		}
	}
	
	//	ここまでイベントリスナ
		
	public function update():Void {
		var t = (_stateCode + 1) % 2;
		
		_keyState[t] = _keyState[_stateCode].slice();
		
		_stateCode = t;
		
	}
	
	inline function new() {
	
		_keyState = new Vector(2,true);
		_keyState[0] = new Vector(256,true);	//	空要素にアクセスし得るので予め領域取っておく
		_keyState[1] = new Vector(256,true);
		_stateCode = 0;
		_isInited = false;
		
	}
	
	public function init() {
		if (_isInited)
			return;
			
		_isInited = true;
	
		//	一部プラットフォームだとnew内部でcurrentstageにアクセスできないのでここで初期化。（static 変数の初期化タイミングの問題だと思う）
		//	それと弱参照使えないプラットフォームもあるようなのので気を付けること。
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, _OnKeyDown,false,0,true);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, _OnKeyUp, false, 0, true);
		
		//	画面フォーカスが失われた時にキー入力情報リセット
		Lib.current.stage.addEventListener(Event.DEACTIVATE, _DeActivate,false,0,true);

	}
	
	public inline function isPushKey(KeyCode:UInt):Bool {
		return(if(_keyState[_stateCode][KeyCode] == true) true else false);
	}
	
	public inline function isJustKey(KeyCode:UInt):Bool {
		return(if((_keyState[_stateCode][KeyCode] == true) && (_keyState[(_stateCode+1)%2][KeyCode] != true)) true else false);
	}
	
}
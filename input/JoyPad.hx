package input;

/**
 * ...
 * @author peperontium
 */


import openfl.Vector;
import openfl.events.Event;
import openfl.Lib;
import openfl.events.JoystickEvent;
import openfl.geom.Point;
import openfl.display.Sprite;

#if !(cpp || neko || android )
import input.KeyInput;
import openfl.ui.Keyboard;
#end


private typedef JoyStickState = { Stick : Vector<Point>, Button : Vector<Bool> , PreButton:Vector<Bool> }


#if (cpp || neko || android )

class JoyPad {
	//		X
	//	Y		A
	//		B
	static inline public var B = 2;
	static inline public var A = 1;
	static inline public var X = 0;
	static inline public var Y = 3;
	
	static inline public var L1 = 6;
	static inline public var L2 = 4;
	static inline public var R1 = 7;
	static inline public var R2 = 5;
	
	static inline public var PAUSE = 8;
	static inline public var SELECT  = 9;
	
	
	static inline var JoyPad_Max:Int = 4;
	static inline var NumOfStick:Int = 2;
	static inline var NumOfButton:Int = 10;
	static inline var Stick_Sens = 0.25;	//	スティックの遊び幅
	
	
	//	ここまで定数
	
	public static var get(default,never) = new JoyPad();
	var _stickState : Vector<JoyStickState>;
	var _isInited: Bool;
	
	//	毎回Pointをnewするのはもったいないので使いまわす
	var p : Point;
	
	private function new() {
		_isInited = false;
		_stickState = new Vector(JoyPad_Max,true);
		p = new Point();
		
		for (i in 0...JoyPad_Max) {
			_stickState[i] = {	Stick : new Vector(NumOfStick, true),
							Button : new Vector(NumOfButton, true) ,
							PreButton : new Vector(NumOfButton, true)
							}
			
			for (j in 0...NumOfStick)
				_stickState[i].Stick[j] = new Point(0,0);
			
			for (j in 0...NumOfButton) {
				_stickState[i].Button[j] = false;
				_stickState[i].PreButton[j] = false;
			}
		}
		
	}
	
	public function getLstickState(NumPad:Int) :Point {
		p.x = _stickState[NumPad].Stick[0].x;
		p.y = _stickState[NumPad].Stick[0].y;
		if (Math.abs(p.x) < Stick_Sens)	p.x = 0;
		if (Math.abs(p.y) < Stick_Sens)	p.y = 0;
		return(p);
	}
	
	public function getRstickState(NumPad:Int) :Point {
		p.x = _stickState[NumPad].Stick[1].x;
		p.y = _stickState[NumPad].Stick[1].y;
		if (Math.abs(p.x) < Stick_Sens)	p.x = 0;
		if (Math.abs(p.y) < Stick_Sens)	p.y = 0;
		return(p);
	}
	
	public inline function isButtonPressed(NumPad:Int,KeyCode:Int) :Bool{
		return(_stickState[NumPad].Button[KeyCode]);
	}
	
	public inline function isButtonJustPressed(NumPad:Int,KeyCode:Int) :Bool{
		return(_stickState[NumPad].Button[KeyCode] && !_stickState[NumPad].PreButton[KeyCode]);
	}
	
	public function init():Void {
		if (_isInited)
			return;
		
		_isInited  = true;
		
		Lib.current.stage.addEventListener( JoystickEvent.AXIS_MOVE, _AxisMove);
		Lib.current.stage.addEventListener( JoystickEvent.BUTTON_DOWN, _ButtonDown );
		Lib.current.stage.addEventListener( JoystickEvent.BUTTON_UP, _ButtonUp );
		
		//	毎フレーム処理の実行直前にキー情報更新
		Lib.current.stage.addEventListener( Event.ENTER_FRAME, _UpdateState, false, -1, true);

	}
	
	/*****		ここからイベントリスナ	****/
	
	function _UpdateState(e) :Void{
		for (i in 0...JoyPad_Max)
			_stickState[i].PreButton = _stickState[i].Button.slice();
	}
	
	function _AxisMove(je:JoystickEvent) :Void{
/*		trace ("devicecode = " + je.device);
		trace ("x = "  + je.axis[0]);
		trace ("y = "  + je.axis[1]);
		trace ("x2 = " + je.axis[2]);
		trace ("y2 = " + je.axis[3]);
		return;*/
		var NumPad = je.device;
		_stickState[NumPad].Stick[0].x = je.axis[0];
		_stickState[NumPad].Stick[0].y = je.axis[1];
		_stickState[NumPad].Stick[1].x = je.axis[2];
		_stickState[NumPad].Stick[1].y = je.axis[3];
	}
	
	function _ButtonDown(je:JoystickEvent) :Void{
		var NumPad = je.device;
//		trace ("Button " + je.id + "Pushed");
		_stickState[NumPad].Button[je.id] = true;
	}
	
	function _ButtonUp(je:JoystickEvent) :Void {
		var NumPad = je.device;
		_stickState[NumPad].Button[je.id] = false;
	}
	
}
#else

//	Dummy JoyPad Class	
class JoyPad {
	//		X
	//	Y		A
	//		B
	static public var B = Keyboard.X;
	static public var A = Keyboard.Z;
	static public var X = Keyboard.S;
	static public var Y = Keyboard.D;
	
	static public var L1 = Keyboard.Q;
	static public var L2 = Keyboard.W;
	static public var R1 = Keyboard.E;
	static public var R2 = Keyboard.R;
	
	static public var SELECT = Keyboard.BACKSPACE;
	static public var PAUSE  = Keyboard.ENTER;
	
	//	ここまで定数
	
	
	public static var get(default,never) = new JoyPad();
	inline private function new() {}
	inline public function init() :Void{
		//	キー初期化呼ぶ？別にいい？
		KeyInput.get.init();
	}
	
	public function getLstickState(P:Int) :Point {
		if (P != 0)	return new Point();
		var p = new Point(0.0, 0.0);
		if (KeyInput.get.IsPushKey(Keyboard.LEFT))
			p.x -= 1;
			
		if (KeyInput.get.IsPushKey(Keyboard.RIGHT))
			p.x += 1;
		
		if (KeyInput.get.IsPushKey(Keyboard.UP))
			p.y -= 1;
			
		if (KeyInput.get.IsPushKey(Keyboard.DOWN))
			p.y += 1;
		
		return(p);
	}
	
	inline public function getRstickState(P:Int) :Point {
		var p = new Point(0.0, 0.0);
		return(p);
	}
	
	
	
	public inline function isButtonPressed(NumPad:Int,KeyCode:Int) :Bool{
		return(KeyInput.get.IsPushKey(KeyCode));
	}
	
	public inline function isButtonJustPressed(NumPad:Int,KeyCode:Int) :Bool{
		return(KeyInput.get.IsJustKey(KeyCode));
	}
	
	
}

#end
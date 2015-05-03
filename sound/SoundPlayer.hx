package sound;


/**
 * ...
 * @author peperontium
 */


import openfl.media.SoundTransform;
import openfl.Assets;
import openfl.media.Sound;
import openfl.media.SoundChannel;



class SoundPlayer{
	
	//	BGMのループ回数
	static inline var BGM_LOOP_MAX = 65535;
	//	無限ループを実装したい場合は音楽の再生終了時のSOUND_COMPLETEイベントを取得して再度鳴らす、を繰り返すといいはず。。。
	
	public static var get(default,never) = new SoundPlayer();
	
	var _nowPlayBGM		: SoundChannel;
	var _nowPlayBGMName	: String;
	var _pausePosition	: Float;
	
	private function new() {
		_nowPlayBGM		= null;
		_nowPlayBGMName	= null;
		_pausePosition	= -1;
	}
	
	//	BGMの音量設定
	public inline function setVolume(volume:Float = 1.0) :Void {
		if(_nowPlayBGM != null)
			_nowPlayBGM.soundTransform = new SoundTransform(volume, 0);
	}
	
	public inline function playBGM(bgm:String):Void{
		if (_nowPlayBGM != null)
			_nowPlayBGM.stop();
		_pausePosition = -1;

		_nowPlayBGM = Assets.getSound(bgm).play(0, BGM_LOOP_MAX);
		_nowPlayBGMName = bgm;
	}
	
	//	BGM一時停止
	public inline function pauseBGM():Void{
		if (_nowPlayBGM != null) {
			_pausePosition = _nowPlayBGM.position;
			_nowPlayBGM.stop();
			_nowPlayBGM = null;
		}
	}

	//	BGM一時停止解除
	public inline function restartBGM():Void {
		if (_nowPlayBGMName != null && _pausePosition < 0) {
			_nowPlayBGM = Assets.getSound(_nowPlayBGMName).play(_pausePosition, BGM_LOOP_MAX);
			_pausePosition = -1;
		}
	}
	
	public inline function playSE(se:String, volume:Float = 1.0):Void{
		var se = Assets.getSound(se).play();
		se.soundTransform = new SoundTransform(volume, 0);
	}
}
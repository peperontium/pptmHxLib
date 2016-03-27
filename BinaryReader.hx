package;



#if flash
import openfl.Assets;
import openfl.utils.ByteArray;

#else

import sys.io.File;
import sys.FileSystem;
import haxe.io.Bytes;


#end

/**
 * ...
 * @author peperontium
 */


#if flash
class BinaryReader{
	
	private var _buf : ByteArray;
	
	
	public inline function new(){
		_buf = new ByteArray();
	}
	
	public function importFile(filePath : String):Bool{
		this.dispose();
		
		if(Assets.exists(filePath,AssetType.BINARY)){
			_buf = Assets.getBytes(filePath);
			_buf.endian = openfl.utils.Endian.LITTLE_ENDIAN;
			return true;
		}
		return false;
	}
	
	public inline function eof():Bool {
		return (_buf.length >= _buf.position);
	}
	
	public inline function dispose():Void {
		_buf.clear();
	}
	
	public inline function readFloat():Float{
		return(_buf.readFloat());
	}
	
	public inline function readInt():Int{
		return (_buf.readInt());
	}
}
#else

class BinaryReader{

	
	private var _buf : Bytes;
	private var _bufSize:Int;
	private var _currentPos : Int;
	
	
	public inline function new(){}
	
	public function importFile(filePath : String):Bool{
		this.dispose();
		
		if(FileSystem.exists(filePath)){
			_buf = File.getBytes(filePath);
			_bufSize = _buf.length;
			return true;
		}
		return false;
	}
	
	public inline function eof():Bool {
		return (_bufSize <= _currentPos);
	}
	
	public inline function dispose():Void {
		_buf = null;
		_bufSize = 0;
		_currentPos = 0;
	}
	
	public inline function readFloat():Float {
		var cur = _currentPos;
		_currentPos += 4;
		return (_buf.getFloat(cur));
	}
	
	public inline function readInt() {
		var cur = _currentPos;
		_currentPos += 4;
		return (_buf.get(cur));
	}
}

#end

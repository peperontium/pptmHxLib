package object3D;

/**
 * ...
 * @author peperontium
 */


import away3d.animators.nodes.SkeletonClipNode;
import away3d.animators.*;
import away3d.animators.data.*;
import away3d.animators.transitions.CrossfadeTransition;
import away3d.cameras.*;
import away3d.containers.*;
import away3d.entities.*;
import away3d.events.*;
import away3d.library.*;
import away3d.library.assets.*;
import away3d.loaders.*;
import away3d.loaders.parsers.*;
import away3d.materials.*;
import away3d.textures.*;
import haxe.ds.StringMap;

import openfl.Vector;
import openfl.utils.ByteArray;
import openfl.Assets;



class Model{
	
	//	animation constants
	private static var s_stateTransition:CrossfadeTransition = new CrossfadeTransition(0.5);
	private static var s_meshLoaderShared : MeshLoader = new MeshLoader();
	
	//	animation variables
	var _animator:SkeletonAnimator;
	var _animationSet:SkeletonAnimationSet;
	var _skeleton:Skeleton;
	var _defaultAnim:String;
	
	public var _mesh(default,null):Mesh;
	
	//	各サブメッシュに割り当てるマテリアル
	var _material:TextureMaterial;
	
	//	読み込み中のアニメーション名とデータ
	var _loadingAnimationNames : StringMap<Bool>;
	var _loadingAnimationBytes : Vector<ByteArray>;
	
	//--------------------------
	//	public functions
	//--------------------------
	public inline function new() {}
	
	/**
	 * MD5形式メッシュおよびアニメーション読み込み。既に読み込んである場合は何もしない
	 * @param modelPath	読み込むモデルファイルのパス
	 * @param animNames アニメーション名&ループフラグ のMap
	 * 
	 * アニメーションファイルはモデルと同一階層ディレクトリより読み込みます
	 * 
	 * WARNING : 関数が返ってきた時点では読み込みが終わっていません
	 * @see	isLoadComplete()
	 */
	public function loadAsync(modelPath:String, animNames:StringMap<Bool>):Void{
		
		s_meshLoaderShared.importMeshAsync(modelPath,onAssetComplete);
		
		//	アニメーション無しならここまで
		if (animNames == null)
			return;
		
		var directory:String = modelPath.substr(0, modelPath.lastIndexOf("/")+1);
		
		_loadingAnimationNames = animNames;
		_loadingAnimationBytes = new Vector<ByteArray>();
		for (n in _loadingAnimationNames.keys())
			_loadingAnimationBytes.push(Assets.getBytes(directory + n + ".md5anim"));
	}
	
	/**
	 * @return メッシュやアニメーション情報の読み込みが終了しているかどうか
	 */
	public inline function isLoadComplete():Bool {
		return (_mesh != null && _loadingAnimationNames == null);
	}
	
	
	/**
	 * SubMesh毎にマテリアルを設定
	 * @param materialArray 設定するマテリアルの配列、サイズはSubMesh配列以上のもの
	 */
	public inline function setMaterials(materialArray:Vector<TextureMaterial>):Void {
		for (i in 0..._mesh.subMeshes.length) {
			_mesh.subMeshes[i].material = materialArray[i];
		}
	}
	
	public inline function playAnimiation(animName:String):Void {
		
		_animator.play(animName, s_stateTransition);
	}
	
	public inline function setAnimSpeed(speed:Int):Void {
		_animator.playbackSpeed  = speed;
	}
	
	/**
	 * 非ループアニメーションの再生終了時に移行するアニメーションの設定
	 */
	public inline function setDefaultAnimation(animName:String):Void {
		_defaultAnim = animName;
	}
	
	//--------------------------
	//	private functions
	//--------------------------
	private inline function _LoadAllAnimation():Void {
		if (_animationSet != null && _loadingAnimationNames != null) {
			for(name in _loadingAnimationNames.keys()){
				s_meshLoaderShared.getBundle().loadData(_loadingAnimationBytes.pop(), null, name, new MD5AnimParser());
			}
		}
	}
	
	
	//--------------------------
	//	イベントリスナ類
	//--------------------------
	private function onPlaybackComplete(event:AnimationStateEvent):Void{
		if (_animator.activeState != event.animationState)
			return;
		
		_animator.play(_defaultAnim, s_stateTransition);
	}
	
	private function onAssetComplete(event:Asset3DEvent):Bool {
	
		if (event.asset.assetType == Asset3DType.ANIMATION_NODE) {
		
			var node:SkeletonClipNode = cast(event.asset, SkeletonClipNode);
			var name:String = event.asset.assetNamespace;
			node.name = name;
			node.looping = _loadingAnimationNames.get(name);
			if (!node.looping) {
				node.addEventListener(AnimationStateEvent.PLAYBACK_COMPLETE, onPlaybackComplete,false,0,true);
			}
			
			_animationSet.addAnimation(node);
			
			//	デフォルトアニメーション
			if (_defaultAnim == null) {
				_animator.playbackSpeed = 1.0;
				_defaultAnim = name;
				playAnimiation(name);
			}
			
			//	残り読み込みアニメーションストックが無い（＝すべて読み込み終了）場合
			if (_loadingAnimationBytes.length == 0) {
				_loadingAnimationNames =  null;
				_loadingAnimationBytes =  null;
				return true;
			}

		} else if (event.asset.assetType == Asset3DType.ANIMATION_SET) {
			trace("debug version.");
			
			_animationSet = cast(event.asset, SkeletonAnimationSet);
			_animator = new SkeletonAnimator(_animationSet, _skeleton);
			//_animator.updatePosition = false;
			//_animator.autoUpdate	= false;
			
			
			_LoadAllAnimation();
			//	apply animator
			_mesh.animator = _animator;
			
		} else if (event.asset.assetType == Asset3DType.SKELETON) {
			_skeleton = cast(event.asset, Skeleton);
			
		} else if (event.asset.assetType == Asset3DType.MESH) {
			_mesh = cast(event.asset, Mesh);
			
			if (isLoadComplete())
				return true;
		}
		
		return false;
	}
	
}


private typedef ModelLoadTaskInfo = { meshName : String, callbackFunc: Asset3DEvent->Bool };
class MeshLoader {
	private var _loadTaskList	: List<ModelLoadTaskInfo>;
	private var _currentTask	: Asset3DEvent->Bool;
	private var _assetBundle	: Asset3DLibraryBundle;
	
	public inline function new() {
		_loadTaskList = new List<ModelLoadTaskInfo>();
		_assetBundle  = Asset3DLibrary.getBundle();
		
		_assetBundle.addEventListener(Asset3DEvent.ASSET_COMPLETE, onCurrentTaskComplete,false,0,true);
	}
	
	private function onCurrentTaskComplete(event:Asset3DEvent):Void {
		
		if (_currentTask != null && _currentTask(event) == true) {
			var next = _loadTaskList.pop();
			
			if(next != null)
				_SetNextLoadTask(next.meshName, next.callbackFunc);
			else
				_currentTask = null;
		};
	}
	

	private inline function _SetNextLoadTask(filePath : String, callbackLoadFunc : Asset3DEvent->Bool):Void {
		_currentTask = callbackLoadFunc;
		var meshbytes:ByteArray = Assets.getBytes(filePath);
		_assetBundle.loadData(meshbytes, null, null, new MD5MeshParser());
	}
	
	public inline function getBundle(): Asset3DLibraryBundle {
		return _assetBundle;
	}
	
	//!	現在読み込み中のタスクがなければすぐ読み込み開始、そうでなければリストへ追加。
	//!	コールバック関数は読み込みが終わったらtrueを返すものを。
	public inline function importMeshAsync( meshPath : String, callbackLoadFunc : Asset3DEvent->Bool):Void{
		
		if (_currentTask == null) {
			_SetNextLoadTask(meshPath, callbackLoadFunc);
		}else {
			_loadTaskList.add( { meshName : meshPath, callbackFunc: callbackLoadFunc } );
		}
	}
}
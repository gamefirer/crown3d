package sl2d.texture
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;
	import flash.utils.Dictionary;
	
	import sl2d.slGlobal;


	public class slTexture 
	{
		protected var _refrenceKey:String;
		protected var _uvInfo:Dictionary;
		protected var _validate:Boolean;
		protected var _factory:slTextureFactory;
		protected var _unit:slTextureUnit;
		private var _gcEnable:Boolean;
		public static function FixSpan(span:uint):uint{
			return Math.pow(2, Math.ceil(Math.LOG2E * Math.log(span)));
		}
		public function slTexture(gcEnable:Boolean = true):void{
			_gcEnable = gcEnable;
		}
		
		protected function initialize(factory:slTextureFactory, refreceKey:String):void{
			_refrenceKey = refreceKey;
			_factory = factory;
			_uvInfo = new Dictionary();
			_validate = false;
		}
		
		//获取其真正的贴图信息
		public function getRealTexture(frame:uint):Texture
		{
			if(_unit)
				return _unit.getRealTexture(frame);
			return null;
		}
		
		//该贴图是否有效。
		//对于一些正在加载的图片来说，有可能处于正在加载的状态。
		public function get validate():Boolean{
			return _validate;
		}
		
		
		public function getUVByFrame(frame:uint):Vector.<Number>{
			return _uvInfo[frame];
		}
		
		
		public function deepDispose():void{
			if(_unit){
				_unit.deepDispose();
			}
			_uvInfo = null;
			_unit = null;
			_validate = false;
		}
		//与地址不同。。
		public function get refrenceKey():String{
			return _refrenceKey;
		}
		
		public function setUV(frame:uint, info:Vector.<Number>):void{
			_uvInfo[frame] = info;
		}
		
		//创建单张图片
		protected function createSingleTexture(factory:slTextureFactory, bmd:BitmapData):void{
			_factory = factory;
			_unit = new slTextureUnit(factory, bmd);
		}
		
		//fromeToTextureInfo	某一个帧对于其在位图列表中下表顺序
		protected function createMultipleTexture(factory:slTextureFactory, groupName:String, bmpList:Vector.<BitmapData>, frameToTextureInfo:Dictionary):void{
			_factory = factory;
			_unit = new slTextureUnitList(factory, groupName, bmpList, frameToTextureInfo);
		}
		
		
		//替换贴图
		public function replaceBmpAtIndex(bmp:BitmapData, index:int = 0):void{
			_unit.replaceBmpAtIndex(_factory, bmp, index);
		}
		
		//追加帧
		public function appendFrameAtIndex(frame:int, textureIndex:int, uv:Vector.<Number>):void{
			setUV(frame, uv);
			_unit.appendFrameAtIndex(frame, textureIndex);
		}
		
		
		public function reUploadBmd(byContextUpdate:Boolean = false):void
		{
			_unit.reUploadBmd(_factory, byContextUpdate);
		}
		
		
	}
}

// ___________________________________________________封装贴图的
import away3d.core.managers.Context3DProxy;
import away3d.core.managers.Stage3DProxy;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display3D.textures.Texture;
import flash.utils.Dictionary;

import sl2d.texture.slBmpTexture;
import sl2d.texture.slTexture;
import sl2d.texture.slTextureFactory;
import sl2d.utils.HashTable;

class slTextureUnit
{
	protected var _texture:Texture;
	protected var _bmd:BitmapData;
	protected static function CreateOneTexture(factory:slTextureFactory, image:BitmapData):Texture
	{
		if(image == null) 
			return null;
		var width:int = slTexture.FixSpan(image.width);
		var height:int = slTexture.FixSpan(image.height);
		return factory.uploadBmp(image, width, height);
	}
	//重新上传贴图数据到context中。
	public function reUploadBmd(factory:slTextureFactory, byContextUpdate:Boolean = false):void
	{
		if(_bmd == null)
			return;
		if(byContextUpdate || _texture == null)
		{
			if(_texture)
			{
				Context3DProxy.disposeTexture(_texture);
			}
			_texture = CreateOneTexture(factory, _bmd);
		}
		else
		{
			if(factory.getContextEnable())
			{
				Context3DProxy.uploadTextureFromBitmapData(_texture, _bmd);
			}
		}
	}
	
	public function slTextureUnit(factory:slTextureFactory, bmd:BitmapData = null)
	{
		_bmd = bmd;
		reUploadBmd(factory);
	}
	
	public function deepDispose():int
	{
		if(_texture)
			Context3DProxy.disposeTexture(_texture);
		_texture = null;
		return 0;
	}
	
	public function getRealTexture(frame:uint):Texture{ return _texture; }
	
	public function replaceBmpAtIndex(factory:slTextureFactory, bmp:BitmapData, index:int = 0):void
	{
		_bmd = bmp;
		reUploadBmd(factory, false);
		
	}
	
	public function appendBitmapData(factory:slTextureFactory, bmd:BitmapData):void{
		//单个贴图不存追加问题
		//如果是slTextureUnitList需要被重写
	}
	
	//
	public function appendFrameAtIndex(frame:int, textureIndex:int):void{
		//单个贴图会直接指向到同一个贴图
		//如果是slTextureUnitList需要被重写
		
	}
	
	
	
}






//___________________________________________________从多个图片汇集成一个列表中
class slTextureUnitList extends slTextureUnit
{
	//该dictionary中应该包含多个贴图的引用数据
	private var _textureListRefrence:Dictionary;
	private var _textureList:Vector.<slBmpTexture>;
	private var _groupName:String;
	public function slTextureUnitList(factory:slTextureFactory, groupName:String, bmpList:Vector.<BitmapData>, frameToTextureInfo:Dictionary){
		super(factory, null);
		_groupName = groupName;
		uploadBmpList(factory, bmpList);
		assignFrameToTexture(frameToTextureInfo);
		
	}
	
	override public function reUploadBmd(factory:slTextureFactory, byContextUpdate:Boolean = false):void{
		super.reUploadBmd(factory, byContextUpdate);
		var texture:slBmpTexture;
		for each(texture in _textureList){
			texture.reUploadBmd(false);
		}
	}
	private function assignFrameToTexture(frameToTextureInfo:Dictionary):void{
		_textureListRefrence = new Dictionary();
		var frameString:String;
		var textureIndex:int;
		for(frameString in frameToTextureInfo){
			textureIndex = frameToTextureInfo[frameString];
			_textureListRefrence[frameString] = _textureList[textureIndex];
		}
	}
	
	private function uploadBmpList(factory:slTextureFactory,  bmpList:Vector.<BitmapData>):void{
		_textureList = new Vector.<slBmpTexture>();
		var bmd:BitmapData;
		var texture:slBmpTexture;
		var keyInGroup:String = "";
		for(var i:int = 0; i < bmpList.length; i ++){
			bmd = bmpList[i];
			if(bmd == null) continue;
			keyInGroup = _groupName + "_" + i;
			texture = factory.createBmpTexture(keyInGroup, bmd);
			_textureList.push(texture);
		}
		
	}
	
	override public function deepDispose():int{
		super.deepDispose();
		var texture:slBmpTexture;
		for each(texture in _textureList){
			if(texture)
				texture.deepDispose();
		}
		_textureList = null;
		_textureListRefrence = null;
		return 0;
	}
	
	
	override public function getRealTexture(frame:uint):Texture{
		var unit:slBmpTexture = _textureListRefrence[frame];
		if(unit)
			return unit.getRealTexture(0);
		return null;
	}
	
	
	
	override public function appendBitmapData(factory:slTextureFactory, bmd:BitmapData):void{
		//如果是slTextureUnitList需要被重写
		var length:int = _textureList.length;
		var nameAtGroup:String = _groupName + "_" + length;
		var texture:slBmpTexture = factory.createBmpTexture(nameAtGroup, bmd);
		_textureList.push(texture);
		
	}
	
	override public function appendFrameAtIndex(frame:int, textureIndex:int):void{
		_textureListRefrence[frame] = _textureList[textureIndex];
	}
	
	override public function replaceBmpAtIndex(factory:slTextureFactory, bmp:BitmapData, index:int = 0):void{
		var texture:slBmpTexture = _textureList[index];
		texture.replaceBmpAtIndex(bmp);
		
		
	}
	
	
	
	
	
	
	
	
	
	
}





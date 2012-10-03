package sl2d.texture{
	//_________________________________________
	//slTextTextureHelper
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.engine.*;
	import flash.utils.Dictionary;
	
	import sl2d.slGlobal;
	import sl2d.texture.*;
	
	public class slTextTexture extends slTeamTexture
	{
		protected static var WholeFreshTextureList:Dictionary;
		protected static var WholeShadowTexture:Dictionary;
		protected static const MinFontSize:int = 12;//用于显示12号小的字体
		protected static const MiddleFontSize:int = 16;//用于显示12-16号的字体
		protected static const MaxFontSize:int = 20;//用于显示16-20号的字体
		//所有的字符对于的贴图。
		protected var _charToFrame:Dictionary = new Dictionary();//字符对应帧数
		protected var _charToHelper:Dictionary = new Dictionary();//字符对于贴图的helper类
		protected var _charToBmdsIndex:Dictionary = new Dictionary();//字符对应贴图的下标
		
		
		protected var _helperList:Vector.<slTextTextureHelper> = new Vector.<slTextTextureHelper>();
		protected var _currentHelper:slTextTextureHelper;
		protected var _fontSize:int;
		protected var _shadow:Boolean;
		//_______________________________________________
		public static function getTextureByFontSize(font:int, shadow:Boolean):slTextTexture{
			if(!WholeFreshTextureList){
				WholeFreshTextureList = new Dictionary();
				WholeFreshTextureList[MinFontSize] = new slTextTexture(MinFontSize, false);
				WholeFreshTextureList[MiddleFontSize] = new slTextTexture(MiddleFontSize, false);
				WholeFreshTextureList[MaxFontSize] = new slTextTexture(MaxFontSize, false);
				
				WholeShadowTexture = new Dictionary();
				WholeShadowTexture[MinFontSize] = new slTextTexture(MinFontSize, true);
				WholeShadowTexture[MiddleFontSize] = new slTextTexture(MiddleFontSize, true);
				WholeShadowTexture[MaxFontSize] = new slTextTexture(MaxFontSize, true);
			}
			
			if(font <= MinFontSize){
				font = MinFontSize;
			}else if(font > MinFontSize && font <= MiddleFontSize){
				font = MiddleFontSize;
			}else{
				font = MaxFontSize;
			}
			
			if(shadow){
				return WholeShadowTexture[font];
			}
			return WholeFreshTextureList[font];
			
		}
		
		
		//当前只定义了2中大小的文本。
		//12号和20号，其余大小的文本，都是从这两种文本中拉伸变形的。
		public function slTextTexture(fontSize:int, shadow:Boolean){
			_shadow = shadow;
			_fontSize = fontSize;
			var textureName:String = "Text_Dic_Texture_" + fontSize + "_" + shadow;
			parseBmpList(slGlobal.TextureFactory, new Vector.<BitmapData>, textureName, new Dictionary());
			appendEntity();
		}
		
		protected function appendEntity():void{
			if(_shadow){
				_currentHelper = new slShadowTextTextureHelper(_fontSize);
			}else{
				_currentHelper = new slTextTextureHelper(_fontSize);
			}
			
			_helperList.push(_currentHelper);
			appendBitmapData(_factory, _currentHelper.bitmapData);
			
		}
		
		//贴图中的字体是固定死的
		public function get fixFontSize():int{
			return _fontSize;
		}
		
		protected var _lastFrameIndex:int = 0;
		public function checkCharInLibs(value:String):void{
			if(value == null || value == "") return;
			//第一步，先将不在库中的内容提取出来，再统一追加至贴图中
			var textureWidth:int = slTextTextureHelper.DEFAULT_TEXTURE_WIDTH;
			var textureHeight:int = slTextTextureHelper.DEFAULT_TEXTURE_HEIGHT;
			var i:int;
			var char:String;//单个字符
			var beAppendString:String = "";
			var count:int = value.length;
			for(i = 0; i < count; i ++){
				char = value.charAt(i);
				//在字典中找到了对于的贴图。
				
				if(_charToHelper[char]) continue;
				if(beAppendString.indexOf(char) > -1) continue;
				
				beAppendString += char;
			}
			
			
			
			//第二步在将提取出的字符追加到库中。
			value = beAppendString;
			count = value.length;
			var uvInfo:Vector.<Number>;
			var rect:Rectangle;
			var endLoopNeedReplaceBmp:Boolean = false;//循环结束了之后，是否需要替换贴图。
			for(i = 0; i < count; i ++){
				char = value.charAt(i);
				endLoopNeedReplaceBmp = true;
				//
				rect = _currentHelper.tryAddOneChar(char);
				//满了
				if(rect == null){
					//替换一张图片
					replaceBmpAtIndex(_currentHelper.bitmapData, _helperList.length - 1);
					endLoopNeedReplaceBmp = false;
					appendEntity();
					//这次一定会成功
					rect = _currentHelper.tryAddOneChar(char);
				}
				//给个链接。
				_charToHelper[char] = _currentHelper;
				_charToFrame[char] = _lastFrameIndex;
				_charToBmdsIndex[char] = _helperList.length - 1;
				//
				var l : Number = rect.x/textureWidth;
				var t : Number = rect.y/textureHeight;
				//生成uv数据
				uvInfo = Vector.<Number>([l, t, l + (rect.width/textureWidth), t + (rect.height/textureHeight), 0, 0, rect.width, rect.height]);
				//赋值
				appendFrameAtIndex(_lastFrameIndex, _helperList.length - 1, uvInfo);
				_lastFrameIndex ++;
				
			}
			
			//循环结束，判断是否需要置换贴图
			if(endLoopNeedReplaceBmp){
				replaceBmpAtIndex(_currentHelper.bitmapData, _helperList.length - 1);
			}
			
			
			
			
		}
		
		
		
		public function getCharFrame(char:String):int{
			return _charToFrame[char];
		}
		public function getCharBmdsIndex(char:String):int{
			return _charToBmdsIndex[char];
		}
		
		
		
	}
	
	
	
	
	
	
}





import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.FontStyle;
import flash.text.engine.*;
import flash.utils.Dictionary;

import sl2d.slGlobal;
import sl2d.texture.*;

class slTextTextureHelper{
	internal static const DEFAULT_TEXTURE_WIDTH : uint = 512;
	internal static const DEFAULT_TEXTURE_HEIGHT : uint = 512;
	protected static const DEFAULT_FONT_COLOR : uint = 0xFFFFFFFF;
	protected static const DEFAULT_OFFSET_Y : uint = 16;
	protected static const DEFAULT_LINE_HEIGHT : uint = 22;
	protected var bd : BitmapData;
	protected var lineHeight:Number = 22;
	protected var offset_y:Number = 16;
	protected var bdInvalidated : Boolean = false;
	protected var w : uint = DEFAULT_TEXTURE_WIDTH;
	protected var h : uint = DEFAULT_TEXTURE_HEIGHT;
	protected var tb : TextBlock = new TextBlock();
	protected var tl : TextLine;
	protected var te : TextElement;
	protected var ef : ElementFormat;
	protected var last_w : Number = 0;
	protected var last_h : Number = 0;
	protected var shadow:Boolean;
	protected var mtx : Matrix = new Matrix();
	protected var _isFull : Boolean = false;
	protected var _fontSize:int;
	public function slTextTextureHelper(fontSize:int){
		_fontSize = fontSize;
		lineHeight = _fontSize * (DEFAULT_LINE_HEIGHT / 14);
		offset_y = _fontSize * (DEFAULT_OFFSET_Y / 14);
		bd = new BitmapData(w, h, true, 0x00000000);
		initTe();
	}
	
	protected function initTe():void{
		var fontDescriptionNormal : FontDescription = new FontDescription(slGlobal.TextFontFamily, FontWeight.NORMAL , FontPosture.NORMAL);
		var ef:ElementFormat = new ElementFormat(fontDescriptionNormal);
		ef.fontSize = _fontSize;
		ef.color = DEFAULT_FONT_COLOR;
		te = new TextElement(null, ef);
		
	}
	
	internal function tryAddOneChar(char : String):Rectangle{
		if(!_isFull){
			bdInvalidated = true;
			te.text = char;
			tb.content = te;
			tl = tb.createTextLine(null, 100);
			var rect:Rectangle = tl.getAtomBounds(0);
			if(DEFAULT_TEXTURE_WIDTH < (last_w + rect.width)){
				last_w = 0;
				last_h += lineHeight;
				if(last_h + lineHeight > DEFAULT_TEXTURE_HEIGHT){
					_isFull = true;
					return null;
				}
			}
			
			mtx.tx = last_w;
			mtx.ty = offset_y + last_h;
			
			var clip : Rectangle = new Rectangle(mtx.tx, last_h, rect.width, lineHeight);
			bd.draw(tl, mtx, null, null, clip, true);
			
			last_w += rect.width;
			bdInvalidated = true;
			
			clip.height = lineHeight;
			return clip;
		}
		return null;
		
	}
	
	
	public function get bitmapData():BitmapData{
		return bd;
	}
	
	
	
	
	
}



import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.FontStyle;
import flash.text.engine.*;


class slShadowTextTextureHelper extends slTextTextureHelper{
	private static const DEFAULT_SHADOW_COLOR:uint = 0x303030;
	private var smallTe:TextElement;
	private var smallTl:TextLine;
	private var smallTB:TextBlock = new TextBlock();
	public function slShadowTextTextureHelper(fontSize:int){
		fontSize += 1;
		super(fontSize);
	}
	
	override protected function initTe():void{
		var fontDescriptionNormal : FontDescription = new FontDescription(slGlobal.TextFontFamily, FontWeight.NORMAL , FontPosture.NORMAL);
		var boldDescriptionNormal : FontDescription = new FontDescription(slGlobal.TextFontFamily, FontWeight.NORMAL , FontPosture.NORMAL);
		//
		var ef:ElementFormat = new ElementFormat(boldDescriptionNormal);
		ef.fontSize = _fontSize;
		ef.color = DEFAULT_SHADOW_COLOR;
		te = new TextElement(null, ef);
		//
		var smallEf:ElementFormat = new ElementFormat(fontDescriptionNormal);
		//		smallEf.fontSize = _fontSize - 1;
		smallEf.fontSize = _fontSize;
		smallEf.color = DEFAULT_FONT_COLOR;
		
		smallTe = new TextElement(null, smallEf);
		
	}
	override internal function tryAddOneChar(char : String):Rectangle{
		if(!_isFull){
			bdInvalidated = true;
			te.text = char;
			tb.content = te;
			tl = tb.createTextLine(null, 100);
			var rect:Rectangle = tl.getAtomBounds(0);
			
			
			if(DEFAULT_TEXTURE_WIDTH < (last_w + rect.width)){
				last_w = 0;
				last_h += lineHeight;
				if(last_h + lineHeight > DEFAULT_TEXTURE_HEIGHT){
					_isFull = true;
					return null;
				}
			}
			
			
			smallTe.text = char;
			smallTB.content = smallTe;
			smallTl = smallTB.createTextLine(null, 100);
			
			var smallRect:Rectangle = smallTl.getAtomBounds(0);
			
			mtx.tx = last_w;
			mtx.ty = offset_y + last_h;
			
			var clip : Rectangle = new Rectangle(mtx.tx, last_h, rect.width, lineHeight);
			bd.draw(tl, mtx, null, null, clip, true);
			//
			mtx.tx -= 0.6;
			mtx.ty -= 0.8;
			bd.draw(smallTl, mtx, null, null, clip, true);
			//
			last_w += rect.width;
			bdInvalidated = true;
			
			clip.height = lineHeight;
			return clip;
		}
		return null;
		
	}
	
	
	
	
	
}












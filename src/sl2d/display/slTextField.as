package sl2d.display
{
	import flash.geom.Rectangle;
	
	import sl2d.texture.*;

	public class slTextField extends slUnion
	{
		private var _last_w : uint = 0;
		private var _last_h : uint = 0;
		private var _fontSize : uint = 12;
		private var _lineWidth : uint = 100;
		private var _charScale : Number = 1;
		private var _text : String;
		private var _textTexture:slTextTexture;
		private var _textWidth:Number = 0;
		private var _textHeight:Number = 0;
		private var _shadow:Boolean;
		private static const _RecycleList:Vector.<slBounds> = new Vector.<slBounds>();
		
		
		/**
		 * 
		 * @param size
		 * @param lineWidth
		 * @param colorValue
		 * 
		 */		
		public function slTextField(size : uint, lineWidth : uint, shadow:Boolean = false, colorValue:uint = 0xFFFFFF){
			_lineWidth = lineWidth;
			//是否有阴影。
			_shadow = shadow;
			fontSize = size;
			color = colorValue;
		}
		

		public function set text(value : String) : void {
			if(value == null) value = "";
			if(_text == value) return;
			_textTexture.checkCharInLibs(value);
			_text = value;
			removeAllChildren();
			createLines(value);
		}
	
		public function get text() : String {
			return _text;
		}

		
		public function set fontSize(value:uint) : void {
			_fontSize = value;
			var newTexture:slTextTexture = slTextTexture.getTextureByFontSize(fontSize, _shadow);
			if(newTexture != _textTexture){
				_textTexture = newTexture;
				textureRef = newTexture;
				//换贴图了。
				//刷新一下bound list。。。
				text = _text;
			}
			_unionTexture = _textTexture;
			_unionShader = _shader;
			_charScale = _fontSize/_textTexture.fixFontSize; 
		}

		public function get fontSize() : uint {
			return _fontSize;
		}


	
		public function set lineWidth(value:uint) : void {
			_lineWidth = value;
		}

		public function get lineWidth() : uint {
			return _lineWidth;
		}
		override public function get groupWidth():int{
			return _textWidth * _scaleInfo.x;
		}
		
		override public function get groupHeight():int{
			return _textHeight * _scaleInfo.y;
		}
		
		protected function createLines(str : String) : void {
			_last_w = _last_h = 0;
			_textWidth = _textHeight = 0;
			var len : uint = str.length;
			var i:int = 0;
			var frame:int;
			var char:String;
			for(i = 0; i < len; i++) {
				char = str.charAt(i);
				var bounds : slBounds = _RecycleList.shift();
				if(bounds == null) bounds = new slBounds();
				bounds.textureRef = _textTexture;
				//获取帧数。
				frame = _textTexture.getCharFrame(char);
				bounds.gotoFrame(frame);
				bounds.color = _color;
				bounds.alpha = _alpha;
				bounds.textureRef = _textTexture;
				if((_last_w + bounds.width) > _lineWidth){
					_last_h += Math.ceil(bounds.height * _charScale);
					_last_w = 0;
				}
				bounds.x = _last_w;
				bounds.y = _last_h;
				bounds.width = Math.ceil(bounds.width * _charScale);
				bounds.height = Math.ceil(bounds.height * _charScale);
				addChild(bounds);

				_last_w += bounds.width;
				_textWidth = (_textWidth < _last_w) ? _last_w : _textWidth;
			}
			if(bounds){
				_textHeight = bounds.y + bounds.height;
			}
			
			
			
		}
		
		override public function setScale(scaleX:Number=1, scaleY:Number=1):void{
			var newScaleX:Number = scaleX / _scaleInfo.x;
			var newScaleY:Number = scaleY / _scaleInfo.y;
			_scaleInfo.setPosition(scaleX, scaleY);
			var char:slBounds;
			for each(char in _children){
				if(char == null) continue;
				char.x *= newScaleX;
				char.y *= newScaleY;
				char.setScale(scaleX, scaleY);
			}
		}
		
		
		override public function set color(value:Number):void{
			super.color = value;
			var item:slObject;
			for each(item in _children){
				item.color = value;
			}
		}
		
		
		override public function set alpha(value:Number):void{
			if(value < 0) value = 0;
			if(value > 1) value = 1;
			if(_alpha == value) return;
			super.alpha = value;
			var item:slObject;
			for each(item in _children){
				item.alpha = value;
			}
		}
		
		override public function removeAllChildren():void{
			var child:slBounds;
			while(_numChildren != 0){
				child = removeChild(_children[_numChildren - 1]) as slBounds;
				if(child == null) continue;
				child.setScale(1, 1);
//				child.dispose();
				_RecycleList.push(child);
			}
		}
		
		override public function dispose():void{
			text = "";
			super.dispose();
		}
		
		
		//
		override internal function get insideViewPort():Boolean{
			_globalRect.setTo(_globalX, _globalY, groupWidth, groupHeight);
			return _globalRect.intersects(slGlobal.ViewPort);
		}
		
//		override public function collectRenderer():void{
//			if(visible && insideViewPort){
//				//画自己
//				super.collectRenderer();
//				//画孩子
//				var child : slObject;
//				for(var i : int = 0; i < _numChildren; i++) {
//					child = _children[i];
////					child.hDepth = 0;
//					//没有离开视窗。
//					if(child.insideViewPort) 
//						child.collectRenderer();
//				}
//			}
//		}
		
	}
}

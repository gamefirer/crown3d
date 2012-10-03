package sl2d.display
{
	import away3d.debug.Debug;
	
	import flash.display3D.textures.Texture;
	
	import sl2d.shader.slProgram;
	import sl2d.shader.slShader;
	import sl2d.slGlobal;
	import sl2d.texture.slTexture;
	import sl2d.texture.slTextureFactory;

	public class slBounds extends slObject 
	{
		private var _frameIndex :int = -1;
		private var _validate:Boolean = false;
		private var _coordVector:Vector.<Number>;
		private var _texture:Texture;
		private var _textureRef:slTexture;
		private var _frameDirty:Boolean = true;
		private var _textureDirty:Boolean = true;
		private var _vDirty : Boolean = true; //vertex dirty
		private var _uDirty : Boolean = true; //uv dirty
		private var _colorDirty : Boolean = true; //color dirty
		private var _alphaDirty : Boolean = true; //alpha dirty
		private static var _TextureFactory:slTextureFactory;			// 贴图工厂
		public var useFloatPos:Boolean = false;
		private var _colorData:Vector.<Number> = Vector.<Number>([1, 1, 1, 1]);
		
		public static function initFactory(factory:slTextureFactory):void
		{
			_TextureFactory = factory;
		}
		
		// 01(位置va0) 23(UV va1)
		private var _boundsInfo:Vector.<Number> = Vector.<Number>([
			0,0,0,0,
			0,0,0,0,
			0,0,0,0,
			0,0,0,0
		]);
		
		public function slBounds() : void 
		{

		}
		public function get textureFactory():slTextureFactory
		{
			return _TextureFactory;
		}

		public function set textureRef(texture:slTexture):void
		{
			if(texture != _textureRef){
				_textureRef = texture;
				_textureDirty = true;
			}
		}
		
		override internal function setTextureDirty():void
		{
			_textureDirty = true;
		}
		
		override public function setScale(scaleX:Number=1, scaleY:Number=1):void
		{
			super.setScale(scaleX, scaleY);
			_vDirty = true;
		}
		
		public function get textureRef():slTexture
		{
			return _textureRef;
		}
		
		public function setGraphicInfo(texture:slTexture, shader:slProgram):void
		{
			_shader = shader;
			textureRef = texture;
		}
		
		public function set shader(value:slProgram):void
		{
			_shader = value;
		}
		
		public function get shader():slProgram
		{
			return _shader;
		}
		
		
		override public function dispose():void
		{
			_frameIndex = -1;
			_texture = null;
			textureRef = null;
			_validate = true;
			_coordVector = null;
			_shader = slShader.Alpha;
			
			_vDirty = true;
			_uDirty = true;
			_colorDirty = true;
			_frameDirty = true;
			_textureDirty = true;
			_boundsInfo.length = 0;
			_boundsInfo.length = 4 * 4;
			_colorData[0] = _colorData[1] = _colorData[2] = _colorData[3] = 1;
			super.dispose();
		}
		

		override public function set x(value : Number) : void
		{
			if(_x != value)
			{
				_x = value;
				_vDirty = true;
			}
		}

		override public function set y(value : Number) : void 
		{
			if(_y != value)
			{
				_y = value;
				_vDirty = true;
			}
		}
		
		override public function set alpha(value:Number):void
		{
			if(value < 0) value = 0;
			if(value > 1) value = 1;
			if(_alpha != value)
			{
				_alpha = value;
				_alphaDirty = true;
			}
			
		}
		
		override public function get alpha():Number
		{
			return _alpha;
		}

		override public function setPosition(X:Number, Y:Number):void
		{
			if(_x != X || _y != Y)
			{
				_vDirty = true;
				super.setPosition(X, Y);
			}
		}

		override public function set width(value:Number):void
		{
			var tWidth:Number = textureWidth;
			if(tWidth != 0)
			{
				_scaleInfo.x = value / tWidth;
			}
			else
			{
				_scaleInfo.x = 1;
			}
			
			if(_width != value)
			{
				_vDirty = true;
				super.width = value;
			}
		}
		
		override public function setSize(w:uint, h:uint):void
		{
			width = w;
			height = h;
		}
		
		override public function set height(value:Number):void 
		{
			var tHeight:Number = textureHeight;
			if(tHeight != 0)
			{
				_scaleInfo.y = value / tHeight;
			}
			else
			{
				_scaleInfo.y = 1;
			}
			
			if(_height != value)
			{
				_vDirty = true;
				super.height = value;
			}
			
		}

		override public function set color(value:Number):void 
		{
			if(value < 0) value = 0;
			if(value > 0xFFFFFF) throw new Error("slBounds:Color Value Cann't Be Bigger than 0xFFFFFF");
			if(_color != value)
			{
				_color = value;
				_colorDirty = true;
			}
		}
		
		private function get textureWidth():Number
		{
			if(_textureRef == null) return super.width;
			var vec:Vector.<Number> = _textureRef.getUVByFrame(_frameIndex);
			if(vec == null) return super.width;
			return vec[6];
		}
		
		override public function get width():Number
		{
			if(_textureRef == null) return super.width;
			var vec:Vector.<Number> = _textureRef.getUVByFrame(_frameIndex);
			if(vec == null) return super.width;
			return vec[6] * _scaleInfo.x;
			
		}
		
		private function get textureHeight():Number
		{
			if(_textureRef == null) return super.width;
			var vec:Vector.<Number> = _textureRef.getUVByFrame(_frameIndex);
			if(vec == null) return super.width;
			return vec[7];
		}
		
		override public function get height():Number
		{
			if(_textureRef == null) return super.width;
			var vec:Vector.<Number> = _textureRef.getUVByFrame(_frameIndex);
			if(vec == null) return super.width;
			return vec[7] * _scaleInfo.y;
			
		}
		
		public function gotoFrame(frame:int):void
		{
			if(frame != _frameIndex){
				_frameDirty = true;
				_frameIndex = frame;
			}
			
		}
		
		public function offsetFrame(offset:int):void
		{
			gotoFrame(_frameIndex + offset);
		}
		
		private function checkStatus():void
		{
			if(_textureRef == null || !_textureRef.validate)
			{
				_validate = false;
			}
			else
			{
//				_textureDirty = _textureDirty || _textureRef.getTextureDirty(_frameIndex);
				if(_frameDirty || _textureDirty)
				{
					_uDirty = true;
					_vDirty = true;
					_coordVector = _textureRef.getUVByFrame(_frameIndex);
					_texture = _textureRef.getRealTexture(_frameIndex);
					_textureDirty = false;
					_frameDirty = false;
				}
				else
				{
					_textureDirty = false;
				}
				_validate = _coordVector && _texture;
				_vDirty = _vDirty || _globalDirty;
			}
		}

//		_coordVector	Vector.<Number>([]);//left, top, right, bottom, offsetX, offsetY, width, height
		override public function validateProperty():void
		{
			checkStatus();
			if(_colorDirty)
			{
				var red : uint = _color >> 16;
				var green : uint = (_color & 0x00FF00) >> 8;
				var blue : uint = (_color & 0x0000FF) ;
				
				//Debug.bltrace(red.toString(16) + " : " + green.toString(16) + " : " + blue.toString(16));
				_colorData[0] = red / 0xFF;
				_colorData[1] = green / 0xFF;
				_colorData[2] = blue /0xFF;
				_colorDirty = false;
			}
			
			if(_alphaDirty)
			{
				_colorData[3] = _alpha;
				_alphaDirty = false;
			}
			
			if(_validate == false) 
				return;
			
			var left : Number = 0;
			var top : Number = 0;
			var right : Number = 0;
			var bottom : Number = 0;
			
			if(_vDirty)
			{
				if(useFloatPos)
				{
					left   = _globalX + _coordVector[4];
					top    = _globalY + _coordVector[5];
					
					right  =  left + _coordVector[6] * _scaleInfo.x;
					bottom =  top  + _coordVector[7] * _scaleInfo.y;
				}
				else
				{
					left   = Math.round(_globalX + _coordVector[4]);
					top    = Math.round(_globalY + _coordVector[5]);
					
					right  = Math.round(left + _coordVector[6] * _scaleInfo.x);
					bottom = Math.round(top  + _coordVector[7] * _scaleInfo.y);
				}
				
				_boundsInfo[0]  = left;
				_boundsInfo[1]  = top;
				
				_boundsInfo[4]  = right;
				_boundsInfo[5]  = top;

				_boundsInfo[8]  = left;
				_boundsInfo[9]  = bottom;
				
				_boundsInfo[12]  = right;
				_boundsInfo[13] = bottom;
				
				_vDirty = false;
			}
			
			if(_uDirty)
			{
				_boundsInfo[2]  = _coordVector[0];
				_boundsInfo[3]  = _coordVector[1];
				
				_boundsInfo[6]  = _coordVector[2];
				_boundsInfo[7]  = _coordVector[1];
				
				_boundsInfo[10]  = _coordVector[0];
				_boundsInfo[11]  = _coordVector[3];
				
				_boundsInfo[14]  = _coordVector[2];
				_boundsInfo[15] = _coordVector[3];
				_uDirty = false;
			}
		}
		
		override public function collectRenderer():void
		{
			if(_validate && visible)
			{
				slGlobal.Helper.addItemToRender(this);
			}
			
		}
		public function get colorData():Vector.<Number>
		{
			return _colorData;
		}
		
		public function get drawEnable():Boolean
		{
			return _validate && visible;
		}
		
		public function get boundsInfo():Vector.<Number>
		{
			return _boundsInfo;
		}
		
		public function get cacheTexture():Texture
		{
			return _texture;
		}
		
		override internal function get insideViewPort():Boolean
		{
			_globalRect.setTo(_globalX, _globalY, width, height);
			return _globalRect.intersects(slGlobal.ViewPort);
		}
		
		
		
		
		
	}
}

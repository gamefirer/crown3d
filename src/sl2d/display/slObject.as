package sl2d.display
{
	
	import away3d.debug.Debug;
	
	import flash.geom.Rectangle;
	
	import sl2d.shader.slProgram;
	import sl2d.shader.slShader;

	public class slObject extends slRect
	{
		private var _parentX:Number = 0;
		private var _parentY:Number = 0;
		protected var _globalX : Number = 0;
		protected var _globalY : Number = 0;
		protected var _color:Number = 0xFFFFFF;
		protected var _globalDirty:Boolean = true;
		protected var _shader:slProgram = slShader.Alpha;
		protected var _scaleInfo:slPoint = new slPoint(1, 1);
		protected var _globalRect:Rectangle = new Rectangle();
		protected var _alpha:Number = 1;
//		public var vDepth:int;
//		public var hDepth:int;
		public var parent:slGroup;
		public var visible:Boolean = true;
		
		public function setGlobalOffset(X : Number, Y : Number) : void {
			_parentX = X;
			_parentY = Y;
		}
		public function set color(value:Number):void{
			_color = value;
		}
		public function get color():Number{
			return _color;
		}
		public function setScale(scaleX:Number = 1, scaleY:Number = 1):void{
			_scaleInfo.setPosition(scaleX, scaleY);
		}
		
		public function get groupWidth():int{
			return width;
		}
		
		public function get groupHeight():int{
			return height;
		}
		protected function setOffset():void{
			var oldX:Number = _globalX;
			var oldY:Number = _globalY;
			_globalX = _parentX + _x;
			_globalY = _parentY + _y;
			_globalDirty = (oldX != _globalX) || (oldY != _globalY);
		}
		public function slObject()
		{
		}
		public function update():void{
//			vDepth = parent ? (parent.vDepth + 1) : 0;
			setOffset();
		}
		public function collectRenderer():void{
		
		}
		
		public function validateProperty():void{
			
		}
		//context update 之后，将_textureDirty的数据强制改成true
		public function onContextChanged():void{
			setTextureDirty();
		}
		
		internal function setTextureDirty():void{
			
		}
		public function set alpha(value:Number):void{
			_alpha = value;
		}
		public function get alpha():Number{
			return _alpha;
		}
		
		override public function get width():Number{
			return _width * _scaleInfo.x;
		}
		override public function get height():Number{
			return _height * _scaleInfo.y;
		}
		
		public function dispose():void{
			_x = 0;
			_y = 0;
			_color = 0xFFFFFF;
			_scaleInfo.setPosition(1, 1);
			_shader = slShader.Alpha;
			_alpha = 1;
		}
		
		//是否离开视窗体。。
		//离开的情况下，则不绘制。
		internal function get insideViewPort():Boolean{
			return true;
		}
		
		
		
	}
}
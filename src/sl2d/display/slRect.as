package sl2d.display
{
	public class slRect extends slPoint
	{
		protected var _width:Number;
		protected var _height:Number;
		public function slRect(X:Number=0, Y:Number=0, Width:Number=0, Height:Number=0)
		{
			super(X,Y);
			_width = Width;
			_height = Height;
		}
		public function get left():Number
		{
			return _x;
		}
		
		public function get right():Number
		{
			return _x + width;
		}
		public function get top():Number
		{
			return _y;
		}
		
		public function get bottom():Number
		{
			return _y + height;
		}
		public function set width(value:Number):void{
			if(value < 0)
				value = 0;
			_width = value;
		}
		public function get width():Number{
			return _width;
		}
		public function set height(value:Number):void{
			if(value < 0)
				value = 0;
			_height = value;
		}
		public function get height():Number{
			return _height;
		}
		public function setSize(w : uint, h : uint) : void {
			_width = w;
			_height = h;
		}
	}
}
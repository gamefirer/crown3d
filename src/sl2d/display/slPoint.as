package sl2d.display
{
	//point
	public class slPoint implements IPoint
	{
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		public function get x():Number{ return _x; }
		public function get y():Number{ return _y; }
		public function set x(value:Number):void
		{
			_x = value;
		}
		
		public function set y(value:Number):void
		{
			_y = value;
		}
		public function slPoint(X:Number = 0, Y:Number = 0)
		{
			_x = X;
			_y = Y;
		}
		
		public function setPosition(X:Number, Y:Number):void{
			_x = X;
			_y = Y;
		}
	}
}
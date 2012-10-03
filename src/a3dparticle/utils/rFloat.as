package a3dparticle.utils
{
	public class rFloat
	{
		public var min : Number;
		public var max : Number;
		
		public function get rand():Number
		{
			return (max-min)*Math.random() + min;
		}
		
		public function rFloat(x:Number):void
		{
			min = max = x;
		}
				
	}
}
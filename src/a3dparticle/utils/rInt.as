package a3dparticle.utils
{
	public class rInt
	{
		public var min : int;
		public var max : int;
		
		public function get rand():int
		{
			return (max-min)*Math.random() + min;
		}
		
		public function rInt(x:int=0)
		{
			min = max = x;
		}
	}
}
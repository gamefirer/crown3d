/**
 *	颜色动画的关键帧 
 */
package away3d.animators.data
{
	public class ColorAnimationFrame
	{
		public var A : int;
		public var R : int;
		public var G : int;
		public var B : int;
		
		public function ColorAnimationFrame(a:int=0xff, r:int=0xff, g:int=0xff, b:int=0xff)
		{
			A=a;
			R=r;
			G=g;
			B=b;
		}
	}
}
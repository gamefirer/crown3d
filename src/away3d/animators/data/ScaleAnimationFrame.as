/**
 *	Scale动画的关键帧数据 
 */
package away3d.animators.data
{
	public class ScaleAnimationFrame
	{
		public var scaleX : Number;
		public var scaleY : Number;
		public var scaleZ : Number;
		
		public function ScaleAnimationFrame(scaleX:Number=1, scaleY:Number=1, scaleZ:Number=1)
		{
			this.scaleX = scaleX;
			this.scaleY = scaleY;
			this.scaleZ = scaleZ;
		}
	}
}
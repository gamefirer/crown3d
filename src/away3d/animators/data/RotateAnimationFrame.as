/**
 *	旋转动画的关键帧数据 
 */
package away3d.animators.data
{
	public class RotateAnimationFrame
	{
		
		public var rotX : Number;
		public var rotY : Number;
		public var rotZ : Number;
		
		
		public function RotateAnimationFrame(rotX:Number=0, rotY:Number=0, rotZ:Number=0)
		{
			this.rotX = rotX;
			this.rotY = rotY;
			this.rotZ = rotZ;
		}
	}
}
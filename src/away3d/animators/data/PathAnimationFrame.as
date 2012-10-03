/**
 *	路径动画的关键帧数据 
 */
package away3d.animators.data
{
	import flash.geom.Vector3D;
	
	public class PathAnimationFrame
	{
		public var durtime : uint;		// 毫秒
		public var pos : Vector3D = new Vector3D;
		
		public function PathAnimationFrame()
		{
		}
	}
}
/**
 *	碰撞数据 
 */
package blade3d.scene.loadvo
{
	import org.poly2tri.Point;

	public class CollideVO
	{
		public var worldPoints : Vector.<Point> = new Vector.<Point>;			// 世界范围
		public var wallPointsList : Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>;		// 所有阻挡范围
		public var holePointsList : Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>;		// 所有洞的范围
	}
}
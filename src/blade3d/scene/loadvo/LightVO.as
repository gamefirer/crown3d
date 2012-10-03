/**
 *	投影灯数据 
 */
package blade3d.scene.loadvo
{
	public class LightVO
	{
		public var lightName : String;
		public var lightPosx : Number;			// 位置
		public var lightPosz : Number;
		public var lightSize : Number;			// 大小
		public var lightRot : Number;			// 旋转
		
		public var lightR : Number;			// 颜色
		public var lightG : Number;
		public var lightB : Number;
		
		public var lightIntensity : Number;		// 光照强度
		
		public var texName : String;			// 贴图名
	}
}
/**
 *	投影灯数据 
 */
package blade3d.scene.loadvo
{
	public class LightVO
	{
		public var lightName : String;
		public var lightPosx : Number = 0;			// 位置
		public var lightPosz : Number = 0;
		public var lightSize : Number = 100;			// 大小
		public var lightRot : Number = 0;			// 旋转
		
		public var lightR : Number = 1;			// 颜色
		public var lightG : Number = 1;
		public var lightB : Number = 1;
		
		public var lightIntensity : Number = 1;		// 光照强度
		
		public var texName : String;			// 贴图名
	}
}
package sl2d
{
	import flash.geom.Rectangle;
	
	import sl2d.display.slCamera;
	import sl2d.display.slWindow;
	import sl2d.renderer.slAGALHelper;
	import sl2d.texture.slTextureFactory;
	
	

	public class slGlobal
	{
		
		public static var isInit:Boolean = false;
		public static var CurTime:int;
		public static var DeltaTime:int;
		public static var ViewPortWidth:Number = 800;			// viewport大小
		public static var ViewPortHeight:Number = 600;
		public static var World:slWorld;
		//系统一共更新的次数。
		public static var WorldUpdateCount:int;
		public static var Camera:slCamera;
		public static var View:slWindow;					// 根节点
		public static var Helper:slAGALHelper;
		//场景舞台的像素起始点位置
		public static var TextureFactory:slTextureFactory;
		public static const ViewPort:Rectangle = new Rectangle();
		public static const TextFontFamily:String = "微软雅黑";
		public function slGlobal()
		{
		}
	}
}
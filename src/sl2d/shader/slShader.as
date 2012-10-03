package sl2d.shader
{
	import flash.display3D.Context3D;
	
	import sl2d.shader.*;

	public class slShader
	{
		// 4种渲染方式
		public static const Alpha:slAlphaShader = new slAlphaShader();
		public static const Lighter:slLighterShader = new slLighterShader();
		public static const Gray:slGrayShader = new slGrayShader();
		public static const Ball:slBallShader = new slBallShader();
		
		public function slShader()
		{
			
		}
		public static function setContext(context:Context3D):void
		{
			Alpha.updateContext(context);
			Lighter.updateContext(context);
			Gray.updateContext(context);
			Ball.updateContext(context);
		}
		

	}
}
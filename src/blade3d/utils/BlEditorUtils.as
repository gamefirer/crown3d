package blade3d.utils
{
	import flash.utils.Dictionary;

	public class BlEditorUtils
	{
		// 编辑器必要资源
		static public var box_mesh : String = "base/box.3ds";
		static public var texLight_bmp : String = "base/helper_texlight.png";
		static public var effect_bmp : String = "base/helper_effect.png";
		
		static public var editMustRes : Vector.<String> = new <String>[texLight_bmp,
																		effect_bmp,
																		box_mesh];
		
		public function BlEditorUtils()
		{
		}
	}
}
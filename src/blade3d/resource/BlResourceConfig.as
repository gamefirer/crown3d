package blade3d.resource
{
	public class BlResourceConfig
	{
		// 资源扩展名
		public static const FILE_TYPE_TEXTURE : String = ".dds";
		public static const FILE_TYPE_AVATAR_MESH    	: String = ".blm";		// avatar模型文件
		public static const FILE_TYPE_AVATAR_TAG		: String = ".blt";		// avatar骨骼绑定点文件
		public static const FILE_TYPE_AVATAR   		: String = ".bla";		// avatar骨骼文件
		public static const FILE_TYPE_AVATAR_SEQ		: String = ".blq";		// avatar的动画文件
		
		// 资源路径
		static public var scene_dir:String = "scene/";
		static public var avatar_dir:String = "character/";
		
		static public var root_url:String = "../res/";
		static public var scene_url:String;					// 场景目录
		static public var avatar_url:String;				// 角色目录
	}
}
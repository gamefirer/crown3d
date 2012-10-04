/**
 *	字符串工具 
 */
package blade3d.utils
{
	public class BlStringUtils
	{
		static public var modelExtName : String = ".3ds";
		static public var texExtName : String = ".dds";
		static public var vertexColorExtName : String = ".3dc";
		
		// 取文件名
		static public function extractFileName(url:String):String
		{
			return url.substr(url.lastIndexOf('/')+1);
		}
		// 去掉扩展名
		static public function extractFileNameNoExt(url:String):String
		{
			return url.substr(0, url.lastIndexOf('.'));
		}
		
		// 取目录名
		static public function extractPath(url:String):String
		{
			return url.substr(0, url.lastIndexOf('/')+1);
		}
		
		
		
	}
	
}
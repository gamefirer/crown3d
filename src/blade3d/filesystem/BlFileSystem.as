package blade3d.filesystem
{
	import away3d.errors.AbstractMethodError;
	
	import blade3d.resource.BlResource;

	public class BlFileSystem
	{
		public function BlFileSystem()
		{
		}
		
		public function saveFile(res:BlResource, url:String):void
		{
			throw new AbstractMethodError();
		}
	}
}
package blade3d.filesystem
{
	import blade3d.resource.BlResource;
	
	import flash.net.FileReference;

	public class BlFlashFileSystem extends BlFileSystem
	{
		public function BlFlashFileSystem()
		{
			super();
		}
		
		override public function saveFile(res:BlResource, url:String):void
		{
			var pPos:int = url.lastIndexOf('/');
			var fileName : String = url.substr(pPos+1);
			
			var saveFile:FileReference = new FileReference();
			saveFile.save(res.res, fileName);
		}
	}
}
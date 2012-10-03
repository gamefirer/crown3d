/**
 *	图片加载器 
 */
package blade3d.loader
{
	import blade3d.loader.BlDDSParser;
	import blade3d.profiler.Profiler;
	import blade3d.resource.BlResourceManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;

	public class BlImageLoader extends BlResourceLoader
	{
		private var _loader : Loader;
		
		private var _bmpData : BitmapData;
		
		public function BlImageLoader(manager:BlResourceLoaderManager)
		{
			super(manager);
			dataFormat = URLLoaderDataFormat.BINARY;
		}
		
		override public function get resType():int {return BlResourceManager.TYPE_IMAGE;}
		
		override protected function callBack(error:int):void
		{
			if(error != 0)
			{
				// callback
				for(var ei:int = 0; ei < _callBacks.length; ei++)
				{
					_callBacks[ei](null);
				}
				
				reset();
				return;
			}
			
			var ba:ByteArray = data as ByteArray;
			
			if(url.substr(url.length-4) == ".dds")
			{
				Profiler.start("uncompressDDS");
				var ddsByteArray : ByteArray = BlDDSParser.getInstance().uncompressDDS(url, ba);
				Profiler.end("uncompressDDS");
				if(ddsByteArray)
				{
					var ddsWidth : int = BlDDSParser.getInstance().width;
					var ddsHeight : int = BlDDSParser.getInstance().height;
					
					_bmpData = new BitmapData(ddsWidth, ddsHeight, true, 0);
					_bmpData.setPixels(new Rectangle(0, 0, ddsWidth, ddsHeight), ddsByteArray);
					
					// callback
					for(var i:int = 0; i < _callBacks.length; i++)
					{
						_callBacks[i](_bmpData);
					}
					
					reset();
				}
			}
			else
			{
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBitmapReady);
				
				_loader.loadBytes(ba);
			}
			
			
		}
		
		private function onBitmapReady(evt : Event) : void 
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBitmapReady);
			var bm:Bitmap = Bitmap(_loader.content);
//			
			_bmpData = bm.bitmapData;

			// callback
			for(var i:int = 0; i < _callBacks.length; i++)
			{
				_callBacks[i](_bmpData);
			}
			
			reset();
		}
	}
}
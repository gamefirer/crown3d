/**
 *	静态模型资源 
 */
package blade3d.resource
{
	import away3d.core.base.Geometry;
	import away3d.debug.Debug;
	
	import blade3d.utils.BlStringUtils;
	
	import flash.utils.ByteArray;

	public class BlModelResource extends BlResource
	{
		override public function get resType() : int {return BlResourceManager.TYPE_MESH;}
		
		private var _geo : Geometry;		// 仅用来保存内存数据
		private var _tex_urls : Vector.<String> = new Vector.<String>;
		private var _first_tex_url : String;
		
		private var _load_count : int = 0;
		
		public function get geo() : Geometry {return _geo.clone();}
		override public function get res() : * {return _geo.clone();}
		public function get tex_path() : String {return _first_tex_url;}
		public function get tex_urls() : Vector.<String> {return _tex_urls;}
		
		public function BlModelResource(url:String)
		{
			super(url);
		}
		
		override protected function _loadImp():void
		{
			BlResourceManager.instance().loaderManager.loadResource(_url, resType, onModelData);
		}
		
		private function onModelData(geo:Geometry, texUrls:Vector.<String>):void
		{
			_geo = geo;
			
			_load_count++;
			// 自动加载对应的贴图
			if(texUrls)
			{
				var i:int;
				// url 处理，添加模型目录名
				for(i=0; i<texUrls.length; i++)
				{
					texUrls[i] = texUrls[i].substring(0, texUrls[i].lastIndexOf("."));
					texUrls[i] = texUrls[i] + BlStringUtils.texExtName;
					texUrls[i] = url.substring(0, url.lastIndexOf("/")+1) + texUrls[i];
				}
				// 第一张贴图
				if(!_first_tex_url && texUrls.length > 0)
					_first_tex_url = texUrls[0];
				// 加载贴图
				for(i=0;  i<texUrls.length; i++)
				{
					_tex_urls.push(texUrls[i]);
					var texResource : BlImageResource = BlResourceManager.instance().findImageResource(texUrls[i]);
					if(texResource)
					{
						_load_count++;
						texResource.asycLoad(onImageData);
					}
					else
						Debug.log("texture "+texUrls[i]+" not exist");
				}
			}
			
			onImageData(null);
		}
		
		private function onImageData(imageRes:BlResource):void
		{
			_load_count--;
			if(_load_count == 0)
				_loadEnd(_geo != null);
		}
	}
}
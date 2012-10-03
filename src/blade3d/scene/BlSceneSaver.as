/**
 *	场景保存器 
 */
package blade3d.scene
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Entity;
	import away3d.entities.Sprite3D;
	
	import blade3d.utils.BlStringUtils;
	
	import flash.net.FileReference;

	public class BlSceneSaver
	{
		private var _scene : BlScene;
		private var _xml : XML;
		
		
		public function BlSceneSaver(scene:BlScene)
		{
			_scene = scene;
		}
		
		public function processOldXml(xml:XML):void
		{
			_xml = new XML(xml);
			// 删除贴图灯
			delete _xml.light;
			
			// 遍历场景保存
			
			recurSave(_scene.sceneNode);
			
		}
		
		private function recurSave(parent:ObjectContainer3D):void
		{
			var addxml:XML;
			if(parent is Sprite3D)
			{
				if(	Sprite3D(parent).renderLayer == Entity.SceneLight_Layer )
				{	// 贴图灯
					var texLight : Sprite3D = Sprite3D(parent);
					addxml = <light/>;
					addxml.@name = texLight.name;
					if(texLight.material.bitmapDataUrl)
						addxml.@tex = BlStringUtils.extractFileName(texLight.material.bitmapDataUrl);
					addxml.@size = texLight.width;
					addxml.@bright = texLight.intensity;
					addxml.@x = texLight.x.toFixed(2);
					addxml.@z = texLight.z.toFixed(2);
					addxml.@rot = int(texLight.rot * 180 / Math.PI);
					addxml.@r = int(texLight.color.x * 255);
					addxml.@g = int(texLight.color.y * 255);
					addxml.@b = int(texLight.color.z * 255);
					_xml.appendChild(addxml);
				}
			}
			
			// 递归
			for(var i:int=0; i<parent.numChildren; i++)
			{
				recurSave(parent.getChildAt(i));
			}
		}
		
		public function saveToFile():void
		{
			var saveFileName : String = "map.xml";
			
			var saveFile:FileReference = new FileReference();
			saveFile.save(_xml, saveFileName);
		}
		
		
	}
}
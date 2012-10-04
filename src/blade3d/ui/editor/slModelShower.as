/**
 *	模型浏览器 
 */
package blade3d.ui.editor
{
	import away3d.core.managers.Context3DProxy;
	
	import blade3d.editor.BlEditorManager;
	import blade3d.viewer.BlViewer;
	import blade3d.viewer.BlViewerManager;
	
	import flash.display3D.textures.Texture;
	
	import sl2d.display.slImage;
	import sl2d.display.slWindow;
	import sl2d.texture.slContext3DTexture;
	
	public class slModelShower extends slWindow
	{
		private var _3dTexture : slContext3DTexture;
		private var _image : slImage;
		
		public function slModelShower()
		{
			super();
			
			_3dTexture = new slContext3DTexture();
			_image = new slImage(_3dTexture);
			addChild(_image);
		}
		
		override protected function preUpdate():void
		{
			_image.setPosition(100, 100);
			
			var minSize : uint = Math.max(0, Math.min( (parent.width - 200), (parent.height - 200) ) );
			_image.setSize(  minSize, minSize );
			
			var viewer : BlViewer = BlEditorManager.instance()._resourceEditor.modelViewer;
			if(viewer.visible )
			{
				_3dTexture.renderTexture = Texture(viewer.renderTexture.getTextureForStage3D(Context3DProxy.stage3DProxy));
				_image.offsetFrame(1);
			}
			else
			{
				_3dTexture.renderTexture = null;
				_image.offsetFrame(1);
			}
			
		}
	}
}
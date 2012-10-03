package away3d.textures
{
	import away3d.arcane;
	import away3d.core.managers.Context3DProxy;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;

	use namespace arcane;

	public class Texture2DBase extends TextureProxyBase
	{
		public function Texture2DBase()
		{
			super();
		}

		override protected function createTexture(context : Context3D) : TextureBase
		{
			return Context3DProxy.createTexture(_width, _height, Context3DTextureFormat.BGRA, false);
		}
	}
}

/**
 *	用来直接显示context3d中的texture的slTexture对象 
 */
package sl2d.texture
{
	import away3d.core.managers.Context3DProxy;
	import away3d.textures.RenderTexture;
	
	import flash.display3D.textures.Texture;
	
	public class slContext3DTexture extends slTexture
	{
		private var _renderTarget : Texture;
		private var _constUvInfo:Vector.<Number>;
		
		public function slContext3DTexture(gcEnable:Boolean=true)
		{
			super(gcEnable);
//			setUV(0, Vector.<Number>([0, 0, bmd.width / width, bmd.height / height, offsetX, offsetY, bmd.width, bmd.height]));
			_constUvInfo = new <Number>[0,0,1,1,0,0,256,256];
		}
		
		public function set renderTexture(rtt : Texture) : void
		{
			_renderTarget = rtt;
			_validate = true;
		}
		
		override public function getRealTexture(frame:uint):Texture
		{
			return _renderTarget;
		}
		
		override public function getUVByFrame(frame:uint):Vector.<Number>{
			return _constUvInfo;
		}
	}
}
/**
 *	显示Rendertarget的ui 
 */
package blade3d.ui.editor
{
	import away3d.core.managers.Context3DProxy;
	import away3d.core.render.DefaultRenderer;
	
	import blade3d.BlEngine;
	import blade3d.postprocess.BlPostProcessManager;
	import blade3d.scene.BlSceneManager;
	import blade3d.viewer.BlViewerManager;
	
	import flash.display3D.textures.Texture;
	
	import sl2d.display.slGroup;
	import sl2d.display.slImage;
	import sl2d.display.slPoint;
	import sl2d.display.slWindow;
	import sl2d.texture.slContext3DTexture;

	public class slRttShower extends slWindow
	{
		
		private var _rtts : Vector.<slContext3DTexture>;
		private var _rttImages : Vector.<slImage>;
		private var _rttSelectIndex : Vector.<int>;
		
		static public var imageCount : int = 4;
		
		
		
		private var _startPos : slPoint = new slPoint(100, 5);
		private var _size : slPoint = new slPoint(300, 300);
		private var _gap : slPoint = new slPoint(2, 2);
		
		public function slRttShower()
		{
			super();
			
			_rtts = new Vector.<slContext3DTexture>;
			_rttImages = new Vector.<slImage>;
			_rttSelectIndex = new Vector.<int>;
			
			var vi : int;
			var hi : int;
			
			for(var i:int=0; i<imageCount; i++)
			{
				vi = i / 2;
				hi = i % 2;
				
				var rtt:slContext3DTexture = new slContext3DTexture();
				var rttImage:slImage = new slImage(rtt);
				addChild(rttImage);
				
				rttImage.setPosition(_startPos.x + hi*(_size.x + _gap.x), _startPos.y + vi*(_size.y + _gap.y));
				rttImage.setSize(_size.x, _size.y);
				rttImage.gotoFrame(0);
				
				_rtts.push(rtt);
				_rttImages.push(rttImage);
				
				_rttSelectIndex.push(i);
			}
			
			showRtt(false);
		}
		
		override protected function preUpdate():void
		{
			for(var i:int=0; i<imageCount; i++)
			{
				switch(_rttSelectIndex[i])
				{
					case 0:		// 深度图
						_rtts[i].renderTexture = BlEngine.mainView.depthRTT;
						break;
					case 1:		// 色彩图
						// 默认渲染图
						if(BlEngine.mainView.filter3DRender)
							_rtts[i].renderTexture = BlEngine.mainView.filter3DRender.getMainInputTexture(Context3DProxy.stage3DProxy);
						else
							_rtts[i].renderTexture = null;
						break;
					case 2:		// 阴影图
						_rtts[i].renderTexture = Texture(BlSceneManager.instance().whiteLight.shadowMapper.depthMap.getTextureForStage3D(Context3DProxy.stage3DProxy));
						break;
					case 3:		// 贴图灯
						_rtts[i].renderTexture = Texture(BlSceneManager.instance().texLight.lightMapper.lightMap.getTextureForStage3D(Context3DProxy.stage3DProxy));
						break;
				}
				
			}
		}
		
		public function showRtt(v:Boolean):void
		{
			for(var i:int=0; i<imageCount; i++)
			{
				_rttImages[i].visible = v;
			}
		}
		
		public function setRtt(i:int, w:int):void
		{
			if(i<0 || i>=imageCount) return;
			_rttSelectIndex[i] = w;
			_rttImages[i].offsetFrame(1);
		}
	}
}
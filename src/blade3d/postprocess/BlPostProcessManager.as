/**
 *	后期特效，管理器 
 */
package blade3d.postprocess
{
	import away3d.containers.View3D;
	import away3d.core.managers.Context3DProxy;
	import away3d.debug.Debug;
	import away3d.filters.BloomFilter3D;
	import away3d.filters.BlurFilter3D;
	import away3d.filters.DepthOfFieldFilter3D;
	import away3d.filters.Filter3DBase;
	import away3d.filters.HBlurFilter3D;
	import away3d.filters.HDepthOfFieldFilter3D;
	import away3d.filters.HueSaturationFilter3D;
	import away3d.filters.MotionBlurFilter3D;
	import away3d.filters.RadialBlurFilter3D;
	
	import blade3d.BlManager;
	
	import flash.display3D.textures.Texture;
	
	public class BlPostProcessManager extends BlManager
	{
		static private var _instance : BlPostProcessManager;
		
		private var _view3D : View3D;
		
		public function BlPostProcessManager()
		{
			if(_instance)
				Debug.error("BlPostProcessManager error");
		}
		
		static public function instance() : BlPostProcessManager
		{
			if(!_instance)
				_instance = new BlPostProcessManager;
			return _instance;
		}
		
		private var filter : Filter3DBase;
//		public function testTexture() : Texture
//		{
//			return filter.getMainInputTexture(Context3DProxy.stage3DProxy);
//		}
		
		public function init(view:View3D, callBack:Function):Boolean
		{
			_initCallBack = callBack;
			_view3D = view;
			
			var filterArr : Array = new Array;
//			filter = new BlurFilter3D;
//			filter = new DepthOfFieldFilter3D;
//			filter = new MotionBlurFilter3D();
//			filter = new HDepthOfFieldFilter3D(1, 1);
//			filterArr.push(filter);
//			
			filter = new BloomFilter3D();
			filterArr.push(filter);
			
//			filterArr.push(new DepthOfFieldFilter3D);
//			_view3D.filters3d = filterArr;
			
			
			_initCallBack(this);
			return true;
		}
		
	}
}
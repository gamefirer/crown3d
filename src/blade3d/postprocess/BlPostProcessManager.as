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
	import flash.utils.Dictionary;
	
	public class BlPostProcessManager extends BlManager
	{
		static private var _instance : BlPostProcessManager;
		
		private var _view3D : View3D;
		
		private var _posterBitMask : uint = 0;				// 后期特效位标识
		private var _posterMap : Dictionary;				// 后期特效表
		private var filterArr : Array;						// filter列表

		public function get posterMap() : Dictionary {return _posterMap;}
		
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
			
			_posterMap = new Dictionary;
			filterArr = new Array;
			
//			var filterArr : Array = new Array;
//			filter = new BlurFilter3D;
//			filter = new DepthOfFieldFilter3D;
//			filter = new MotionBlurFilter3D();
//			filter = new HDepthOfFieldFilter3D(1, 1);
//			filterArr.push(filter);
//			
//			filter = new BloomFilter3D();
//			filterArr.push(filter);
			
//			filterArr.push(new DepthOfFieldFilter3D);
//			_view3D.filters3d = filterArr;
			
			
			_initCallBack(this);
			return true;
		}
		
		public function getPoster(type:uint):BlPoster {return posterMap[type];}
		
		public function addPoster(type:uint):BlPoster
		{
			if(_posterBitMask & type)
			{
				return _posterMap[type];			// 已经有该后期效果了
			}
			
			var newPoster : BlPoster;
			
			switch(type)
			{
				case BlPoster.POSTER_BLUR:
				{
					newPoster = new BlBlurPoster;
					break;
				}
				case BlPoster.POSTER_SATURATION:
				{
					newPoster = new BlSaturationPoster;
					break;
				}
			}
			
			// 添加filter
			if(newPoster)
			{
				_posterBitMask = _posterBitMask | type;
				
				filterArr.push(newPoster.filter);
				_view3D.filters3d = filterArr;
				
				_posterMap[type] = newPoster;
				newPoster.onAdd();				
			}
			
			return newPoster;
		}
		
		public function removePoster(type:uint):void
		{
			if( (_posterBitMask & type) == 0 )
				return;			// 无此Poster
			
			_posterBitMask = _posterBitMask & ~type;
			
			var removePoster : BlPoster = _posterMap[type];
			removePoster.onRemove();
			
			// 移除该poster
			_posterMap[type] = null;
			filterArr.splice( filterArr.indexOf(removePoster), 1 );
			
			_view3D.filters3d = filterArr;
		}
		
		
	}
}
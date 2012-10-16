/**
 *	后期特效基类 
 */
package blade3d.postprocess
{
	import away3d.errors.AbstractMethodError;
	import away3d.filters.Filter3DBase;

	public class BlPoster
	{
		// 后期特效种类
		static public var POSTER_BLUR : uint = 0x1;			// 全屏幕模糊
		static public var POSTER_SATURATION : uint = 0x2;		// 色调
		
		protected var _filter : Filter3DBase;
		
		
		public function get type() : uint {throw new AbstractMethodError();}
		public function get filter() : Filter3DBase {return _filter;}
		
		public function BlPoster()
		{
		}
		
		public function onAdd():void
		{
			
		}
		
		public function onRemove():void
		{
			
		}
	}
}
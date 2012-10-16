/**
 *	模糊效果 
 */
package blade3d.postprocess
{
	import away3d.filters.BlurFilter3D;

	public class BlBlurPoster extends BlPoster
	{
		
		override public function get type() : uint {return POSTER_BLUR;}
		
		public function BlBlurPoster()
		{
			super();
			
			_filter = new BlurFilter3D;
		}
		
		override public function onAdd():void
		{
			
		}
		
		override public function onRemove():void
		{
			
		}
	}
}
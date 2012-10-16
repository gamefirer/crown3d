/**
 *	色调效果 
 */
package blade3d.postprocess
{
	import away3d.filters.HueSaturationFilter3D;

	public class BlSaturationPoster extends BlPoster
	{
		override public function get type() : uint {return POSTER_SATURATION;}
		
		public function BlSaturationPoster()
		{
			super();
			
			_filter = new HueSaturationFilter3D;
		}
		
		override public function onAdd():void
		{
			
		}
		
		override public function onRemove():void
		{
			
		}
	}
}
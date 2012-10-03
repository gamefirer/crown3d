/**
 *	矩形发射器 
 */
package a3dparticle.emitter
{
	import a3dparticle.particle.ParticleParam;
	
	import flash.geom.Vector3D;

	public class RectangleEmitter extends EmitterBase
	{
		public var wide_x : Number = 100;
		public var wide_y : Number = 100;
		public var wide_z : Number = 100;
		
		public function RectangleEmitter()
		{
			super();
		}
		
		override protected function initPosition(param:ParticleParam):void
		{
			var half_x : Number = wide_x / 2;
			var half_y : Number = wide_y / 2;
			var half_z : Number = wide_z / 2;
			
			param["OffsetPositionLocal"] = new Vector3D( wide_x * Math.random() - half_x,
				wide_y * Math.random() - half_y,
				wide_z * Math.random() - half_z);
		}
	}
}
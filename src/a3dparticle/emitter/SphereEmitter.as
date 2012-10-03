/**
 *	球形发射器 
 */
package a3dparticle.emitter
{
	import a3dparticle.particle.ParticleParam;
	
	import flash.geom.Vector3D;

	public class SphereEmitter extends EmitterBase
	{
		public var minR : Number = 0;
		public var maxR : Number = 100;
		
		public function SphereEmitter()
		{
			super();
		}
		
		override protected function initPosition(param:ParticleParam):void
		{
			var degree1:Number = int(Math.random()*12)/12 * Math.PI * 2;
			var degree2:Number = int(Math.random()*12)/12 * Math.PI * 2;
			
			
			var r:Number = Math.random() * (maxR - minR) + minR;
			
			param["OffsetPositionLocal"] = new Vector3D(r * Math.sin(degree1) * Math.cos(degree2), r * Math.cos(degree1) * Math.cos(degree2), r * Math.sin(degree2));
		}
	}
}
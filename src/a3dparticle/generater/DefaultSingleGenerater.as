/**
 *	默认的粒子生成器 
 */
package a3dparticle.generater
{
	import a3dparticle.particle.ParticleBitmapMaterial;
	import a3dparticle.particle.ParticleSample;
	
	import away3d.materials.utils.DefaultMaterialManager;
	import away3d.primitives.PlaneGeometry;
	
	public class DefaultSingleGenerater extends SingleGenerater
	{
		public function DefaultSingleGenerater(count:uint)
		{
			// 创建默认的粒子采用器
			var defaultSampler : ParticleSample;
			if(!defaultSampler)
			{
				var material:ParticleBitmapMaterial = new ParticleBitmapMaterial( DefaultMaterialManager.getDefaultBitmapData() );
				var plane:PlaneGeometry = new PlaneGeometry( 20, 20, 1, 1, false);
				defaultSampler = new ParticleSample(plane.subGeometries[0], material);
			}
			
			super(defaultSampler, count);
		}
	}
}
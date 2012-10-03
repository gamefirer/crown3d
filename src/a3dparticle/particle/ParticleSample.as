package a3dparticle.particle 
{
	import away3d.core.base.SubGeometry;
	
	public class ParticleSample 
	{
		static public var SAMPLER_TYPE_DEFAULT : int = 0;		// 面片粒子
		
		public var subGem:SubGeometry;
		public var material:ParticleMaterialBase;
		
		public function ParticleSample(subGem:SubGeometry,material:ParticleMaterialBase) 
		{
			this.subGem = subGem;
			this.material = material;
		}
		
	}

}
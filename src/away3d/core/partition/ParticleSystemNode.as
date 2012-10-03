/*
 *	particle system对应的node
 */
package away3d.core.partition
{
	import away3d.core.traverse.PartitionTraverser;
	import away3d.entities.Entity;
	import away3d.particle.ParticleSystem;

	public class ParticleSystemNode extends EntityNode
	{
		public static var showParticle : Boolean = true;
		
		private var _particleSystem : ParticleSystem;
		
		
		public function ParticleSystemNode(particleSystem : ParticleSystem)
		{
			super(particleSystem);
			_particleSystem = particleSystem;	// also keep a stronger typed reference
		}
		
		override public function acceptTraverser(traverser : PartitionTraverser) : void
		{
			if( !showParticle )
				return;
			
//			Profiler.start("ParticleSystemNode::acceptTraverser");
			
			if (traverser.enterNode(this)) {
				super.acceptTraverser(traverser);
				traverser.applyParticle(_particleSystem);
			}
			traverser.leaveNode(this);
			
//			Profiler.end("ParticleSystemNode::acceptTraverser");
		}
		
	}
}
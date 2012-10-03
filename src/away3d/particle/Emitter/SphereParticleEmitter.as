package away3d.particle.Emitter
{
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	import away3d.primitives.WireframeSphere;
	
	import blade3d.BlConfiguration;
	
	public class SphereParticleEmitter extends RectangleParticleEmitter
	{
		public var radiusBig : Number = 0;		// 外径
		public var radiusSmall : Number = 0;	// 内径
		
		public function SphereParticleEmitter(particleSystem:ParticleSystem=null)
		{
			super(particleSystem);
		}
		
		override public function initParticle(newParticle:Particle) : void
		{
			super.initParticle(newParticle);
			
			// 位置
			if(_particleSystem.isWolrdParticle)
				newParticle.pos.copyFrom(_particleSystem.scenePosition);
			else
				newParticle.pos.setTo(0, 0, 0);
			
			var radius : Number = (radiusBig - radiusSmall) * Math.random() + radiusSmall;
			var angle1 : Number = Math.PI * 2 * Math.random();
			var angle2 : Number = Math.PI * Math.random() + Math.PI/2;
			
			newParticle.pos.x += radius * Math.cos(angle2) * Math.cos(angle1);
			newParticle.pos.z += radius * Math.cos(angle2) * Math.sin(angle1);
			newParticle.pos.y += radius * Math.sin(angle2);
		}
		
		override public function showEmitter():void
		{
			if(BlConfiguration.editorMode)
			{
				_emitMesh = new WireframeSphere(radiusBig, 8, 6);
			}
		}
		
	}
}
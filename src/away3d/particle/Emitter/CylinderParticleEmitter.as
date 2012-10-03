/**
 *	管状发射器 
 */
package away3d.particle.Emitter
{
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	import away3d.primitives.WireframeCylinder;
	
	import blade3d.BlConfiguration;
	
	public class CylinderParticleEmitter extends RectangleParticleEmitter
	{
		public var radiusBig : Number = 0;			// 外径
		public var radiusSmall : Number = 0;		// 内径
		public var height : Number;			// 高
		
		public function CylinderParticleEmitter(particleSystem:ParticleSystem=null)
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
			var angle : Number = Math.PI * 2 * Math.random();
			
			newParticle.pos.x += radius * Math.cos(angle);
			newParticle.pos.z += radius * Math.sin(angle);
			newParticle.pos.y += height *(2.0*Math.random()-1.0);
			
		}
		
		override public function showEmitter():void
		{
			if(BlConfiguration.editorMode)
			{
				_emitMesh = new WireframeCylinder(radiusBig, radiusBig, height);
			}
		}
		
	}
}
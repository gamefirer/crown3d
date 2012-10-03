/**
 *	粒子与地面碰撞的控制器(同时可以作为另一粒子系统的矩形发射器,暴风雪效果用)
 */
package away3d.particle.Effector
{
	import away3d.particle.Displayer.GpuDisplayer;
	import away3d.particle.Emitter.ParticleEmitterBase;
	import away3d.particle.Emitter.RectangleParticleEmitter;
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	
	import bl.managers.blSceneManager;
	import bl.scene.blScene;
	import bl.scene.blWorld;
	
	import flash.geom.Vector3D;
	
	public class TerrainEffector extends RectangleParticleEmitter implements ParticleEffectorBase
	{
		private var _triggerParticleSystem : ParticleSystem;
		private var _effectorParticleSystem : ParticleSystem;
		
		private var _createPositions : Vector.<Vector3D> = new Vector.<Vector3D>;		// 需要新生成粒子的位置列表
		
		public function TerrainEffector(particleSystem : ParticleSystem)
		{
			super(particleSystem);
		}
		
		public function setParticleSystem(value : ParticleSystem) : void 
		{
			_effectorParticleSystem = value;	
		}
		
		override public function set particleSystem(value : ParticleSystem) : void
		{
			if(_triggerParticleSystem)
			{	// 脱离当前发射器
				_triggerParticleSystem.emitter = null;
			}
			_triggerParticleSystem = value;
		}
		
		override public function get particleSystem() : ParticleSystem
		{
			return _triggerParticleSystem;
		}
		
		public function updateParticles(deltaTime : int, partilce : Particle) : void
		{
			var heightY:Number = blWorld.getInstance().scene.getTerrainHeight(partilce.pos.x, partilce.pos.z);
			if(partilce.pos.y < heightY)
			{	// 该粒子到地面下面
				partilce.Dead();
				_createPositions.push(partilce.pos.clone());
			}
			
		}
		
		override public function Update(deltaTime : int) : void
		{
			if(!_triggerParticleSystem) return;
			
			super.Update(deltaTime);
			if( !_isInEmitTime )
				return;			
			
			var pPos : Vector3D;
			while(_createPositions.length > 0)
			{
				pPos = _createPositions.pop();
				
				var newParticle : Particle = _triggerParticleSystem.GenerateParticle();
				if(newParticle)
				{	
					newParticle.reset();
					initParticle(newParticle);
					
					// 位置
					if(_triggerParticleSystem.isWolrdParticle)
						newParticle.pos.copyFrom(pPos);
					else
						newParticle.pos.setTo(0, 0, 0);
					
					newParticle.pos.x += (EmitterRectTo.x - EmitterRectFrom.x) * Math.random() + EmitterRectFrom.x;
					newParticle.pos.y += (EmitterRectTo.y - EmitterRectFrom.y) * Math.random() + EmitterRectFrom.y;
					newParticle.pos.z += (EmitterRectTo.z - EmitterRectFrom.z) * Math.random() + EmitterRectFrom.z;
					
					tellGpuDisplayer(newParticle);
				}
			}
											
		}
		
		public function initGpuDisplayer(gpuDisplayer : GpuDisplayer) : void
		{
			
		}
	}
}
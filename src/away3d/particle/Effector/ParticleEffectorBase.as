/*
 *	粒子控制器
 */
package away3d.particle.Effector
{
	import away3d.errors.AbstractMethodError;
	import away3d.particle.Displayer.GpuDisplayer;
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	
	public interface ParticleEffectorBase
	{

		function setParticleSystem(value : ParticleSystem) : void;
		
		function updateParticles(deltaTime : int, partilce : Particle) : void;
		
		function initGpuDisplayer(gpuDisplayer : GpuDisplayer) : void;
	}
}
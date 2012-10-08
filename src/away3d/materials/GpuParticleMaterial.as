/**
 *	GPU粒子的材质 
 */
package away3d.materials
{
	import away3d.materials.passes.GpuParticlePass;
	import away3d.particle.ParticleSystem;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;

	public class GpuParticleMaterial extends MaterialBase
	{
		private var _gpuParticlePass : GpuParticlePass;
		
		public function GpuParticleMaterial(bitmapData : BitmapData = null, smooth : Boolean = true, repeat : Boolean = false, mipmap : Boolean = true)
		{
			super();
			
			_gpuParticlePass = new GpuParticlePass;
			addPass(_gpuParticlePass);
			
			this.bitmapData = bitmapData;
			this.smooth = smooth;
			this.repeat = repeat;
			this.mipmap = mipmap;
			
			// 粒子材质设置
			blendMode = BlendMode.ADD;		// 加色渲染
			bothSides = true;				// 粒子要双面渲染
			depthWrite = false;				// 不写深度
		
		}
		
		public function set currentTime(time:int):void
		{
			_gpuParticlePass.currentTime = time;
		}
		
		public function get bitmapData() : BitmapData
		{
			return _gpuParticlePass.bitmapData;
		}
		
		public function set bitmapData(value : BitmapData) : void
		{
			_gpuParticlePass.bitmapData = value;
		}
		
		public function setParitlceSystem(ps : ParticleSystem) : void
		{
			_gpuParticlePass.setParitlceSystem(ps);
			if(ps)
				bothSides = ps.twoSide;
		}
		
		public function updateTexture() : void
		{
			_gpuParticlePass.updateBitmapData();
		}
		
		override public function dispose() : void
		{
			super.dispose();
		}
	}
}
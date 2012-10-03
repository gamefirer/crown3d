/*
 *	矩形范围发射器
 */
package away3d.particle.Emitter
{
	import away3d.particle.Displayer.GpuDisplayer;
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	import away3d.primitives.WireframeCube;
	import away3d.primitives.WireframePrimitiveBase;
	
	import blade3d.BlConfiguration;
	import blade3d.profiler.Profiler;
	
	import flash.geom.Vector3D;

	public class RectangleParticleEmitter extends ParticleEmitterBase
	{
		// 发射器参数
		public var emitRate : int = 5;			// 发射率,每秒发射粒子数
		
		public var lifeTime : int = 1000;		// 生命期(毫秒ms)
		public var lifeTimeRange : int = 0;	// 生命期变化
		public var color : uint = 0xffffff;	// 颜色
		public var colorRange : uint = 0x000000;	// 颜色变化值
		public var alpha : Number = 1;			// 透明度
		public var alphaRange : Number = 0;	// 透明度变化值
		public var sizeX : Number = 10;			// 大小
		public var sizeY : Number = 10;			// 大小
		public var sizeRange : Number = 0;		// 大小变化		
		public var directionFrom : Vector3D = new Vector3D(0,1,0);			// 发射方向
		public var directionTo : Vector3D = new Vector3D(0,1,0);	// 发射角度变化范围
		public var vel : int = 100;		// 运动速度(每秒)
		public var velRange : int = 0;		// 运动速度变化范围
		public var rot : Number = 0;		// 初始角度(弧度)
		public var rotRange : Number = 0;	// 初始角度变化
		public var rotVel : Number = 0;			// 旋转速度
		public var rotVelRange : Number = 0;		// 旋转速度变化
		public var EmitterRectFrom : Vector3D = new Vector3D(-10,-10,-10);		// 发射器矩形生成范围
		public var EmitterRectTo : Vector3D = new Vector3D(10,10,10);
		
		protected var _newParticleCount : Number;
		
		// 发射器模型
		protected var _emitMesh : WireframePrimitiveBase;
		
		override public function set particleSystem(value : ParticleSystem) : void
		{
			super.particleSystem = value;
			if(_emitMesh)
				_particleSystem.addChild(_emitMesh);
		}
		
		public function RectangleParticleEmitter(particleSystem : ParticleSystem = null)
		{
			super(particleSystem);	
			_newParticleCount = 0;
		}
		
		override public function Update(currentTime : int, deltaTime : int) : void
		{
			if(!_particleSystem) return;
			
			UpdateTime(deltaTime);
			if( !_isInEmitTime )
				return;			
			
			Profiler.start("RectEmitter:Update");
			_newParticleCount += Number(deltaTime * emitRate) / 1000;
			
			// 发射粒子数
			var emitCount : int = int(_newParticleCount);
			// 粒子间时间间隔
			var timeInterval : int = 1;
			if(emitCount >= 1)
				timeInterval = deltaTime/emitCount;
			
			var i:int = 0;
			while(_newParticleCount > 1)
			{
				var newParticle : Particle = _particleSystem.GenerateParticle();
				if(newParticle)
				{	
					newParticle.reset();
					
					// 时间设置
					newParticle.startTime = currentTime + timeInterval*i;
					
					initParticle(newParticle);
					
					tellGpuDisplayer(newParticle);
				}
				
				i++;
				_newParticleCount--;
			}
			Profiler.end("RectEmitter:Update");
		}
		
		public function initParticle(newParticle:Particle) : void
		{
			// 颜色
			var r:uint = (color>>16 & 0xff) + (colorRange>>16 & 0xff) * Math.random();
			var g:uint = (color>>8 & 0xff) + (colorRange>>8 & 0xff) * Math.random();
			var b:uint = (color & 0xff) + (colorRange & 0xff) * Math.random();
			newParticle.color = (r << 16) + (g << 8) + b;
			// 透明度
			newParticle.alpha = alpha + alphaRange * Math.random();
			// uv
			newParticle.u = 0;
			newParticle.v = 0;
			// 生命期
			newParticle.remainTime = lifeTime + lifeTimeRange * Math.random();
			// 方向
			newParticle.dir.x = directionFrom.x * Math.random() + directionTo.x * Math.random();
			newParticle.dir.y = directionFrom.y * Math.random() + directionTo.y * Math.random();
			newParticle.dir.z = directionFrom.z * Math.random() + directionTo.z * Math.random();
			newParticle.dir.normalize();
			// 移动速度
			newParticle.vel = vel + velRange * Math.random();
			// 大小
			var sizeRand : Number = sizeRange * Math.random();
			newParticle.sizeX = sizeX + sizeRand;
			newParticle.sizeY = sizeY + sizeRand;
			// 旋转
			newParticle.rot = rot +  rotRange * Math.random();
			// 旋转速度
			newParticle.rotVel = rotVel + rotVelRange * Math.random();
			
			
			// 位置
			if(_particleSystem.isWolrdParticle)
				newParticle.pos.copyFrom(_particleSystem.scenePosition);
			else
				newParticle.pos.setTo(0, 0, 0);
			
			newParticle.pos.x += (EmitterRectTo.x - EmitterRectFrom.x) * Math.random() + EmitterRectFrom.x;
			newParticle.pos.y += (EmitterRectTo.y - EmitterRectFrom.y) * Math.random() + EmitterRectFrom.y;
			newParticle.pos.z += (EmitterRectTo.z - EmitterRectFrom.z) * Math.random() + EmitterRectFrom.z;
			
		}
		
		protected function tellGpuDisplayer(newParticle:Particle) : void
		{
			if( _particleSystem.displayer is GpuDisplayer )
				GpuDisplayer(_particleSystem.displayer).initGpuParticle(newParticle);	// 设置该粒子对应的vertexbuffer
		}
		
		public function showEmitter():void
		{
			if(BlConfiguration.editorMode)
			{
				_emitMesh = new WireframeCube(EmitterRectTo.x*2, EmitterRectTo.y*2, EmitterRectTo.z*2);
			}
		}
		
	}
}
/*
 *	条带系统(粒子系统的另一种实现)
 */
package away3d.particle
{
	import away3d.cameras.Camera3D;
	import away3d.core.math.Vector3DUtils;
	import away3d.core.traverse.EntityCollector;
	import away3d.core.traverse.PartitionTraverser;
	import away3d.debug.Profiler;
	import away3d.materials.DefaultMaterialBase;
	import away3d.particle.Displayer.NullDisplayer;
	import away3d.particle.Displayer.StripeDisplayer;
	import away3d.particle.Dragger.DragStripeEmitter;
	import away3d.particle.Dragger.StripeEmitterBase;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	public class StripeSystem extends ParticleSystem
	{
		// 条带
		private var _dragger : StripeEmitterBase;				// 条带拖拽器
		public var isTimedUV : Boolean = false;			// 是否根据时间决定UV
		public var wideParallel : Boolean = false;		// 条带平行拉伸
		private var _wideDir : Vector3D = new Vector3D(0,0,1);		// 条带拉伸方向
		
		
		public function set dragger(value : StripeEmitterBase) : void { _dragger = value; }
		public function get dragger() : StripeEmitterBase {return _dragger;}
		
		public function set wideDir(dragDir : Vector3D) : void
		{
			_wideDir.copyFrom(dragDir);
			_wideDir.normalize();
		}
		
		public function get wideDir() : Vector3D { return _wideDir; }
		
		public function StripeSystem(dragger : StripeEmitterBase, material : DefaultMaterialBase, max : int = 20) 
		{
			super(material, null, max, new NullDisplayer);
			isBillBoard = false;			// 条带默认非billboard
			
			_dragger = dragger;
			_dragger.stripeSystem = this;
			
			displayer = new StripeDisplayer(this);
			this.material = material;
//			showBounds = true;
		}
		
		override public function Stop(immediately : Boolean) : void
		{
			_IsEmit = false;
			if(immediately)
			{	// 所有粒子死亡
				var i:int;
				for(i=0; i<=_maxLiveIndex; i++)
				{
					_Particles[i].Dead();
				}
				_maxLiveIndex = -1;
				_dragger.Clear();				
			}
		}
		
		override protected function Update(currentTime : int, deltaTime : int, traverser : PartitionTraverser) : void
		{
//			Profiler.start("ParticleSystem:Update");
			
			//Debug.bltrace("cT=" + currentTime + " dt=" + deltaTime);
			
			// 更新粒子
			UpdateParticles(deltaTime);
			
			// 更新发射器
			if(_dragger && _IsEmit)
				_dragger.Update(deltaTime, traverser);
			
			// 更新粒子的控制器
			UpdateEffector(deltaTime);
			
			if(_displayer)
				_displayer.render(traverser);
			
			// 更新boundingbox
			UpdateBounds();
//			Profiler.end("ParticleSystem:Update");
		}
		
		override protected function UpdateEffector(deltaTime : int) : void
		{
			var i:int;
			var si:int;

			for(si=0; si<_dragger.stripeNum; si++)
			{
				var indexOrder : Vector.<int> = _dragger.getIndexOrder(si);
				var validParticleCount : int = _dragger.getStripeParticleNum(si);
				var p : Particle;
				
				for(i=0; i<indexOrder.length; i++)
				{
					if(indexOrder[i] < 0)
						break;
					
					p = _Particles[indexOrder[i]];
					
					for(var ei:int = 0; ei<_effectors.length; ei++ )
					{
						_effectors[ei].updateParticles(deltaTime, p);
					}					
				}
			}
		}
		
		//
	}
}
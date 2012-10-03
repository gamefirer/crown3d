/**
 *	在渲染时才会做update的动画器 
 */
package away3d.animators
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.errors.AbstractMethodError;
	
	import blade3d.profiler.Profiler;
	
	public class RenderAnimatorBase
	{
		private var _target : Object3D;
		
		private var _lastUpdateTime : uint;		// 上次更新的时间
		
		protected var _isPlay : Boolean = false;
		private var _setPlaying : Boolean = false;
		protected var _isLoop : Boolean = true;
		
		protected var _playingTime : uint;			// 动画播放的时间
		
		public function RenderAnimatorBase()
		{
		}
		
		public function get isPlay() : Boolean {return _isPlay;}
		
		public function get animatorType() : String
		{
			throw new AbstractMethodError();
			return null;
		}
		
		public function set target(target : Object3D) : void
		{
			_target = target;			
		}
		
		public function get target() : Object3D
		{
			return _target;
		}
		
		public function set loop(isLoop : Boolean) : void
		{
			_isLoop = isLoop;
		}
		
		public function get loop() : Boolean
		{
			return _isLoop;
		}
		
		public function playDefault() : void 
		{
			throw new AbstractMethodError();
		}
		
		public function reset(playingTime : uint = 0) : void
		{
			_playingTime = playingTime;
		}
		
		public function start() : void { _setPlaying = true; }
		public function stop() : void { _isPlay = _setPlaying = false; }
		
		// 根据时间更新动画
		public function updateAnimation(curTime : uint,  deltaTime : uint) : void
		{
			if(curTime == _lastUpdateTime)
				return;
			
			if(_setPlaying != _isPlay)
			{
				if(_isPlay)		// play -> stop
				{
					
				}
				else		// stop -> play
				{
					_lastUpdateTime = curTime;
				}
				
				_isPlay = _setPlaying;
				onPlayChange(_isPlay);
			}
			
			if(_isPlay)
				_playingTime += (curTime - _lastUpdateTime);
			else
				return;
			
			_lastUpdateTime = curTime;
			
			Profiler.start("updateRenderAnimation");
			calcAnimation(deltaTime);
			Profiler.end("updateRenderAnimation");
		}
		// 根据动画的播放时间计算动画值
		protected function calcAnimation(deltaTime : uint) : void
		{
			throw new AbstractMethodError();
		}
		
		protected function onPlayChange(isPlay:Boolean):void
		{
			
		}
		
		
		
		
	}
}
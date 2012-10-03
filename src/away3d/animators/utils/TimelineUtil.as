package away3d.animators.utils
{
	import away3d.animators.data.AnimationSequenceBase;
	import away3d.arcane;

	use namespace arcane;

	public class TimelineUtil
	{
		private var _frame0 : uint;
		private var _frame1 : uint;
		private var _blendWeight : Number;
		
		public function TimelineUtil()
		{
		}
		
		
		public function get frame0() : Number
		{
			return _frame0;
		}
		
		
		public function get frame1() : Number
		{
			return _frame1;
		}
		
		
		public function get blendWeight() : Number
		{
			return _blendWeight;
		}
		// 计算动画帧
		public function updateFrames2(playTime : uint, _activeSequence : AnimationSequenceBase, loop : Boolean) : void
		{
			var durations : Vector.<uint> = _activeSequence._durations;
			var frameCount : uint = durations.length;						// 帧数
			var totalDuration : uint = _activeSequence._totalDuration;
			
			if(frameCount == 0)
				throw new Error("no frame to update");
						
			if(playTime > totalDuration)
			{
				if(loop)
					playTime %= totalDuration;
				else
					playTime = totalDuration;
			}
			
			_frame0 = 0;
			_frame1 = 0;
			
			if(frameCount == 1)
			{
				_frame0 = 0;
				_frame1 = 0;
				_blendWeight = 0;
			}
			else if(playTime >= totalDuration)
			{
				_frame0 = frameCount-1;
				_frame1 = frameCount-1;
				_blendWeight = 0;
			}
			else
			{
				var dur1 : uint = 0;
				var dur2 : uint = 0;
				while(playTime >= dur2)
				{
					dur1 = dur2;
					dur2 += durations[_frame1];
					_frame1++;					
				}
				
				_frame0 = _frame1-1;
				if(_frame1 >= frameCount)
				{
					if(loop)
						_frame1 = 0;
					else
						_frame1--;
				}
				_blendWeight = Number(playTime - dur1) / (dur2 - dur1);				
			}
			
		}
		
		/**
		 * Calculates the frames between which to interpolate.
		 */
		public function updateFrames(time : Number, _activeSequence : AnimationSequenceBase) : void
		{
			var lastFrame : uint, frame : uint, nextFrame : uint;
			var dur : uint, frameTime : uint;
			var durations : Vector.<uint> = _activeSequence._durations;
			var totalDuration : uint = _activeSequence._totalDuration;
			var looping : Boolean = _activeSequence.looping;
			var numFrames : int = durations.length;
			var w : Number;
			
			if ((time > totalDuration || time < 0) && looping) {
				time %= totalDuration;
				if (time < 0) time += totalDuration;
			}
			
			lastFrame = numFrames - 1;
			
			if (!looping && time > totalDuration - durations[lastFrame]) {
				_activeSequence.notifyPlaybackComplete();
				frame = lastFrame;
				nextFrame = lastFrame;
				w = 0;
			}
			else if (_activeSequence._fixedFrameRate) {
				var t : Number = time/totalDuration * numFrames;
				frame = t;
				nextFrame = frame + 1;
				w = t - frame;
				if (frame == numFrames) frame = 0;
				if (nextFrame >= numFrames) nextFrame -= numFrames;
			}
			else {
				do {
					frameTime = dur;
					frame = nextFrame;					// 此行放前面,away3d的bug
					dur += durations[frame];
					
					if (++nextFrame == numFrames) {
						nextFrame = 0;
					}					
				} while (time > dur);

				w = (time - frameTime) / durations[frame];
			}
			
			_frame0 = frame;
			_frame1 = nextFrame;
			_blendWeight = w;
		}
	}
}
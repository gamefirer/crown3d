/**
 *	缩放动画控制器 
 */
package away3d.animators
{
	import away3d.animators.data.ScaleAnimationFrame;
	import away3d.animators.data.ScaleAnimationSequence;
	import away3d.animators.utils.TimelineUtil;
	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.entities.Entity;
	
	import flash.utils.Dictionary;

	use namespace arcane;
	
	public class ScaleAnimator extends RenderAnimatorBase
	{
		private var _sequences : Dictionary;
		private var _activeSequence : ScaleAnimationSequence;
		
		private static var _tlUtil : TimelineUtil = new TimelineUtil();
		private var _deltaFrame : ScaleAnimationFrame;
		
		public var ani_ScaleX : Number = 1;
		public var ani_ScaleY : Number = 1;
		public var ani_ScaleZ : Number = 1;
		
		public function ScaleAnimator(target : ObjectContainer3D)
		{
			super();
			
			this.target = target;
			
			_sequences = new Dictionary;
			_deltaFrame = new ScaleAnimationFrame();
		}
		
		override public function get animatorType() : String
		{
			return AnimatorType.SCALE_ANIMATOR;
		}
		
		public function get activeSequence() : ScaleAnimationSequence
		{
			return _activeSequence;
		}
		
		public function addSequence(sequence : ScaleAnimationSequence) : void
		{
			_sequences[sequence.name] = sequence;
			if(!_activeSequence)
				_activeSequence = sequence;
		}
		
		override public function playDefault() : void
		{
			var firstSeqName : String;
			for(var key:String in _sequences)
			{
				firstSeqName = key;
				break;
			}
			play(firstSeqName);	
		}
		
		public function play(sequenceName : String) : void
		{
			_activeSequence = _sequences[sequenceName];
			
			reset();
			start();
			
//			target.scaleXYZ(0.001);
//			updateAnimation(0,0);
		}
		
		override protected function calcAnimation(deltaTime : uint) : void
		{
			if(!target)
				return;
			
			if(_activeSequence.frames.length == 0)
				return;
			
			var w : Number;
			var frame0 : ScaleAnimationFrame, frame1 : ScaleAnimationFrame;
			
			_tlUtil.updateFrames2(_playingTime, _activeSequence, _isLoop);
			
			frame0 = _activeSequence.frames[_tlUtil.frame0];
			frame1 = _activeSequence.frames[_tlUtil.frame1];
			w = _tlUtil.blendWeight;
			
			_deltaFrame.scaleX = frame1.scaleX - frame0.scaleX;
			_deltaFrame.scaleY = frame1.scaleY - frame0.scaleY;
			_deltaFrame.scaleZ = frame1.scaleZ - frame0.scaleZ;
			
			ani_ScaleX = frame0.scaleX + (w * _deltaFrame.scaleX);
			ani_ScaleY = frame0.scaleY + (w * _deltaFrame.scaleY);
			ani_ScaleZ = frame0.scaleZ + (w * _deltaFrame.scaleZ);
			
			target.invalidateTransform();
			
		}
		
		override protected function onPlayChange(isPlay:Boolean):void
		{
			if(isPlay && target)
				target.invalidateTransform();
		}
		
//		override protected function updateAnimation(realDT:Number, scaledDT:Number):void
//		{
//			if(!_target)
//				return;
//			
////			Profiler.start("ScaleAnimator");
//			
//			var w : Number;
//			var frame0 : ScaleAnimationFrame, frame1 : ScaleAnimationFrame;
//			
//			
//			
//			_absoluteTime += scaledDT;
//			
////			if (_absoluteTime >= _activeSequence._totalDuration)
////				_absoluteTime %= _activeSequence._totalDuration;
//			
//			var frame : ScaleAnimationFrame;
//			var idx : uint;
//			
//			_tlUtil.updateFrames(_absoluteTime, _activeSequence);
//
//			frame0 = _activeSequence._frames[_tlUtil.frame0];
//			frame1 = _activeSequence._frames[_tlUtil.frame1];
//			w = _tlUtil.blendWeight;
//			
//			_deltaFrame.scaleX = frame1.scaleX - frame0.scaleX;
//			_deltaFrame.scaleY = frame1.scaleY - frame0.scaleY;
//			_deltaFrame.scaleZ = frame1.scaleZ - frame0.scaleZ;
//			
//			_target.scaleX = frame0.scaleX + (w * _deltaFrame.scaleX);
//			_target.scaleY = frame0.scaleY + (w * _deltaFrame.scaleY);
//			_target.scaleZ = frame0.scaleZ + (w * _deltaFrame.scaleZ);
//			
////			Profiler.end("ScaleAnimator");
//		}
		
//		override public function reset(absoluteTime : Number = 0) : void
//		{
//			_absoluteTime = absoluteTime;
//			if(_target && _activeSequence && _activeSequence._frames[0])
//			{
//				_target.scaleX = _activeSequence._frames[0].scaleX;
//				_target.scaleY = _activeSequence._frames[0].scaleY;
//				_target.scaleZ = _activeSequence._frames[0].scaleZ;
//			}
//			
//		}
	}
}
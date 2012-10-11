/**
 *	旋转动画控制器 
 */
package away3d.animators
{
	import away3d.animators.data.RotateAnimationFrame;
	import away3d.animators.data.RotateAnimationSequence;
	import away3d.animators.utils.TimelineUtil;
	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	use namespace arcane;
	
	public class RotateAnimator extends RenderAnimatorBase
	{
		private var _sequences : Dictionary;
		private var _activeSequence : RotateAnimationSequence;
		
		private static var _tlUtil : TimelineUtil = new TimelineUtil() ;
		
		public var ani_RotX : Number = 0;
		public var ani_RotY : Number = 0;
		public var ani_RotZ : Number = 0;
		
		public function RotateAnimator(target : ObjectContainer3D = null)
		{
			super();
			
			this.target = target;
			
			_sequences = new Dictionary;
		}
		
		override public function get animatorType() : String
		{
			return AnimatorType.ROTATE_ANIMATOR;
		}
		
		public function get activeSequence() : RotateAnimationSequence
		{
			return _activeSequence;
		}
		
		public function addSequence(sequence : RotateAnimationSequence) : void
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
			
		}
		
		override protected function calcAnimation(deltaTime : uint) : void
		{
			if(!target)
				return;
			
			var frame0 : RotateAnimationFrame;
			
			_tlUtil.updateFrames2(_playingTime, _activeSequence, _isLoop);
			frame0 = _activeSequence.frames[_tlUtil.frame0];
			
			ani_RotX += frame0.rotX * deltaTime / 1000;
			ani_RotY += frame0.rotY * deltaTime / 1000;
			ani_RotZ += frame0.rotZ * deltaTime / 1000;
			
			target.invalidateTransform();
		}
		
		
	}
}
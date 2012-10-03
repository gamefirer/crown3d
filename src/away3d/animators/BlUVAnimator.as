/**
 *	UV动画控制器 
 */
package away3d.animators
{
	import away3d.animators.data.UVAnimationFrame;
	import away3d.animators.data.UVAnimationSequence;
	import away3d.animators.utils.TimelineUtil;
	import away3d.arcane;
	import away3d.core.base.SubMesh;
	import away3d.materials.TextureMaterial;
	
	import flash.utils.Dictionary;

	use namespace arcane;
	
	public class BlUVAnimator extends RenderAnimatorBase
	{
		private var _targetMesh : SubMesh;
		private var _sequences : Dictionary;
		private var _activeSequence : UVAnimationSequence;
		
		private static var _tlUtil : TimelineUtil = new TimelineUtil();
		private var _deltaFrame : UVAnimationFrame;
		
		private var _isSmooth : Boolean = true;			// if true uv动画平滑移动 else uv动画跳跃变换(9宫格)
		private var _isRepeat : Boolean = false;			// 贴图循环
		
		public function get smooth():Boolean {return _isSmooth;}
		public function set smooth(val:Boolean):void {_isSmooth = val;}
		public function get repeat():Boolean {return _isRepeat;}
		public function set repeat(val:Boolean):void
		{
			_isRepeat = val;
			if(_targetMesh)
				_targetMesh.material.repeat = _isRepeat;
		}
		
		public function BlUVAnimator(target : SubMesh)
		{
			super();
			
			_targetMesh = target;
			if(_targetMesh)
			{
				_targetMesh.uvRotation = 1;
				_targetMesh.uvRotation = 0;					// make _uvTransformDirty
				_targetMesh.material.repeat = repeat;
			}
			_sequences = new Dictionary;
			_deltaFrame = new UVAnimationFrame();
		}
		
		override public function get animatorType() : String
		{
			return AnimatorType.UV_ANIMATOR;
		}
		
		public function activeSequence() : UVAnimationSequence
		{
			return _activeSequence;
		}
		
		public function setTargetMesh(target : SubMesh) : void
		{
			_targetMesh = target;
			
			if(_targetMesh)
			{
				_targetMesh.uvRotation = 1;
				_targetMesh.uvRotation = 0;					// make _uvTransformDirty
				_targetMesh.material.repeat = repeat;
			}
		}
		
		public function addSequence(sequence : UVAnimationSequence) : void
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
			var material : TextureMaterial = _targetMesh.material as TextureMaterial;

			_activeSequence = _sequences[sequenceName];

			if (material)
			{
				material.animateUVs = true;
				material.repeat = _isRepeat;
			}

			reset();
			start();
			
		}
		
		override protected function calcAnimation(deltaTime:uint):void
		{
			if(!_targetMesh)
				return;
			
			var w : Number;
			var frame0 : UVAnimationFrame, frame1 : UVAnimationFrame;
			
			_tlUtil.updateFrames2(_playingTime, _activeSequence, _isLoop);
			
			if(_isSmooth)
			{
				frame0 = _activeSequence.frames[_tlUtil.frame0];
				frame1 = _activeSequence.frames[_tlUtil.frame1];
				w = _tlUtil.blendWeight;
				
				_deltaFrame.offsetU = frame1.offsetU - frame0.offsetU;
				_deltaFrame.offsetV = frame1.offsetV - frame0.offsetV;
				_deltaFrame.scaleU = frame1.scaleU - frame0.scaleU;
				_deltaFrame.scaleV = frame1.scaleV - frame0.scaleV;
				_deltaFrame.rotation = frame1.rotation - frame0.rotation;
				
				_targetMesh.offsetU = frame0.offsetU + (w * _deltaFrame.offsetU);
				_targetMesh.offsetV = frame0.offsetV + (w * _deltaFrame.offsetV);
				_targetMesh.scaleU = frame0.scaleU + (w * _deltaFrame.scaleU);
				_targetMesh.scaleV = frame0.scaleV + (w * _deltaFrame.scaleV);
				_targetMesh.uvRotation = frame0.rotation + (w * _deltaFrame.rotation);
			}
			else
			{
				frame0 = _activeSequence.frames[_tlUtil.frame0];
				
				_targetMesh.offsetU = frame0.offsetU;
				_targetMesh.offsetV = frame0.offsetV;
				_targetMesh.scaleU = frame0.scaleU;
				_targetMesh.scaleV = frame0.scaleV;
				_targetMesh.uvRotation = frame0.rotation;
			}
		}
		
	}
}
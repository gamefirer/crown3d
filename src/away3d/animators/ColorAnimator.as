/**
 *	贴图颜色动画 
 */
package away3d.animators
{
	import away3d.animators.data.ColorAnimationFrame;
	import away3d.animators.data.ColorAnimationSequence;
	import away3d.animators.utils.TimelineUtil;
	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.DefaultMaterialBase;
	
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;

	use namespace arcane;
	
	public class ColorAnimator extends RenderAnimatorBase
	{
		private var _sequences : Dictionary;
		private var _activeSequence : ColorAnimationSequence;
		
		private static var _tlUtil : TimelineUtil = new TimelineUtil();
		
		private var _targetMesh : Mesh;

		private var _deltaFrame : ColorAnimationFrame;
		
		public function ColorAnimator(target : Mesh)
		{
			super();
			
			this.target = target;
			
			_sequences = new Dictionary;
			_deltaFrame = new ColorAnimationFrame();
		}
		
		override public function get animatorType() : String
		{
			return AnimatorType.COLOR_ANIMATOR;
		}
		
		public function get activeSequence():ColorAnimationSequence
		{
			return _activeSequence;
		}
		
		public function setTargetMesh(target : Mesh) : void
		{
			_targetMesh = target;
			if(!_targetMesh)
				return;
			
			if( DefaultMaterialBase(_targetMesh.material).colorTransform == null)
				DefaultMaterialBase(_targetMesh.material).colorTransform = new ColorTransform;
		}
		
		public function addSequence(sequence : ColorAnimationSequence) : void
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
		
//		override public function reset(absoluteTime : Number = 0) : void
//		{
//			_absoluteTime = absoluteTime;
//		}
		
		public function play(sequenceName : String) : void
		{
			_activeSequence = _sequences[sequenceName];
			
			reset();
			start();
			
//			updateAnimation(0, 0);
		}
		
		override protected function calcAnimation(deltaTime:uint):void
		{
			if(!_targetMesh)
				return;
			
			var colorTransform : ColorTransform = DefaultMaterialBase(_targetMesh.material).colorTransform;
			if(!colorTransform)
				return;
			
			var w : Number;
			var frame0 : ColorAnimationFrame, frame1 : ColorAnimationFrame;
			
			_tlUtil.updateFrames2(_playingTime, _activeSequence, _isLoop);
			
			frame0 = _activeSequence.frames[_tlUtil.frame0];
			frame1 = _activeSequence.frames[_tlUtil.frame1];
			w = _tlUtil.blendWeight;
			
			_deltaFrame.A = frame1.A - frame0.A;
			_deltaFrame.R = frame1.R - frame0.R;
			_deltaFrame.G = frame1.G - frame0.G;
			_deltaFrame.B = frame1.B - frame0.B;
			
			var a : Number = Number(frame0.A + (w * _deltaFrame.A))/0xff;
			var r : Number = Number(frame0.R + (w * _deltaFrame.R))/0xff;
			var g : Number = Number(frame0.G + (w * _deltaFrame.G))/0xff;
			var b : Number = Number(frame0.B + (w * _deltaFrame.B))/0xff;
			
			colorTransform.alphaMultiplier = a;
			colorTransform.redMultiplier = r;
			colorTransform.greenMultiplier = g;
			colorTransform.blueMultiplier = b;
		}
		
				
	}
}
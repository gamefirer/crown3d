/**
 *	骨骼中骨头关键帧实现的,SkeletonTreeNode
 * 	 
 */
package away3d.animators.nodes
{
	import away3d.animators.data.JointPose;
	import away3d.animators.data.Skeleton;
	import away3d.animators.data.SkeletonKeyframeAnimationSequence;
	import away3d.animators.data.SkeletonPose;
	import away3d.debug.Debug;

	public class SkeletonKeyFrameClipNode extends SkeletonClipNode
	{
		public var _clip : SkeletonKeyframeAnimationSequence;
		
		public function SkeletonKeyFrameClipNode()
		{
			super();
		}
		
		override public function getSkeletonPose(skeleton:Skeleton):SkeletonPose
		{
			if (_skeletonPoseDirty)
				updateSkeletonPose(skeleton);
			
			return _skeletonPose;
		}
		// 更新骨骼
		override protected function updateSkeletonPose(skeleton:Skeleton) : void
		{
			_skeletonPoseDirty = false;
			
			var numJoints : uint = skeleton.numJoints;
			var endPoses : Vector.<JointPose> = _skeletonPose.jointPoses;
			
			if (endPoses.length != numJoints) 
				endPoses.length = numJoints;
			
//			Debug.trace(_time);
			// 更新每个骨头
			var endPose : JointPose;			
			for (var i : uint = 0; i < numJoints; ++i) 
			{
				endPose = endPoses[i] ||= new JointPose();
				
				var bonePose : JointPose = _clip.getBonePose(i, _time);
				endPose.translation.copyFrom(bonePose.translation);
				endPose.orientation.copyFrom(bonePose.orientation);
			}
		}
		
		override protected function updateRootDelta() : void
		{
		
		}
		
		override protected function updateFrames() : void
		{
			
		}
		
		override protected function updateStitch():void
		{
			
		}
	}
}
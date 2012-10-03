/**
 *	骨骼上的挂接点(要addchild到mesh上,否则场景搜索时不会被找到)
 */
package away3d.entities
{
	import away3d.animators.SkeletonAnimator;
	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.library.assets.AssetType;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	use namespace arcane;
	
	public class BoneTag extends ObjectContainer3D
	{
		private var _skeletonAnimator : SkeletonAnimator;		// 绑定点所在的骨骼
		private var _boneIndex : int;			// 绑定的骨头的index
		
		public function BoneTag(skeletonAnimation : SkeletonAnimator, boneIndex : int)
		{
			super();
			_skeletonAnimator = skeletonAnimation;
			_boneIndex = boneIndex;
		}
		
		override public function get assetType() : String
		{
			return AssetType.BONE_TAG;
		}
		// 需要更新矩阵(提供给所在骨骼调用)
		public function needUpdateSceneTransform() : void
		{
			invalidateTransform();
		}
		
		// BoneTag的parent.sceneTransform是骨骼中某骨头的位置
		override protected function updateSceneTransform():void
		{
			if (_parent) 
			{
				_sceneTransform.copyFrom( _skeletonAnimator.globalPose.jointPoses[_boneIndex].toMatrix3D() );		// 骨头位置
				_sceneTransform.append( _parent.sceneTransform );		// 骨骼位置
				_sceneTransform.prepend(transform);
				
				///Debug.bltrace(  _skeletonAnimation.globalPose.jointPoses[1].translation );
			}
			else 
			{
					// 该骨骼绑定点已经被释放,没有parent
			}
			
			_sceneTransformDirty = false;
			
		}
		
		override public function dispose() : void
		{
			_skeletonAnimator = null;
			
			super.dispose();
		}

	}
}
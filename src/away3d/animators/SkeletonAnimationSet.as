package away3d.animators
{
	import away3d.animators.*;
	import away3d.core.managers.*;
	import away3d.materials.passes.*;

	/**
	 * The animation data set used by skeleton-based animators, containing skeleton animation state data.
	 * 
	 * @see away3d.animators.SkeletonAnimator
	 * @see away3d.animators.SkeletonAnimationState
	 */
	public class SkeletonAnimationSet extends AnimationSetBase implements IAnimationSet
	{
		private var _jointsPerVertex : uint;
		
		/**
		 * Returns the amount of skeleton joints that can be linked to a single vertex via skinned weight values. For GPU-base animation, the 
		 * maximum allowed value is 4.
		 */
		public function get jointsPerVertex() : uint
		{
			return _jointsPerVertex;
		}
		
		/**
		 * Creates a new <code>SkeletonAnimationSet</code> object.
		 * 
		 * @param jointsPerVertex Sets the amount of skeleton joints that can be linked to a single vertex via skinned weight values. For GPU-base animation, the maximum allowed value is 4. Defaults to 4.
		 */
		public function SkeletonAnimationSet(jointsPerVertex : uint = 4)
		{
			_jointsPerVertex = jointsPerVertex;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getAGALVertexCode(pass : MaterialPassBase, sourceRegisters : Array, targetRegisters : Array) : String
		{
			var len : uint = sourceRegisters.length;

			var indexOffset0 : uint;
			if(SkeletonAnimator.useDualQuat)
				indexOffset0 = pass.numUsedVertexConstants+1;
			else
				indexOffset0 = pass.numUsedVertexConstants;
			var indexOffset1 : uint = indexOffset0 + 1;
			var indexOffset2 : uint = indexOffset0 + 2;
			var indexStream : String = "va" + pass.numUsedStreams;
			var weightStream : String = "va" + (pass.numUsedStreams + 1);
			var indices : Array = [ indexStream + ".x", indexStream + ".y", indexStream + ".z", indexStream + ".w" ];
			var weights : Array = [ weightStream + ".x", weightStream + ".y", weightStream + ".z", weightStream + ".w" ];
			var temp1 : String = findTempReg(targetRegisters);
			var temp2 : String = findTempReg(targetRegisters, temp1);
			var temp3 : String = findTempReg2(targetRegisters, [temp1, temp2]);
			var temp4 : String = findTempReg2(targetRegisters, [temp1, temp2, temp3]);
			var temp5 : String = findTempReg2(targetRegisters, [temp1, temp2, temp3, temp4]);
			var temp6 : String = findTempReg2(targetRegisters, [temp1, temp2, temp3, temp4, temp5]);
			var temp7 : String = findTempReg2(targetRegisters, [temp1, temp2, temp3, temp4, temp5, temp6]);
			var dot : String = "dp4";
			var code : String = "";
			
			var const0 : String = "vc" + (indexOffset0-1) + "";  // [0, 1, 0, 0]

			for (var i : uint = 0; i < len; ++i) 
			{
				var src : String = sourceRegisters[i];

				for (var j : uint = 0; j < _jointsPerVertex; ++j)
				{
					if(SkeletonAnimator.useDualQuat)
					{
						code +=
							// temp1 = 旋转(四元数)
							"mov " + temp1 + ", " + "vc[" + indices[j] + "+" + indexOffset1 + "]\n" +
							// 先将旋转四元数(范化四元数)，转换为矩阵
							// [ 1-2yy-2zz , 2xy-2wz , 2xz+2wy ]
							// [ 2xy+2wz , 1-2xx-2zz , 2yz-2wx ]
							// [ 2xz-2wy , 2yz+2wx , 1-2xx-2yy ]
							"add " + temp2 + ".xyz, " + temp1 + ".xyz, " + temp1 + ".xyz\n" +	// temp2 = temp1*2
							// 使 temp4(2x*w, 2y*w, 2z*w)
							"mul " + temp4 + ".x, " + temp2 + ".x, " + temp1 + ".w\n" +		// 2x*w
							"mul " + temp4 + ".y, " + temp2 + ".y, " + temp1 +".w\n" +		// 2y*w
							"mul " + temp4 + ".z, " + temp2 + ".z, " + temp1 + ".w\n" +		// 2z*w
							// 使 temp5(2x*x, 2y*x, 2z*x)
							"mul " + temp5 + ".x, " + temp2 + ".x, " + temp1 + ".x\n" +		// 2x*x
							"mul " + temp5 + ".y, " + temp2 + ".y, " + temp1 + ".x\n" + 		// 2y*x
							"mul " + temp5 + ".z, " + temp2 + ".z, " + temp1 + ".x\n" +		// 2z*x
							// 使 temp6(2y*y, 2z*y, 2z*z)
							"mul " + temp6 + ".x, " + temp2 + ".y, " + temp1 + ".y\n" +		// 2y*y
							"mul " + temp6 + ".y, " + temp2 + ".z, " + temp1 + ".y\n" + 		// 2z*y
							"mul " + temp6 + ".z, " + temp2 + ".z, " + temp1 + ".z\n" + 		// 2z*z
							
							// 到此 temp1, temp2, temp3 不再需要，可以使用了
							
							// 使 temp1 为 [ 1-2yy-2zz , 2xy-2wz , 2xz+2wy, ]
							"add " + temp1 + ".x, " + temp6 + ".x, " + temp6 + ".z\n" +		// 2yy+2zz
							"sub " + temp1 + ".x, " + const0 + ".y, " + temp1 + ".x\n" +		// 1-(2yy+2zz)
							"sub " + temp1 + ".y, " + temp5 + ".y, " + temp4 + ".z\n" + 		// 2yx - 2zw
							"add " + temp1 + ".z, " + temp5 + ".z, " + temp4 + ".y\n" + 		// 2zx + 2yw
							// 使 temp2 为 [ 2xy+2wz , 1-2xx-2zz , 2yz-2wx, ]
							"add " + temp2 + ".x, " + temp5 + ".y, " + temp4 + ".z\n" +		// 2yx + 2zw
							"add " + temp2 + ".y, " + temp5 + ".x, " + temp6 + ".z\n" +		// 2xx + 2zz
							"sub " + temp2 + ".y, " + const0 + ".y, "+ temp2 + ".y\n" +		// 1-(2xx+2zz)
							"sub " + temp2 + ".z, " + temp6 + ".y, " + temp4 + ".x\n" +		// 2zy - 2xw
//							"mov " + temp2 + ", " + const0 + ".y\n" +
//							"mov " + temp2 + ".w, " + const0 + ".y\n" +
							//  使 temp3 为 [ 2xz-2wy , 2yz+2wx , 1-2xx-2yy, ]
							"sub " + temp3 + ".x, " + temp5 + ".z, " + temp4 + ".y\n" +		// 2zx - 2yw
							"add " + temp3 + ".y, " + temp6 + ".y, " + temp4 + ".x\n" +		// 2zy + 2xw
							"add " + temp3 + ".z, " + temp5 + ".x, " + temp6 + ".x\n" + 		// 2xx + 2yy
							"sub " + temp3 + ".z, " + const0 + ".y, " + temp3 + ".z\n" +		// 1-(2xx+2yy)
							
							
							// 加入位移
							"mov " + temp1 + ".w, " + "vc[" + indices[j] + "+" + indexOffset0 + "].x\n" +
							"mov " + temp2 + ".w, " + "vc[" + indices[j] + "+" + indexOffset0 + "].y\n" +
							"mov " + temp3 + ".w, " + "vc[" + indices[j] + "+" + indexOffset0 + "].z\n" +
							
							//  顶点*骨头矩阵
							dot + " " + temp4 + ".x, " + src + ", " + temp1 + "\n" +
							dot + " " + temp4 + ".y, " + src + ", " + temp2+ "\n" +
							dot + " " + temp4 + ".z, " + src + ", " + temp3 + "\n" +
							
							// 到此不再需要temp1, temp2, temp3
							"mov " + temp4 + ".w, " + src + ".w\n" +
							"mul " + temp1 + ", " + temp4 + ", " + weights[j] + "\n"; 	// apply weight
					}
					else
					{
						code +=	dot + " " + temp1 + ".x, " + src + ", vc[" + indices[j] + "+" + indexOffset0 + "]		\n" +
								dot + " " + temp1 + ".y, " + src + ", vc[" + indices[j] + "+" + indexOffset1 + "]    	\n" +
								dot + " " + temp1 + ".z, " + src + ", vc[" + indices[j] + "+" + indexOffset2 + "]		\n" +
								"mov " + temp1 + ".w, " + src + ".w		\n" +
								"mul " + temp1 + ", " + temp1 + ", " + weights[j] + "\n";	// apply weight
					}

					// add or mov to target. Need to write to a temp reg first, because an output can be a target
					if(SkeletonAnimator.useDualQuat)
					{
						// temp7 加和 每个骨头的结果
						if (j == 0) 
							code += "mov " + temp7 + ", " + temp1 + "\n";
						else 
							code += "add " + temp7 + ", " + temp7 + ", " + temp1 + "\n";
					}
					else
					{
						if (j == 0) 
							code += "mov " + temp2 + ", " + temp1 + "\n";
						else 
							code += "add " + temp2 + ", " + temp2 + ", " + temp1 + "\n";
					}
				}
				// switch to dp3 once positions have been transformed, from now on, it should only be vectors instead of points
				dot = "dp3";
				if(SkeletonAnimator.useDualQuat)
					code += "mov " + targetRegisters[i] + ", " + temp7 + "\n";
				else
					code += "mov " + targetRegisters[i] + ", " + temp2 + "\n";
			}

			return code;
		}
		
		/**
		 * @inheritDoc
		 */
		public function activate(stage3DProxy : Stage3DProxy, pass : MaterialPassBase) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function deactivate(stage3DProxy : Stage3DProxy, pass : MaterialPassBase) : void
		{
			var streamOffset : uint = pass.numUsedStreams;

			stage3DProxy.setSimpleVertexBuffer(streamOffset, null, null, 0);
			stage3DProxy.setSimpleVertexBuffer(streamOffset + 1, null, null, 0);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function addState(stateName:String, animationState:IAnimationState):void
		{
			super.addState(stateName, animationState);
			
			animationState.addOwner(this, stateName);
		}
	}
}

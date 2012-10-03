package sl2d.shader
{
	import away3d.core.managers.Context3DProxy;
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	public class slBallShader extends slProgram
	{
//		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, color);
//		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, color1);
//		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, color2);
//		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, _paramVector);
		public function slBallShader(){
			
		}
		
		
		override public function updateContext(context:Context3D):void
		{
			if(_program)
				Context3DProxy.disposeProgram(_program);
			_program = Context3DProxy.createProgram(); // context.createProgram();
			
//			var vertexAgal:String = 
//				"mov vt1, va0 \n"+
//				"m44 op, vt1, vc0 \n"+	// 4x4 matrix transform from world space to output clipspace
//				"mov v0, va1 \n"	// copy xformed tex coords to fragment program
			
			var shaderAgal:String = 
				"mov ft0, v0 \n" +									// ft0 = v0 = uv
				"tex ft1, ft0.xy, fs1 <2d,clamp,linear> \n" + 	// color(ft2) = tex2 sample uv(ft0.xy)
				"mov ft2, ft1 \n"	+									// ft2 = ft1
//				如果采样2中的颜色alpha < 0.5,就不绘制。
				"sub ft2.w, ft2.w, fc3.z \n" + 						// ft2.w = ft2.w - fc3.z
				"kil ft2.w \n" + 										// ft2.w < 0, return;
				//如果顶点坐标y小于进度的y就不绘制
				"tex ft3, ft0.xy, fs0 <2d,clamp,linear> \n" + 	// color(ft3) = tex1 sample uv(ft0.xy)
				
				"sge ft2.x, ft1.x, fc3.z \n" + 						//ft2.x = (ft1.x > fc3.z) ? 1 ; 0 (r > 0.2 ? 1 : 0)
				"sge ft2.y, ft1.z, fc3.z \n" + 						//ft2.y = (ft1.z > fc3.z) ? 1 : 0 (b > 0.2 ? 1 : 0)
				"mov ft4.xy, ft2.xy \n" + 
				"mul ft2.x, ft2.x, fc3.x \n" + 						//ft2.x = ft2.x * fc3.x
				"mul ft2.y, ft2.y, fc3.y \n" + 						//ft2.y = ft2.y * fc3.y
				"add ft2.w, ft2.x, ft2.y \n" +						//ft2.w = ft2.x + ft2.y		(ft2:progress的值,小于progress的部分不会被显示)
				"sub ft2.w, ft0.y, ft2.w \n" +						//ft2.w = ft0.y - ft2.w
				"kil ft2.w \n" +
				
				"mul ft5, ft4.xxxx, fc1.xyzw \n" +					//ft5 = ft4.xxxx * fc1.xyzw
				"mul ft6, ft4.yyyy, fc2.xyzw \n" + 					//ft6 = ft4.yyyy * fc2.xyzw
				"add ft7, ft5, ft6 \n" + 							//ft7 = ft5 + ft6
				"mul ft3, ft3, ft7 \n" + 							//ft3 = ft3 * ft7	(目标颜色乘以偏色)
				
				"mul ft3, ft3, fc0\n" + 								// ft3 = color(ft3) * rgba(fc0)
				"mov oc, ft3";											// output ft3
			
			var sAgal:AGALMiniAssembler = new AGALMiniAssembler();
			var vAgal:AGALMiniAssembler = new AGALMiniAssembler();
			sAgal.assemble(Context3DProgramType.FRAGMENT, shaderAgal);
			vAgal.assemble(Context3DProgramType.VERTEX, _vertexAgal);
			
			_program.upload(vAgal.agalcode, sAgal.agalcode);
			
			_blendSrc = Context3DBlendFactor.SOURCE_ALPHA;
			_blendDst = Context3DBlendFactor.ONE;
			
		}
		
		
	}
}
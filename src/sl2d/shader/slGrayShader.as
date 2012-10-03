package sl2d.shader
{
	import away3d.core.managers.Context3DProxy;
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	public class slGrayShader extends slProgram
	{
		
		public function slGrayShader()
		{

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
				"mov ft0, v0 \n" +			// ft0 = v0 = uv
				"tex ft2, ft0.xy, fs0 <2d,clamp,linear> \n" + // color(ft2) = texsample uv(ft0.xy)
				"mul ft2, ft2, fc0 \n" + 	// ft2 = color(ft2) * rgba(ft1)
				"mul ft2.xyz, ft2.xyz, fc1.xyz \n" +     // ft2 = color(ft2) * grayColor;
				"add ft2.x, ft2.x, ft2.y \n" +
				"add ft2.x, ft2.x, ft2.z \n" +
				"mov ft2.xyz, ft2.xxx\n" +
				"mov oc, ft2";					// output ft2
			
			
			
			
			var sAgal:AGALMiniAssembler = new AGALMiniAssembler();
			var vAgal:AGALMiniAssembler = new AGALMiniAssembler();
			sAgal.assemble(Context3DProgramType.FRAGMENT, shaderAgal);
			vAgal.assemble(Context3DProgramType.VERTEX, _vertexAgal);
			
			_program.upload(vAgal.agalcode, sAgal.agalcode);
			
			_blendSrc = Context3DBlendFactor.SOURCE_ALPHA;
			_blendDst = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
		}
	}
}
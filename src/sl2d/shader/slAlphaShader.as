package sl2d.shader
{
	import away3d.core.managers.Context3DProxy;
	
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	public class slAlphaShader extends slProgram
	{
		
//		_context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
//		_context.setVertexBufferAt(1, _uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
//		_context.setVertexBufferAt(2, _colorBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
//		private static const VERTEX_CONSTANT_1 : Vector.<Number> = Vector.<Number> ( [0, 0, 0, -0.01] );
//		_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _camara.getViewProjectionMatrix(), true);
//		_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 1, VERTEX_CONSTANT_1);
		public function slAlphaShader()
		{
			
		}
		
		override public function updateContext(context:Context3D):void
		{	
			if(_program)
				Context3DProxy.disposeProgram(_program);
			_program = Context3DProxy.createProgram(); // context.createProgram();
			//			_passCompairMode = Context3DCompareMode.GREATER;
			
//			var vertexAgal:String = 
//				"mov vt1, va0 \n"+
//				"m44 op, vt1, vc0 \n"+	// 4x4 matrix transform from world space to output clipspace
//				"mov v0, va1 \n"	// copy xformed tex coords to fragment program
			
			var shaderAgal:String = 
				"mov ft0, v0 \n" +			// ft0 = v0 = uv
				"tex ft2, ft0.xy, fs0 <2d,clamp,linear> \n" + // color(ft2) = texsample uv(ft0.xy)
				"mul ft2, ft2, fc0 \n" + 	// ft2 = color(ft2) * rgba(ft1)
				"mov oc, ft2\n";					// output ft2
			
			
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
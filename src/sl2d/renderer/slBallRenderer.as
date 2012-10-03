package sl2d.renderer
{
	import away3d.containers.View3D;
	import away3d.core.managers.Context3DProxy;
	import away3d.core.managers.Stage3DProxy;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	
	import sl2d.display.slBounds;
	import sl2d.shader.slProgram;
	import sl2d.shader.slShader;
	import sl2d.utils.HashTable;

	public class slBallRenderer
	{
		private var _paramVector:Vector.<Number> = new Vector.<Number>();
		public function slBallRenderer()
		{
		}
		
		public function render(context:Context3D,
							   vMap:HashTable, 
							   hMap:HashTable, 
							   item:slBounds, 
							   texture1:Texture, 
							   texture2:Texture, 
							   color1:Vector.<Number>, 
							   color2:Vector.<Number>, 
							   progress1:Number, 
							   progress2:Number):void
		{
			var color:Vector.<Number> = item.colorData;
			var vertexBuffer:VertexBuffer3D = vMap.getValue(0);
			var indexBuffer:IndexBuffer3D = hMap.getValue(1);
			var uvInfo:Vector.<Number> = item.boundsInfo;
			_paramVector.length = 0;
			_paramVector.push(progress1, progress2, 0.2, 1);
			
			_paramVector.length = 4;
			//换一个顶点和uv坐标的缓冲。。
			context.setTextureAt(0, texture1);
			context.setTextureAt(1, texture2);
			var shader:slProgram = slShader.Ball;
			
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, color);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, color1);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, color2);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, _paramVector);
			
			context.setProgram(shader.program);
			context.setBlendFactors(shader.blendSrc, shader.blendDst);
			// vertex shader设置
			_paramVector[0] = uvInfo[0];
			_paramVector[1] = uvInfo[1];
			_paramVector[2] = uvInfo[4*3];
			_paramVector[3] = uvInfo[4*3+1];
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 32, _paramVector, 1);
			
			_paramVector[0] = uvInfo[2];
			_paramVector[1] = uvInfo[3];
			_paramVector[2] = uvInfo[4*3+2];
			_paramVector[3] = uvInfo[4*3+3];
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 32+1, _paramVector, 1);
			
			_paramVector[0] = 0;
			_paramVector[1] = 0;
			_paramVector[2] = 0;
			_paramVector[3] = 0;
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 32+2, _paramVector, 1);
			
			// draw
			context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
			Context3DProxy.drawTriangles(indexBuffer, 0, 2);
			Context3DProxy.drawUICall++;
			//reset
			context.setTextureAt(1, null);
		}
	}
}
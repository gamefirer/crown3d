package sl2d.shader
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Program3D;

	public class slProgram
	{
		protected var _program:Program3D;
		protected var _blendSrc: String;
		protected var _blendDst: String;
		
		public function get program():Program3D{ return _program; }
		public function get blendSrc():String{ return _blendSrc; }
		public function get blendDst():String{ return _blendDst; }
		
		static protected var _vertexAgal:String;
		
		public function slProgram()
		{
			// 公共VertexShader
			_vertexAgal =
				// 初始化vt0-5
				"mov vt0, vc4.wwww\n"+
				"mov vt1, vc4.wwww\n"+
				"mov vt2, vc4.wwww\n"+
				"mov vt3, vc4.wwww\n"+
				"mov vt4, vc4.wwww\n"+
				"mov vt5, vc4.wwww\n"+				
				// 寻找该矩形对应的vc
				"mul vt1.x, va0.x, vc4.y\n" +		// 第几个矩形*3
				"add vt1.y, vt1.x, vc4.x\n" +		// 第几个矩形*3+32, vt1.y=该矩形对应的常量寄存器
				"mov vt0, vc[vt1.y]\n"+				// vt0 为该矩形的pos
				"add vt1.y, vt1.y, vc4.z\n" +
				"mov vt1, vc[vt1.y]\n"+				// vt1 为该矩形的uv
				// 计算顶点位
				"mov vt3, va0.zwzw\n" +
				"sub vt3.z, vc4.z, vt3.z\n"+		// vt3 = (va0.z, va0.w, 1-va0.z, 1-va0.w)
				"sub vt3.w, vc4.z, vt3.w\n"+		// vt3 = (1100) (0110) (1001) (0011)
				// pos
				"mul vt4, vt0, vt3\n"+
				"add vt4.xy, vt4.xy, vt4.zw\n"+
				// uv
				"mul vt5, vt1, vt3\n"+
				"add vt5.xy, vt5.xy, vt5.zw\n"+
				//
				"mov vt4.zw, vc4.wz\n"+			// (posx, posy, 0 ,1)
				"m44 op, vt4, vc0\n"+
				"mov v0, vt5\n";					// (u, v, *, *)
			
		}
		
		public function updateContext(context:Context3D):void{
			
		}
		
		
	}
}
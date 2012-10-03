/*
 *	渲染场景lightmap用的pass
 */
package away3d.materials.passes
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.textures.BitmapTexture;
	
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	
	use namespace arcane;
	
	public class LightMapPass extends MaterialPassBase
	{
		private var _lightMapTexture : BitmapTexture;			// 光照贴图
		private var _constVector : Vector.<Number>;			// 常量
		private var _constClrVector : Vector.<Number>;			// 颜色值常量
		
		public function LightMapPass()
		{
			super();
			_constVector = Vector.<Number>([0.0, 1.0, 0.1, 0.0]);		// fc0.y光照强度  fc0.z 没有贴图的渲染值
			_constClrVector = Vector.<Number>([1.0, 1.0, 1.0, 0.0])		// 
			_lightMapTexture = null;
		}
		
		public function set lightMapTexture(tex : BitmapTexture) : void
		{
			_lightMapTexture = tex;
		}
		
		public function setLightColor(r:Number, g:Number, b:Number) : void
		{
			_constClrVector[0] = r;
			_constClrVector[1] = g;
			_constClrVector[2] = b;
		}
		// 设置光照强度
		public function setLightIntensity(value : Number) : void
		{
			_constVector[1] = value;
		}
		
		// vertex shader 代码
		arcane override function getVertexCode(code : String) : String
		{
			// project
			code += "m44 vt1, vt0, vc0		\n" +
					"mul op, vt1, vc4\n";
			
			var _passCode : String = "";
			// vt1是投影空间的坐标(乘MVP后的坐标)
			if(_lightMapTexture==null)
			{
				_passCode += "mov v0, vt1";		// 无需UV
			}
			else
			{
				_passCode += 	"mov v0, vt1\n"+		// v0位置
								"mov v1, va1\n";		// 用va1保存UV
			}
			
			code = code + _passCode;
			return code;
		}
		// fragment shader 代码
		arcane override function getFragmentCode() : String
		{
			if(_lightMapTexture==null)
				return "mov oc, fc0.z\n";	// 没有贴图就渲染一个固定值
			
			return "tex ft0, v1, fs0 <2d, linear, clamp>\n" +		// 贴图采样
					"mul ft0, ft0, fc1\n" +							// 乘以颜色值
					"mul ft0, ft0, fc0.y\n" +						// 乘以光照强度
					"mov oc, ft0\n";
		}
		
		arcane override function render(renderable : IRenderable, stage3DProxy : Stage3DProxy, camera : Camera3D, lightPicker : LightPickerBase) : void
		{
			if(_lightMapTexture)
			{	// uvBuffer填入va1
				stage3DProxy.setSimpleVertexBuffer(1, renderable.getUVBuffer(stage3DProxy), Context3DVertexBufferFormat.FLOAT_2);
			}
			
			super.render(renderable, stage3DProxy, camera, lightPicker);			
		}		
		
		arcane override function activate(stage3DProxy : Stage3DProxy, camera : Camera3D, textureRatioX : Number, textureRatioY : Number) : void
		{
			super.activate(stage3DProxy, camera, textureRatioX, textureRatioY);
			
			// 常量寄存器
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _constVector, 1);
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, _constClrVector, 1);
			if(_lightMapTexture)
			{	// 设置贴图寄存器
				stage3DProxy.setTextureAt(0, _lightMapTexture.getTextureForStage3D(stage3DProxy));
			}
		}
		
		arcane override function deactivate(stage3DProxy : Stage3DProxy) : void
		{
			super.deactivate(stage3DProxy);
		}
			
	}	// class
} // package
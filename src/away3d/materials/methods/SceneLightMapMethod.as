package away3d.materials.methods
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.Debug;
	import away3d.lights.LightBase;
	import away3d.materials.utils.ShaderRegisterCache;
	import away3d.materials.utils.ShaderRegisterElement;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	
	use namespace arcane;
	
	public class SceneLightMapMethod extends ShadingMethodBase
	{
		private var _castingLight : LightBase;
		private var _projMatrix : Matrix3D = new Matrix3D();
		// 寄存器相关
		
		private var _lightMapVar : ShaderRegisterElement;
		
		
		public function SceneLightMapMethod(castingLight : LightBase)
		{
			super();		
			castingLight.castsLightMap = true;
			_castingLight = castingLight;
		}
		
		override arcane function initVO(vo : MethodVO) : void
		{
		}
		
		override arcane function initConstants(vo : MethodVO) : void
		{
			var fragmentData : Vector.<Number> = vo.fragmentData;
			var vertexData : Vector.<Number> = vo.vertexData;
			
			var index : int = vo.fragmentConstantsIndex;
			// 保留
			fragmentData[index] = 0.0;
			fragmentData[index+1] = 0.0;
			fragmentData[index+2] = 0.0;
			fragmentData[index+3] = 0.0;
			
			fragmentData[index+6] = -0.0003;
			fragmentData[index+7] = 0.0;
			fragmentData[index+6] = 0.2;		// z 为变黑的程度
			fragmentData[index+7] = 1.0;
			
			index = vo.vertexConstantsIndex;
			if (index != -1) 
			{
				vertexData[index] = .5;				// 计算uv转换用常量
				vertexData[index + 1] = -.5;
				vertexData[index + 2] = 1.0;
				vertexData[index + 3] = 1.0;
			}
		}
		
		// 获取VertexShader代码
		arcane override function getVertexCode(vo : MethodVO, regCache : ShaderRegisterCache) : String
		{
			// 使用一个常量寄存器(保存变换到贴图空间的常量)
			var toTexReg : ShaderRegisterElement = regCache.getFreeVertexConstant();
			// 使用4个常量寄存器(保存投影矩阵)
			var lightMapProj : ShaderRegisterElement = regCache.getFreeVertexConstant();
			regCache.getFreeVertexConstant();
			regCache.getFreeVertexConstant();
			regCache.getFreeVertexConstant();
			
			vo.vertexConstantsIndex = (toTexReg.index-vo.vertexConstantsOffset)*4;
			// 一个暂存寄存器
			var temp : ShaderRegisterElement = regCache.getFreeVertexVectorTemp();
			// 一个varying寄存器
			_lightMapVar = regCache.getFreeVarying();
			
			
			var code : String = "";
			code += "m44 " + temp + ", vt0, " + lightMapProj + "\n" +
				"rcp " + temp+".w, " + temp+".w\n" +
				"mul " + temp+".xyz, " + temp+".xyz, " + temp+".w\n" +
				"mul " + temp+".xy, " + temp+".xy, " + toTexReg+".xy\n" +
				"add " + temp+".xy, " + temp+".xy, " + toTexReg+".xx\n" +
				"mov " + _lightMapVar+".xyz, " + temp+".xyz\n" +
				"mov " + _lightMapVar+".w, va0.w\n";
			return code;
		}
		// 获取FregmentShader代码
		arcane function getFragmentCode(vo : MethodVO, regCache : ShaderRegisterCache, targetReg : ShaderRegisterElement) : String
		{
			// 使用一个贴图寄存器
			var lightMapRegister : ShaderRegisterElement = regCache.getFreeTextureReg();	
			// 使用2个常量寄存取
			var constReg1 : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var constReg2 : ShaderRegisterElement = regCache.getFreeFragmentConstant();	
			// 使用一个暂存寄存器
			var tempReg : ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			
			vo.fragmentConstantsIndex = constReg1.index*4;
			vo.texturesIndex = lightMapRegister.index;
			
			var code : String = "";
			code += "tex " + tempReg + ", " + _lightMapVar + ", " + lightMapRegister + " <2d, linear, repeat>\n" +
					"mov " + targetReg + ", " + tempReg + "\n";
				
//			if(blGameConfig.debugMode != blNumbers.debug_final)
			if(true)
			{
					// 超出lightmap投影范围的地方变黑些,以做调试用
				code += "sge " + tempReg+".x, " + _lightMapVar +".x, " + constReg2+".w\n" +
					"mul " + tempReg+".y, " + tempReg+".x, " + constReg2+".z\n" +
					"sub " + targetReg + ", " +  targetReg+", " + tempReg+".y\n" +
					
					"slt " + tempReg+".x, " + _lightMapVar +".x, " + constReg2+".y\n" +
					"mul " + tempReg+".y, " + tempReg+".x, " + constReg2+".z\n" +
					"sub " + targetReg + ", " +  targetReg+", " + tempReg+".y\n" +
					
					"sge " + tempReg+".x, " + _lightMapVar +".y, " + constReg2+".w\n" +
					"mul " + tempReg+".y, " + tempReg+".x, " + constReg2+".z\n" +
					"sub " + targetReg + ", " +  targetReg+", " + tempReg+".y\n" +
					
					"slt " + tempReg+".x, " + _lightMapVar +".y, " + constReg2+".y\n" +
					"mul " + tempReg+".y, " + tempReg+".x, " + constReg2+".z\n" +
					"sub " + targetReg + ", " +  targetReg+", " + tempReg+".y\n";
			}

			return code;	
		}
		
		arcane override function setRenderState(vo : MethodVO, renderable : IRenderable, stage3DProxy : Stage3DProxy, camera : Camera3D) : void
		{
			// _projMatrix 使物体由local空间,变换到lightmap的投影camera空间
			_projMatrix.copyFrom(_castingLight.lightMapper.lightProjection);
			_projMatrix.prepend(renderable.sceneTransform);
			_projMatrix.copyRawDataTo(vo.vertexData, vo.vertexConstantsIndex + 4, true);
			
		}
		
		arcane override function activate(vo : MethodVO, stage3DProxy : Stage3DProxy) : void
		{
			// 设置lightmap
			stage3DProxy.setTextureAt(vo.texturesIndex, _castingLight.lightMapper.lightMap.getTextureForStage3D(stage3DProxy));			
		}
		
		arcane override function deactivate(vo : MethodVO, stage3DProxy : Stage3DProxy) : void
		{			
		}
	}
	
} // package
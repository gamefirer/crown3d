/**
 *		地表渲染方法(4层纹理)
 */
package away3d.materials.methods
{
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.utils.DefaultMaterialManager;
	import away3d.materials.utils.ShaderRegisterCache;
	import away3d.materials.utils.ShaderRegisterElement;
	import away3d.textures.BitmapTexture;
	import away3d.textures.BitmapTextureCache;
	import away3d.textures.TextureProxyBase;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;

	use namespace arcane;
	
	public class TerrainDiffuseMethod2 extends BasicDiffuseMethod
	{
		private var _blendBitmap : BitmapData;
		private var _blendingTexture : BitmapTexture;	// 混合贴图
		
		private var _layerBitmaps : Vector.<BitmapData>;
		private var _layerTextures : Vector.<BitmapTexture>;
		
		private var _uvScale : Number = 10;
		
		public function TerrainDiffuseMethod2()
		{
			super();
		
			_customTextureCode = terrainTextureCode;
			
			_blendBitmap = DefaultMaterialManager.getDefaultBitmapData();
			
			_layerBitmaps = new Vector.<BitmapData>(4, true);
			_layerTextures = new Vector.<BitmapTexture>(4, true);
			for(var i:int=0; i<4; i++)
			{
				_layerBitmaps[i] = DefaultMaterialManager.getDefaultBitmapData();
			}
			
		}
		
		override arcane function initVO(vo : MethodVO) : void
		{
			super.initVO(vo);
			
			vo.needsUV = true;
			vo.repeatTextures = true;
		}
		
		override arcane function initConstants(vo : MethodVO) : void
		{
			super.initConstants(vo);
			var fragmentData : Vector.<Number> = vo.fragmentData;
			
			var index : int = vo.fragmentConstantsIndex;
			// x 层纹理的uv缩放 ; y 常数1;  z ?; w ?
			fragmentData[index+4] = _uvScale;		// 地形计算用
			fragmentData[index+5] = 1;
			fragmentData[index+6] = 1;
			fragmentData[index+7] = 1;
			
		}
		
		// 设置UV倍数
		public function setUVScale(uvScale:Number) : void
		{
			_uvScale = uvScale;
		}
		
		// 设置地表纹理(0:为默认层 1:red 2:green 3:blue)
		public function setTextureLayer(layer:int, bm:BitmapData) : void
		{
			_layerBitmaps[layer] = bm;
		}
		
		// 设置混合图
		public function setTerrainBlendTextrue(bm:BitmapData) : void
		{
			_blendBitmap = bm;
			
			if (_blendingTexture)
			{
				BitmapTextureCache.instance().freeTexture(_blendingTexture);
				_blendingTexture = null;
			}
		}
		
		private function terrainTextureCode(vo : MethodVO, regCache : ShaderRegisterCache, targetReg : ShaderRegisterElement) : String
		{
			var code : String = "";
			// 暂存寄存器(只有两个可用了)
			var temp1 : ShaderRegisterElement;
			var temp2 : ShaderRegisterElement;
			temp1 = regCache.getFreeFragmentVectorTemp();
			regCache.addFragmentTempUsages(temp1, 1);
			temp2 = regCache.getFreeFragmentVectorTemp();
			regCache.addFragmentTempUsages(temp2, 1);
			
			var terrainDataReg : ShaderRegisterElement;
			terrainDataReg = regCache.getFreeFragmentConstant();	// 记得+4
			
			// 地表纹理渲染
			var blendTexReg : ShaderRegisterElement = regCache.getFreeTextureReg();
			var layerTexReg1 : ShaderRegisterElement = regCache.getFreeTextureReg();
			var layerTexReg2 : ShaderRegisterElement = regCache.getFreeTextureReg();
			var layerTexReg3 : ShaderRegisterElement = regCache.getFreeTextureReg();
			var layerTexReg4 : ShaderRegisterElement = regCache.getFreeTextureReg();
			vo.texturesIndex = blendTexReg.index;
			vo.secondaryTexturesIndex = layerTexReg1.index;
			vo.thirdlyTexturesIndex = layerTexReg2.index;
			vo.fourthTexturesIndex = layerTexReg3.index;
			vo.fifthTexturesIndex = layerTexReg4.index;
			
			// 混合图
			code += getTexSampleCode(vo, temp1, blendTexReg); 	// 获取混合贴图->temp1
			// 通道颜色值求和，归一化
			code +=
				"add " + temp2 + ".x, " + temp1 + ".x, " + temp1 + ".y\n" +
				"add " + temp2 + ".x, " + temp2 + ".x, " + temp1 + ".z\n" +					// temp2.x = r+g+b
				"sub " + temp2 + ".y, " + terrainDataReg + ".y, " + temp2 + ".x\n" +			// temp2.y = 1 - temp2.x
				"sat " + temp1 + ".w, " + temp2 + ".y\n" +
				"add " + temp2 + ".x, " + temp2 + ".x, " + temp1 + ".w\n" +					// temp2.x >= 1
				
				"div " + temp1 + ".x, " + temp1 + ".x, " + temp2 + ".x\n" +					// r g b 归一化
				"div " + temp1 + ".y, " + temp1 + ".y, " + temp2 + ".x\n" +
				"div " + temp1 + ".z, " + temp1 + ".z, " + temp2 + ".x\n";					// temp1 为混合值
			
			// 第一层
			code +=
				"mov " + temp2 + ", " + _uvFragmentReg + "\n"  +
				"mul " + temp2 + ", " + temp2 + ", " + terrainDataReg + ".x\n";
			code +=	getTexSampleCode(vo, temp2, layerTexReg1, temp2);
			code +=
				"mul " + temp2 + ",  " + temp1 + ".w, " + temp2 + "\n" +
				"mov " + targetReg + ", " + temp2 + "\n";
			// 第二层
			code += 
				"mov " + temp2 + ", " + _uvFragmentReg + "\n"  +
				"mul " + temp2 + ", " + temp2 + ", " + terrainDataReg + ".x\n";
			code +=	getTexSampleCode(vo, temp2, layerTexReg2, temp2);
			code +=
				"mul " + temp2 + ",  " + temp1 + ".x, " + temp2 + "\n" +
				"add " + targetReg + ", " + targetReg + ", " + temp2 + "\n";
			
			// 第三层
			code += 
				"mov " + temp2 + ", " + _uvFragmentReg + "\n"  +
				"mul " + temp2 + ", " + temp2 + ", " + terrainDataReg + ".x\n";
			code += getTexSampleCode(vo, temp2, layerTexReg3, temp2);
			code +=
				"mul " + temp2 + ",  " + temp1 + ".y, " + temp2 + "\n" +
				"add " + targetReg + ", " + targetReg + ", " + temp2 + "\n";
			// 第四层
			code += 
				"mov " + temp2 + ", " + _uvFragmentReg + "\n"  +
				"mul " + temp2 + ", " + temp2 + ", " + terrainDataReg + ".x\n";
			code += getTexSampleCode(vo, temp2, layerTexReg4, temp2);
			code +=
				"mul " + temp2 + ",  " + temp1 + ".z, " + temp2 + "\n" +
				"add " + targetReg + ", " + targetReg + ", " + temp2 + "\n";
			
			regCache.removeFragmentTempUsage(temp2);
			regCache.removeFragmentTempUsage(temp1);
			return code;
		}
		
		arcane override function activate(vo : MethodVO, stage3DProxy : Stage3DProxy) : void
		{
			super.activate(vo, stage3DProxy);
			var context : Context3D = stage3DProxy._context3D;
			
			vo.fragmentData[vo.fragmentConstantsIndex+4] = _uvScale;
			// 混合图
			if(!_blendingTexture)
				_blendingTexture = BitmapTextureCache.instance().getTexture(_blendBitmap);
			stage3DProxy.setTextureAt(vo.texturesIndex, _blendingTexture.getTextureForStage3D(stage3DProxy));

			// 四层纹理图
			for(var i:int=0; i<4; i++)
			{
				if(!_layerTextures[i] )
					_layerTextures[i] = BitmapTextureCache.instance().getTexture(_layerBitmaps[i]);
				
				if(i==0)
					stage3DProxy.setTextureAt(vo.secondaryTexturesIndex, _layerTextures[i].getTextureForStage3D(stage3DProxy));
				else if(i==1)
					stage3DProxy.setTextureAt(vo.thirdlyTexturesIndex, _layerTextures[i].getTextureForStage3D(stage3DProxy));
				else if(i==2)
					stage3DProxy.setTextureAt(vo.fourthTexturesIndex, _layerTextures[i].getTextureForStage3D(stage3DProxy));
				else if(i==3)
					stage3DProxy.setTextureAt(vo.fifthTexturesIndex, _layerTextures[i].getTextureForStage3D(stage3DProxy));
			}
			
		}
		
		override public function dispose() : void
		{
			super.dispose();
			if (_blendingTexture)
			{
				BitmapTextureCache.instance().freeTexture(_blendingTexture);
				_blendingTexture = null;
			}
			for(var i:int=0; i<4; i++)
			{
				if (_layerTextures[i])
				{
					BitmapTextureCache.instance().freeTexture(_layerTextures[i]);
					_layerTextures[i] = null;
				}
			}
		}
		
//		override public function invalidateBitmapData() : void
//		{
//			super.invalidateBitmapData();
//			if(_blendingTexture)
//				_blendingTexture.invalidateContent();
//			for(var i:int=0; i<4; i++)
//			{
//				if (_layerTextures[i])
//				{
//					_layerTextures[i].invalidateContent();
//				}
//			}
//		}
		
		arcane override function reset() : void
		{
			super.reset();
			
//			_terrainDataIndex = -1;
//			_blendingTextureIndex = -1;
//			for(var i:int=0; i<4; i++)
//			{
//				_layerTexturesIndex[i] = -1;
//			}
		}
		
		
	}
}
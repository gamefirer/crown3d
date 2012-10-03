/**
 *	处理顶点色的渲染方法 
 */
package away3d.materials.methods
{
	import away3d.arcane;
	import away3d.materials.utils.ShaderRegisterCache;
	import away3d.materials.utils.ShaderRegisterElement;
	
	use namespace arcane;
	
	public class BasicColorMethod extends ShadingMethodBase
	{
		public function BasicColorMethod()
		{
			super();
		}
		
		override arcane function initVO(vo : MethodVO) : void
		{
			vo.needsColor = true;
		}
		
		override arcane function initConstants(vo : MethodVO) : void
		{
		}
		
		
		arcane function getFragmentCode(vo : MethodVO, regCache : ShaderRegisterCache, targetReg : ShaderRegisterElement) : String
		{
			return "mul " + targetReg + ", " + targetReg + ", " + _colorFragmentReg + "\n";
//			return "";
		}
		

		
		
	}
}
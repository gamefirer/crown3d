/**
 *	模型数据 
 */
package blade3d.scene.loadvo
{
	import away3d.core.math.Quaternion;
	
	import flash.geom.Vector3D;

	public class MeshVO
	{
		public var path : String;
		public var pos : Vector3D;
		public var rot : Quaternion;
		public var scale : Vector3D;
		
		public var hasVertexColor : Boolean = false;	// 是否有顶点色文件
		
		public var isBlend : Boolean = false;		// 是否透明
		public var IsTwoSide : Boolean = false;	// 是否双面渲染
		public var zBias : Number = 0;
		public var isCastShadow : Boolean = false;	// 是否接受阴影
		public var isRecvTexLight : Boolean = true;	// 是否接受贴图灯
		public var writeZ : Boolean = true;
		public var testZ : Boolean = true;
		
		public var isTerrainTexture : Boolean = false;	// 是否使用地表材质
		public var mixTextureName : String;
		public var terrainTextureName1 : String;
		public var terrainTextureName2 : String;
		public var terrainTextureName3 : String;
		public var terrainTextureName4 : String;
		public var uvScale : Number = 1;
		
	}
}
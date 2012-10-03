package blade3d.scene
{
	import away3d.core.base.SubGeometry;
	import away3d.debug.Debug;
	import away3d.entities.Mesh;
	
	import blade3d.resource.BlBinaryResource;
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceManager;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class BlVertexColorLoader
	{
		private var _callback : Function;
		private var _targetMesh : Mesh;
		
		public function BlVertexColorLoader()
		{
		}
		
		public function startLoad(mesh:Mesh, vcUrl:String, callback:Function):void
		{
			_targetMesh = mesh;
			_callback = callback;
			var vcRes:BlResource = BlResourceManager.instance().findBinaryResource(vcUrl);
			vcRes.asycLoad(onVertexColor);
		}
		
		private function onVertexColor(res:BlResource):void
		{
			Debug.assert(res is BlBinaryResource, "vertex color file error");
			var vcData : ByteArray = BlBinaryResource(res).ba;
			
			vcData.position = 0;
			vcData.endian = Endian.LITTLE_ENDIAN;
			var version : int = vcData.readUnsignedInt();
			if(version == 1)
			{
				readVertexDataVersion1(vcData);
			}
			else if(version == 2)
			{
				readVertexDataVersion2(vcData);
			}
		}
		
		private function readVertexDataVersion2(mesh_Data : ByteArray) : void
		{
			var subGeo : SubGeometry = _targetMesh.geometry.subGeometries[0];
			if(subGeo)
			{
				var vcNum : int = mesh_Data.readUnsignedInt();		// 顶点色引索数
				// 读取颜色引索
				var vertexColorIndices : Vector.<int> = new Vector.<int>;
				var clrIndex : int;
				for(var cii:int = 0; cii < vcNum; cii++)
				{
					clrIndex = mesh_Data.readUnsignedShort();
					vertexColorIndices.push(clrIndex);
				}
				
				var clrNum : int = mesh_Data.readUnsignedInt();		// 颜色数
				var vertexColors : Vector.<Number> = new Vector.<Number>;
				var r : int;
				var g : int;
				var b : int;
				for(var ci:int = 0; ci < clrNum; ci++)
				{
					r = mesh_Data.readUnsignedByte();
					g = mesh_Data.readUnsignedByte();
					b = mesh_Data.readUnsignedByte();
					vertexColors.push(Number(r)/0xff);
					vertexColors.push(Number(g)/0xff);
					vertexColors.push(Number(b)/0xff);					
				}
				
				Debug.assert(vertexColorIndices.length == subGeo.indexData.length);
				
				// 写入顶点色到Geo中
				var index:int;
				clrIndex = 0;
				var vertexColorData : Vector.<Number> = new Vector.<Number>(subGeo.numVertices*4, true);
				for(var fi:int=0; fi<subGeo.indexData.length/3; fi++)
				{
					// 顶点1
					index = subGeo.indexData[fi*3];
					clrIndex = vertexColorIndices[fi*3+2];
					vertexColorData[index*4] = vertexColors[clrIndex*3];
					vertexColorData[index*4+1] = vertexColors[clrIndex*3+1];
					vertexColorData[index*4+2] = vertexColors[clrIndex*3+2];
					vertexColorData[index*4+3] = 1;
					//					r = vertexColors[clrIndex*3]*0xff;
					//					g = vertexColors[clrIndex*3+1]*0xff;
					//					b = vertexColors[clrIndex*3+2]*0xff;
					//					Debug.bltrace((fi+1)+" "+clrIndex+" ("+r+","+g+","+b+")");
					// 顶点2
					index = subGeo.indexData[fi*3+1];
					clrIndex = vertexColorIndices[fi*3+1];
					vertexColorData[index*4] = vertexColors[clrIndex*3];
					vertexColorData[index*4+1] = vertexColors[clrIndex*3+1];
					vertexColorData[index*4+2] = vertexColors[clrIndex*3+2];
					vertexColorData[index*4+3] = 1;
					//					r = vertexColors[clrIndex*3]*0xff;
					//					g = vertexColors[clrIndex*3+1]*0xff;
					//					b = vertexColors[clrIndex*3+2]*0xff;
					//					Debug.bltrace((fi+1)+" "+clrIndex+" ("+r+","+g+","+b+")");
					// 顶点3
					index = subGeo.indexData[fi*3+2];
					clrIndex = vertexColorIndices[fi*3];
					vertexColorData[index*4] = vertexColors[clrIndex*3];
					vertexColorData[index*4+1] = vertexColors[clrIndex*3+1];
					vertexColorData[index*4+2] = vertexColors[clrIndex*3+2];
					vertexColorData[index*4+3] = 1;
					//					r = vertexColors[clrIndex*3]*0xff;
					//					g = vertexColors[clrIndex*3+1]*0xff;
					//					b = vertexColors[clrIndex*3+2]*0xff;
					//					Debug.bltrace((fi+1)+" "+clrIndex+" ("+r+","+g+","+b+")");
				}
				
				subGeo.updateVertexColorData(vertexColorData);
			}
			
			_callback(_targetMesh);
		}
		
		private function readVertexDataVersion1(mesh_Data : ByteArray) : void
		{
			var vcNum : int = mesh_Data.readUnsignedInt();
			
			var subGeo : SubGeometry = _targetMesh.geometry.subGeometries[0];
			if(subGeo)
			{
				// 读取顶点色数据			
				var vertexColors : Vector.<Number> = new Vector.<Number>;
				var r : int;
				var g : int;
				var b : int;
				for(var ci:int = 0; ci < vcNum; ci++)
				{
					r = mesh_Data.readUnsignedByte();
					g = mesh_Data.readUnsignedByte();
					b = mesh_Data.readUnsignedByte();
					vertexColors.push(Number(r)/0xff);
					vertexColors.push(Number(g)/0xff);
					vertexColors.push(Number(b)/0xff);					
				}
				
				Debug.assert(vertexColors.length/3 == subGeo.indexData.length);
				
				var index:int;
				var vertexColorData : Vector.<Number> = new Vector.<Number>(subGeo.numVertices*4, true);
				for(var fi:int=0; fi<subGeo.indexData.length/3; fi++)
				{
					// 顶点1
					index = subGeo.indexData[fi*3];
					vertexColorData[index*4] = vertexColors[(fi*3+2)*3];
					vertexColorData[index*4+1] = vertexColors[(fi*3+2)*3+1];
					vertexColorData[index*4+2] = vertexColors[(fi*3+2)*3+2];
					vertexColorData[index*4+3] = 1;
					// 顶点2
					index = subGeo.indexData[fi*3+1];
					vertexColorData[index*4] = vertexColors[(fi*3+1)*3];
					vertexColorData[index*4+1] = vertexColors[(fi*3+1)*3+1];
					vertexColorData[index*4+2] = vertexColors[(fi*3+1)*3+2];
					vertexColorData[index*4+3] = 1;
					// 顶点3
					index = subGeo.indexData[fi*3+2];
					vertexColorData[index*4] = vertexColors[(fi*3)*3];
					vertexColorData[index*4+1] = vertexColors[(fi*3)*3+1];
					vertexColorData[index*4+2] = vertexColors[(fi*3)*3+2];
					vertexColorData[index*4+3] = 1;
				}
				
				subGeo.updateVertexColorData(vertexColorData);
			}
			
			_callback(_targetMesh);
		}
	}
}
package blade3d.scene.terrain
{
	import away3d.cameras.Camera3D;
	import away3d.core.base.SubGeometry;
	import away3d.debug.Debug;
	import away3d.tools.utils.Ray;
	
	import blade3d.BlEngine;
	import blade3d.camera.BlCameraManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	// 做地形碰撞检测用的对象	
	public class blTerrainMesh
	{
		private var _maxTrianglesPerCell:int;			// 一个Cell中最多几个三角
		private var _minCellSize:Number;
		
		private var _quadTree : blTerrainQuadTree;			// 四叉树
			
		private var _collisionTriangles:Vector.<uint> = new Vector.<uint>();		// 碰撞到的三角
		private var _segBox : blTAABox = new blTAABox;			// 碰撞检测用aabb
		private var _ray : Ray = new Ray;					// 碰撞检测用射线
		
		// terrain map相关
		private var _terrainBmp : BitmapData;				// terrain map
		private var _terrainBmpWidth : int;
		private var _terrainBmpHeight : int;
		private const _terrainCellSize : int = 100;
		
		public function get terrainBmp() : BitmapData {return _terrainBmp;}
		
		public function blTerrainMesh(geo:SubGeometry, maxTrianglesPerCell:int = 10, minCellSize:Number = 500)
		{
			
			_maxTrianglesPerCell = maxTrianglesPerCell;
			_minCellSize = minCellSize;
			
			if(geo)
			{
				createMesh(geo);
			}
		}
		// 创建地形Mesh
		private function createMesh(geo:SubGeometry):void 
		{			
			// 创建并构造四叉树
			_quadTree = new blTerrainQuadTree();
			_quadTree.addTriangles(geo);
			_quadTree.buildQuadTree(_maxTrianglesPerCell, _minCellSize);
			
			_terrainBmpWidth = Math.max(_quadTree.boundingBox.sideX/_terrainCellSize, 1);
			_terrainBmpHeight = Math.max(_quadTree.boundingBox.sideY/_terrainCellSize, 1);
			_terrainBmp = new BitmapData(_terrainBmpWidth, _terrainBmpHeight, false, 0);
		}
		
		private var retPoint :Vector3D = new Vector3D;
		public function ScreenPointToTerrain(x:Number, y:Number, noNull : Boolean = false) : Vector3D
		{
			//Debug.bltrace("1: " + x + " 	 " + y);
			
			x = (x * 2 - BlEngine.getStageWidth()) / BlEngine.getStageWidth();
			y = (y * 2 - BlEngine.getStageHeight()) / BlEngine.getStageHeight();
			//Debug.bltrace("2: " + x + " " + y);
			// 获得一个镜头方向的向量
			var cam : Camera3D = BlCameraManager.instance().currentCamera.camera;
			var unprojV : Vector3D = cam.lens.unproject(x,y,0);
			var rayDir : Vector3D = cam.sceneTransform.deltaTransformVector(unprojV);
			rayDir.normalize();
			//Debug.bltrace("rayDir " + rayDir.x.toFixed(2) + " " + rayDir.y.toFixed(2) + " " + rayDir.z.toFixed(2));
			
			// 屏幕点,对应的射线
			var nearPoint : Vector3D = BlCameraManager.instance().currentCamera.camera.scenePosition;
			var farPoint : Vector3D = new Vector3D;
			farPoint = rayDir;
			farPoint.scaleBy(10000);	// 最远拾取距离
			farPoint = farPoint.add(nearPoint);
			
			// 创建一个射线的boundingbox
			_segBox.clear();
			_segBox.addPoint(nearPoint);
			_segBox.addPoint(farPoint);
			//Debug.bltrace("nearPoint " + nearPoint.x.toFixed(2) + " " + nearPoint.y.toFixed(2) + " " + nearPoint.z.toFixed(2));
			//Debug.bltrace("farPoint " + farPoint.x.toFixed(2) + " " + farPoint.y.toFixed(2) + " " + farPoint.z.toFixed(2));
			
			// 获取Boundingbox中的三角
			_collisionTriangles.length = 0;
			var numTriangles : uint = _quadTree.getTrianglesIntersectingtAABox(_collisionTriangles, _segBox);
			
			// 检查那个三角与点(x,y)相交
			var findCount : int = 0;		
			for(var i:uint=0; i<_collisionTriangles.length; i++)
			{
				var meshTriangle : blTIndexedTriangle = _quadTree.getTriangle(_collisionTriangles[i]);
			
				var p1 : Vector3D = _quadTree.getVertex(meshTriangle.getVertexIndex(0));
				var p2 : Vector3D = _quadTree.getVertex(meshTriangle.getVertexIndex(1));
				var p3 : Vector3D = _quadTree.getVertex(meshTriangle.getVertexIndex(2));
				
				var intersectP : Vector3D = _ray.getIntersectWithTriangle(nearPoint, farPoint, p1, p2, p3);
				if(intersectP)
				{
//					return 	intersectP;
//					Debug.bltrace("intersect " + _collisionTriangles[i] + " " + intersectP.x.toFixed(2) + " " + intersectP.y.toFixed(2) + " " + intersectP.z.toFixed(2));
					if(findCount == 0)
					{	
						retPoint.copyFrom(intersectP);
					}
					else
					{
						// 取最近的点
						var d1 : Number = Vector3D.distance(nearPoint, intersectP);
						var d2 : Number = Vector3D.distance(nearPoint, retPoint);
						if(d1 < d2)
							retPoint.copyFrom(intersectP);
					}
					
					findCount++;
//					Debug.bltrace("nearestIntersectP " + retPoint.x.toFixed(2) + " " + retPoint.y.toFixed(2) + " " + retPoint.z.toFixed(2));
				}				
			}
			
			if(findCount > 0)
			{
//				Debug.bltrace("findCount="+findCount);
				return retPoint;
			}
			else if(noNull)
			{
				// 如果点击到了地形的外面,就返回y=0的那个点
				if( nearPoint.y * farPoint.y < 0 )
				{
					// 用 rayDir 作为返回值
					rayDir.x = (0 - nearPoint.y) / (farPoint.y - nearPoint.y) * (farPoint.x - nearPoint.x) + nearPoint.x;
					rayDir.z = (0 - nearPoint.y) / (farPoint.y - nearPoint.y) * (farPoint.z - nearPoint.z) + nearPoint.z;
					rayDir.y = 0;
					return rayDir;
				}
				else
					return farPoint;
			}
			else			
				return null;
		}
		
		public function isInTerrain(x:Number, y:Number) : Boolean
		{
			x = x - _quadTree.boundingBox.minPosX;
			y = _quadTree.boundingBox.maxPosY - y;
			
			if(x >= _quadTree.boundingBox.sideX || y >= _quadTree.boundingBox.sideY || x < 0 || y < 0)
				return false;
			
			return true;
		}
		
		public function GetTerrainHeight(x:Number, y:Number) : Number
		{
			//return GetTerrainMeshHeight(x, y);
			x = x - _quadTree.boundingBox.minPosX;
			y = _quadTree.boundingBox.maxPosY - y;
			
			if(x >= _quadTree.boundingBox.sideX || y >= _quadTree.boundingBox.sideY || x < 0 || y < 0)
				return 0;
			
			var l : int = x/_terrainCellSize;
			var b : int = y/_terrainCellSize;
			var proX : Number = x%_terrainCellSize / _terrainCellSize;
			var proY : Number = y%_terrainCellSize / _terrainCellSize;
			
			// 四点插值
			var hlb : Number = GetTerrainMapHeight(l, b);
			var hrb : Number = GetTerrainMapHeight(l+1, b);
			var hlt : Number = GetTerrainMapHeight(l, b+1);
			var hrt : Number = GetTerrainMapHeight(l+1, b+1);
			
			return (hlb * (1-proX) + hrb * proX) * (1-proY) + (hlt * (1-proX) + hrt * proX) * proY;
		}
		
		public function GetTerrainMapHeight(x : uint, y : uint) : Number
		{
			var height : Number = 0;
			var clr : uint = _terrainBmp.getPixel(x, y);
			if(clr == 0)
			{
				var realX:Number = x*_terrainCellSize +  _quadTree.boundingBox.minPosX;
				var realY:Number = _quadTree.boundingBox.maxPosY - y*_terrainCellSize;
				height = GetTerrainMeshHeight(realX, realY);
				if(height >= _quadTree.minY)
					clr = (height - _quadTree.minY) /  (_quadTree.maxY - _quadTree.minY) * 0xfffffe + 1;
				else
					clr = 1;
				_terrainBmp.setPixel(x, y, clr);
//				Debug.bltrace( "x:" + realX.toFixed(2) + " y:" + realY.toFixed(2) + " height=" + height.toFixed(2));
			}
			else
			{
				height =(clr-1) * (_quadTree.maxY - _quadTree.minY) / 0xfffffe + _quadTree.minY;
			}
			return height;
		}
		// 判断点在三角型中
		public static function PointInTriangle(x:Number, y:Number, triP1:Vector3D, triP2:Vector3D, triP3:Vector3D) : Boolean
		{
			var p1 : Vector3D = triP1;
			var p2 : Vector3D = triP2;
			var p3 : Vector3D = triP3;
			
			// 直线方程p1-p2
			var A1 : Number = p1.z - p2.z;
			var B1 : Number = p2.x - p1.x;
			var C1 : Number = p1.x * p2.z - p2.x * p1.z;
			// 直线方程p2-p3
			var A2 : Number = p2.z - p3.z;
			var B2 : Number = p3.x - p2.x;
			var C2 : Number = p2.x * p3.z - p3.x * p2.z;
			// 直线方程p3-p1
			var A3 : Number = p3.z - p1.z;
			var B3 : Number = p1.x - p3.x;
			var C3 : Number = p3.x * p1.z - p1.x * p3.z;
			
			var isInTri : Boolean = false;
			var D1 : Number = A1*x+B1*y+C1;
			var D2 : Number = A2*x+B2*y+C2;
			var D3 : Number = A3*x+B3*y+C3;
			
			const Tiny : Number = 0.01;
			if( (D1 >= -Tiny && D2 >= -Tiny && D3 >= -Tiny) || (D1 <= Tiny && D2 <= Tiny && D3 <= Tiny) )
				isInTri = true;
			
			return isInTri;
		}
		
		// 获得某位置的地形高度
		private function GetTerrainMeshHeight(x : Number, y : Number) : Number
		{
			//x = 763.40;
			//y = -43.99;
			_collisionTriangles.length = 0;
			
			_segBox.SetAABox(x, y, 20, 20);
			var numTriangles : uint = _quadTree.getTrianglesIntersectingtAABox(_collisionTriangles, _segBox);
			// 检查那个三角与点(x,y)相交
			for(var i:uint=0; i<_collisionTriangles.length; i++)
			{
				var meshTriangle : blTIndexedTriangle = _quadTree.getTriangle(_collisionTriangles[i]);
			
				var p1 : Vector3D = _quadTree.getVertex(meshTriangle.getVertexIndex(0));
				var p2 : Vector3D = _quadTree.getVertex(meshTriangle.getVertexIndex(1));
				var p3 : Vector3D = _quadTree.getVertex(meshTriangle.getVertexIndex(2));
				
				var isInTri : Boolean = PointInTriangle(x, y, p1, p2, p3);
								
				if(!isInTri)
				{
					_collisionTriangles.splice(i, 1);
					i--;
				}
			}
			
			//Debug.bltrace("x=" + x.toFixed(2) + " y=" + y.toFixed(2) + " numTri=" + numTriangles + " Tri2=" + _collisionTriangles.length);
			numTriangles = _collisionTriangles.length;
			
			if(numTriangles > 0)
			{
				// 取最高的那个位置
				var maxHeight : Number = -100000;
				for(i=0;i<_collisionTriangles.length;i++)
				{
					var inTriangle : blTIndexedTriangle = _quadTree.getTriangle(_collisionTriangles[i]);
					var height : Number = getHeightInTriangle(x, y, inTriangle);
					if(height > maxHeight)
						maxHeight = height;
				}
				//Debug.bltrace("height" + maxHeight.toFixed(2));
				return maxHeight;
			}
			else
				return 0;
		}
		
		private function getHeightInTriangle(x : Number, y : Number, tri : blTIndexedTriangle) : Number
		{
			var meshTriangle : blTIndexedTriangle = tri;
				
			var p1 : Vector3D = _quadTree.getVertex(meshTriangle.getVertexIndex(0));
			var p2 : Vector3D = _quadTree.getVertex(meshTriangle.getVertexIndex(1));
			var p3 : Vector3D = _quadTree.getVertex(meshTriangle.getVertexIndex(2));
			
			// 计算(x,y)在三角面(p1,p2,p3)上的位置
			var tmp : Vector3D = new Vector3D;
			// p1.x >= p2.x >= x >= p3.x || p1.x <= p2.x <= x <= p3.x
			if(p1.x >= x)
			{
				if(p3.x >= x)
				{
					tmp = p3; p3 = p2; p2 = tmp;
				}
				else
				{
					if(p2.x >= x)
					{
									
					}
					else
					{
						tmp = p3; p3 = p1; p1 = tmp;
					}
				}
			}
			else if(p1.x < x)
			{
				if(p3.x < x)
				{
					tmp = p3; p3 = p2; p2 = tmp;
				}
				else
				{
					if(p2.x < x)
					{
						
					}
					else
					{
						tmp = p3; p3 = p1; p1 = tmp;
					}
				}
			}
			else
				return p1.y;
						
			var p4 : Vector3D = new Vector3D;		// p4 in p1 p3
			var p5 : Vector3D = new Vector3D;		// p4 in p2 p3
			
			p4.x = x;
			if( (p1.x-p3.x) == 0 )
			{
				p4.y = p3.y;
				p4.z = p3.z;
			}
			else
			{
				p4.y = (p1.y - p3.y)*(x-p3.x)/(p1.x-p3.x) + p3.y;
				p4.z = (p1.z - p3.z)*(x-p3.x)/(p1.x-p3.x) + p3.z;
			}
			
			p5.x = x;
			if( (p2.x-p3.x) == 0 )
			{
				p5.y = p3.y;
				p5.z = p3.z;
			}
			else
			{
				p5.y = (p2.y - p3.y)*(x-p3.x)/(p2.x-p3.x) + p3.y;
				p5.z = (p2.z - p3.z)*(x-p3.x)/(p2.x-p3.x) + p3.z;
			}
			
			var result : Number;
			if(p4.z == p5.z)
				result = p5.y;
			else
				result = (p4.y - p5.y)*(y-p5.z)/(p4.z-p5.z) + p5.y; 
			
			return result;
		}
					
		public function dispose() : void
		{
			if(_collisionTriangles)
				_collisionTriangles.length = 0;
			if(_terrainBmp)
				_terrainBmp.dispose();
		}
		
		
	}
}

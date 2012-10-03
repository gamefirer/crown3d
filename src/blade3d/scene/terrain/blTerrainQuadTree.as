package blade3d.scene.terrain
{
	import away3d.core.base.SubGeometry;
	import away3d.debug.Debug;
	
	import flash.geom.Vector3D;
	
	// 地形用的四叉树
	public class blTerrainQuadTree
	{
		private var _cells:Vector.<blTerrainQuadTreeCell>;		// 所有节点
		private var _rootCell : blTerrainQuadTreeCell;			// 根节点
		private var _vertices:Vector.<Vector3D>;
		private var _triangles:Vector.<blTIndexedTriangle>
		private var _boundingBox:blTAABox;
		
		private var _cellsToTest:Vector.<int>;			// 碰撞检测用数组
		private var _testCounter:int;
		
		private var _maxY : Number;		// 最高位置
		private var _minY : Number;		// 最低位置
		
		public function blTerrainQuadTree() : void
		{
			_testCounter = 0;
			_cells = new Vector.<blTerrainQuadTreeCell>();
			_vertices = new Vector.<Vector3D>();
			_triangles = new Vector.<blTIndexedTriangle>();
			_cellsToTest = new Vector.<int>();
			_boundingBox = new blTAABox();
		}
		
		public function clear():void {
			_cells.length=0;
			_vertices.length=0;
			_triangles.length=0;
		}
		
		public function getVertex(iVertex:uint):Vector3D { return _vertices[iVertex]; 	}
		
		public function getTriangle(iTriangle:uint):blTIndexedTriangle { return _triangles[iTriangle]; }
		
		public function get boundingBox() : blTAABox {return _boundingBox;}
		
		public function get maxY() : Number {return _maxY;}
		public function get minY() : Number {return _minY;}
		
		// 加入三角型到树中,不build
		public function addTriangles(geo:SubGeometry):void 
		{
			clear();
			
			// 载入顶点列表
			var vexI : uint = 0;
			var tmpVector : Vector3D = new Vector3D;
			while(vexI < geo.numVertices)
			{
				tmpVector.x = geo.vertexData[vexI*3];
				tmpVector.y = geo.vertexData[vexI*3+1];
				tmpVector.z = geo.vertexData[vexI*3+2];
				_vertices.push(new Vector3D(tmpVector.x, tmpVector.y, tmpVector.z));
				vexI++;
			}
			// 载入三角型
			var NLen:Number,tiny:Number=0.000001;
			var i0:uint,i1:uint,i2:uint;
			var dr1:Vector3D,dr2:Vector3D,N:Vector3D;
			var indexedTriangle:blTIndexedTriangle;
			var triI : uint = 0;
			while(triI < geo.numTriangles)
			{
				i0 = geo.indexData[triI*3];
				i1 = geo.indexData[triI*3+1];
				i2 = geo.indexData[triI*3+2];
				
				dr1 = _vertices[i1].subtract(_vertices[i0]);
				dr2 = _vertices[i2].subtract(_vertices[i0]);
				N = dr1.crossProduct(dr2);
				NLen = N.length;
				
				if (NLen > tiny)	// 如果该三角型的面积过于小了,就忽略
				{
					indexedTriangle = new blTIndexedTriangle();
					indexedTriangle.setVertexIndices(i0, i1, i2, _vertices);
					_triangles.push(indexedTriangle);
				}
				
				triI++;
			}		
		}
		// 构建四叉树
		public function buildQuadTree(maxTrianglesPerCell:int, minCellSize:Number):void 
		{
			_boundingBox.clear();
			
			_maxY = -1000000000;
			_minY =  1000000000;
			for each(var vt:Vector3D in _vertices) {
				_boundingBox.addPoint(vt);
				if(vt.y > _maxY) _maxY = vt.y;
				if(vt.y < _minY) _minY = vt.y;
			}
			
			_cells.length=0;
			_rootCell = new blTerrainQuadTreeCell(_boundingBox);		// 创建根节点
			_cells.push(_rootCell);
			
			var numTriangles:uint = _triangles.length;
			for (var i:uint = 0; i < numTriangles; i++ ) 
			{
				_cells[0].triangleIndices[i] = i;			// 先把所有的三角面放到根节点上
			}
			
			var cellsToProcess:Vector.<int> = new Vector.<int>();
			cellsToProcess.push(0);
			
			var iTri:int;
			var cellIndex:int;
			var childCell:blTerrainQuadTreeCell;
			while (cellsToProcess.length != 0) 
			{
				cellIndex = cellsToProcess.pop();
				if(cellIndex == 51)
				{
					var xxx:int = 0;
				}
				
				if (_cells[cellIndex].triangleIndices.length <= maxTrianglesPerCell 
					|| _cells[cellIndex].AABox.radius < minCellSize) 
				{
					continue;		// 该cell中还可以放三角面
				}
				
				for (i = 0; i < blTerrainQuadTreeCell.NUM_CHILDREN; i++ )
				{
					_cells[cellIndex].childCellIndices[i] = int(_cells.length);
					cellsToProcess.push(int(_cells.length));
					_cells.push(new blTerrainQuadTreeCell(createAABox(_cells[cellIndex].AABox, i)));
					
					childCell = _cells[_cells.length - 1];
					
					// 父节点上的三角型往子节点中放
					numTriangles = _cells[cellIndex].triangleIndices.length;
					var pushCount : int = 0;
					for (var j:uint=0; j < numTriangles; j++ ) 
					{
						iTri = _cells[cellIndex].triangleIndices[j];
						
						if(iTri == 36 && (_cells.length - 1)==52)
						{
							var xxxx:int = 0;
						}
						
						if (doesTriangleIntersectCell(_triangles[iTri], childCell))
						{
							pushCount++;
							childCell.triangleIndices.push(iTri);
						}
					}
					//Debug.bltrace("c"+(_cells.length - 1)+"="+pushCount);
				}
				_cells[cellIndex].triangleIndices.length=0;
			}
			
			// log tree
			//Debug.bltraceTree(0);			
		}
		// 创建子节点的AABox
		private function createAABox(aabb:blTAABox, _id:uint):blTAABox 
		{
			var centerX : Number = aabb.centreX;
			var centerY : Number = aabb.centreY;
			var dimX : Number = aabb.sideX;
			var dimY : Number = aabb.sideY;
						
			var result:blTAABox = new blTAABox();
			switch(_id)
			{
				case 0:		// 1象限
					result.SetAABox(centerX+dimX/4, centerY+dimY/4, dimX/2, dimY/2);
					break;
				case 1:		// 2象限
					result.SetAABox(centerX-dimX/4, centerY+dimY/4, dimX/2, dimY/2);
					break;
				case 2:		// 3象限
					result.SetAABox(centerX-dimX/4, centerY-dimY/4, dimX/2, dimY/2);
					break;
				case 3:		// 4象限
					result.SetAABox(centerX+dimX/4, centerY-dimY/4, dimX/2, dimY/2);
					break;
				default:
					result.SetAABox(centerX+dimX/4, centerY-dimY/4, dimX/2, dimY/2);
					break;
			}			
		
			return result;
		}
		// 如果三角型和Cell相交,返回True
		private function doesTriangleIntersectCell(triangle:blTIndexedTriangle, cell:blTerrainQuadTreeCell):Boolean 
		{
			// boundingbox要重叠
			if (!triangle.boundingBox.overlapTest(cell.AABox)) {
				return false;
			}
			
			var p1:Vector3D = getVertex(triangle.getVertexIndex(0));
			var p2:Vector3D = getVertex(triangle.getVertexIndex(1));
			var p3:Vector3D = getVertex(triangle.getVertexIndex(2));
			
			if (cell.AABox.isPointInside(p1) ||
				cell.AABox.isPointInside(p2) ||
				cell.AABox.isPointInside(p3) )
			{	// 三角型有顶点在cell中
				return true;
			}
			
			// cell的顶点在三角型中
			var isIntersect : Boolean =
				blTerrainMesh.PointInTriangle( cell.AABox.minPosX, cell.AABox.minPosY, p1, p2, p3) ||
				blTerrainMesh.PointInTriangle( cell.AABox.minPosX, cell.AABox.maxPosY, p1, p2, p3) ||
				blTerrainMesh.PointInTriangle( cell.AABox.maxPosX, cell.AABox.maxPosY, p1, p2, p3) ||
				blTerrainMesh.PointInTriangle( cell.AABox.maxPosX, cell.AABox.minPosY, p1, p2, p3);
			
			if(isIntersect)
				return true;
			
			
			// 三角形的边是否与AABB的边相交
			isIntersect = cell.AABox.isIntersectLineSegment(p1.x, p1.z, p2.x ,p2.z) ||
				cell.AABox.isIntersectLineSegment(p1.x, p1.z, p3.x ,p3.z) ||
				cell.AABox.isIntersectLineSegment(p2.x, p2.z, p3.x ,p3.z);
			
			return isIntersect;
		}
		
		// 寻找在某位置上的三角面
		public function getTrianglesIntersectingtAABox(triangles:Vector.<uint>, aabb:blTAABox):uint 
		{
			if (_cells.length == 0)
				return 0;
			
			
			_cellsToTest.length=0;
			_cellsToTest.push(0);
			
			incrementTestCounter();
			
			var cellIndex:int,nTris:uint, cell:blTerrainQuadTreeCell, triangle:blTIndexedTriangle;
			
			while (_cellsToTest.length != 0) 
			{
				cellIndex = _cellsToTest.pop();
				
				cell = _cells[cellIndex];
				
				if (!aabb.overlapTest(cell.AABox)) {
					continue;
				}
				
				if (cell.isLeaf()) {
					nTris = cell.triangleIndices.length;
					for (var i:uint = 0 ; i < nTris ; i++) {
						triangle = getTriangle(cell.triangleIndices[i]);
						if (triangle.counter != _testCounter) {
							triangle.counter = _testCounter;
							if (aabb.overlapTest(triangle.boundingBox)) {
								triangles.push(cell.triangleIndices[i]);
							}
						}
					}
				}else {
					for (i = 0 ; i < blTerrainQuadTreeCell.NUM_CHILDREN ; i++) {
						_cellsToTest.push(cell.childCellIndices[i]);
					}
				}
			}
			return triangles.length;
			
		}
		
		private function incrementTestCounter():void 
		{
			++_testCounter;
			if (_testCounter == 0) {
				var numTriangles:uint = _triangles.length;
				for (var i:uint = 0; i < numTriangles; i++) {
					_triangles[i].counter = 0;
				}
				_testCounter = 1;
			}
		}
		// 显示quadtree结构
		private var traceDeep : int = 0;
		private function traceTree(cellIndex : int) : void
		{
			if(cellIndex < 0)
				return;
			
			traceDeep++;
			
			var cell : blTerrainQuadTreeCell = _cells[cellIndex];
			
			var spaces : String = "";
			for(var si:int=0;si<(traceDeep-1);si++)
				spaces += "-|";
			
			Debug.trace(spaces + "i=" + cellIndex + " " +
				cell.AABox.minPosX.toFixed(2) + " " + cell.AABox.maxPosX.toFixed(2) + " " + cell.AABox.minPosY.toFixed(2) + " " + cell.AABox.maxPosY.toFixed(2));
			
			var i:int;
			for(i=0; i<cell.triangleIndices.length; i++)
			{
				if( cell.triangleIndices[i] >= 0 )
				{
					var tri : blTIndexedTriangle = _triangles[cell.triangleIndices[i]];
					Debug.trace(spaces + " t=" + cell.triangleIndices[i] + " " + 
						tri.boundingBox.minPosX.toFixed(2) + " " + tri.boundingBox.maxPosX.toFixed(2) + " "
						+ tri.boundingBox.minPosY.toFixed(2) + " " + tri.boundingBox.maxPosY.toFixed(2));
						
				}
			}
			for(i=0; i<cell.childCellIndices.length; i++)
			{
				if( cell.childCellIndices[i] >= 0 )
				{					
					traceTree(cell.childCellIndices[i]);
				}
			}
			traceDeep--;
		}
		
	}

}
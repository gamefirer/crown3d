package blade3d.scene.terrain
{
	import flash.geom.Vector3D;
	
	// 四叉树节点
	public class blTerrainQuadTreeCell
	{
		public static var NUM_CHILDREN:uint = 4;
		
		// (如果不是leaf)子节点的index, -1表示无子节点
		public var childCellIndices:Vector.<int>;
		// (如果是leaf) 三角面的index
		public var triangleIndices:Vector.<int>;
		// 该节点的包围框
		public var AABox:blTAABox;
		
		private var _points:Vector.<Vector3D>;
//		private var _egdes:Vector.<EdgeData>;
		
		public function blTerrainQuadTreeCell(aabox:blTAABox)
		{
			childCellIndices = new Vector.<int>(NUM_CHILDREN, true);
			triangleIndices = new Vector.<int>();
			
			clear();
			
			if(aabox){
				AABox = aabox.clone();
			}else {
				AABox = new blTAABox();
			}
//			_points = AABox.getAllPoints();
//			_egdes = AABox.edges;
		}
		
		// Indicates if we contain triangles (if not then we should/might have children)
		public function isLeaf():Boolean {
			return childCellIndices[0] == -1;
		}
		
		public function clear():void {
			for (var i:uint = 0; i < NUM_CHILDREN; i++ ) {
				childCellIndices[i] = -1;
			}
			triangleIndices.splice(0, triangleIndices.length);
		}
		
		public function get points():Vector.<Vector3D> {
			return _points;
		}
//		public function get egdes():Vector.<EdgeData> {
//			return _egdes;
//		}
	}	
}
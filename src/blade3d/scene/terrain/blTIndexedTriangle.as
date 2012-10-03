package blade3d.scene.terrain
{
	import flash.geom.Vector3D;
	
	public class blTIndexedTriangle
	{
		public var counter:int;
		
		private var _vertexIndices:Vector.<uint>;
		private var _boundingBox:blTAABox;
		
		public function blTIndexedTriangle() 
		{
			counter = 0;
			_vertexIndices = new Vector.<uint>(3, true);
			_vertexIndices[0] = -1;
			_vertexIndices[1] = -1;
			_vertexIndices[2] = -1;
			_boundingBox = new blTAABox();
		}
		
		public function setVertexIndices(i0:uint, i1:uint, i2:uint, vertexArray:Vector.<Vector3D>):void {
			_vertexIndices[0] = i0;
			_vertexIndices[1] = i1;
			_vertexIndices[2] = i2;
			
			_boundingBox.clear();
			_boundingBox.addPoint(vertexArray[i0]);
			_boundingBox.addPoint(vertexArray[i1]);
			_boundingBox.addPoint(vertexArray[i2]);
		}
		
		public function updateVertexIndices(vertexArray:Vector.<Vector3D>):void{
			var i0:uint,i1:uint,i2:uint;
			i0=_vertexIndices[0];
			i1=_vertexIndices[1];
			i2=_vertexIndices[2];
			
			_boundingBox.clear();
			_boundingBox.addPoint(vertexArray[i0]);
			_boundingBox.addPoint(vertexArray[i1]);
			_boundingBox.addPoint(vertexArray[i2]);
		}
		
		public function get vertexIndices():Vector.<uint> {
			return _vertexIndices;
		}
		
		public function getVertexIndex(iCorner:uint):uint {
			return _vertexIndices[iCorner];
		}
		
		public function get boundingBox():blTAABox {
			return _boundingBox;
		}
	}
	
}
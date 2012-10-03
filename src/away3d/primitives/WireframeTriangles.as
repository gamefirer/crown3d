/**
 *	三角形线段 
 */
package away3d.primitives
{
	import away3d.entities.SegmentSet;
	
	import flash.geom.Vector3D;

	public class WireframeTriangles extends WireframePrimitiveBase
	{
		private var maxPoint : Vector3D = new Vector3D(0,0,0);
		private var minPoint : Vector3D = new Vector3D(0,0,0);
		
		private var _triangleVertex : Vector.<Vector3D>;
		
		public function WireframeTriangles(triangleVertex : Vector.<Vector3D>, color : uint = 0x0000FF) 
		{
			super(color);
		
			_triangleVertex = new Vector.<Vector3D>;
			for(var i:int; i<triangleVertex.length; i++)
			{
				_triangleVertex.push( triangleVertex[i].clone() );
			}
		}
		
		override protected function buildGeometry() : void
		{
			var triCount:int = _triangleVertex.length/3; 
			for(var i:int=0; i<triCount; i++)
			{
				updateOrAddSegment(i*3, _triangleVertex[i*3], _triangleVertex[i*3+1]);
				updateOrAddSegment(i*3+1, _triangleVertex[i*3+1], _triangleVertex[i*3+2]);
				updateOrAddSegment(i*3+2, _triangleVertex[i*3+2], _triangleVertex[i*3]);
				
			}
		}
		private function build(triangleVertex : Vector.<Vector3D>, color : uint):void
		{
			_triangleVertex = new Vector.<Vector3D>;
			for(var i:int; i<triangleVertex.length; i++)
			{
				_triangleVertex.push( triangleVertex[i].clone() );
			}
			
			this.color = color;
			removeAllSegments();
			invalidateGeometry();
		}
		
	}	
}

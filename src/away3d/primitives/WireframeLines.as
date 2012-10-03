/**
 *	绘制线段的对象 
 */
package away3d.primitives
{
	
	import flash.geom.Vector3D;
	
	public class WireframeLines extends WireframePrimitiveBase
	{
		private var maxPoint : Vector3D = new Vector3D(0,0,0);
		private var minPoint : Vector3D = new Vector3D(0,0,0);
		
		private var _linePoints : Vector.<Vector3D>;
		
		
		// linePoints为线段序列
		public function WireframeLines(linePoints : Vector.<Vector3D>, color : uint = 0x0000FF) {
			super(color);
			
			_linePoints = new Vector.<Vector3D>;
			for(var i:int=0; i<_linePoints.length; i++)
			{
				_linePoints.push(linePoints[i]);
			}
			
			build(linePoints, color);
		}
		
		override protected function buildGeometry() : void
		{
			if(_linePoints.length == 0)
			{
				_linePoints.push(maxPoint);
				_linePoints.push(maxPoint);
			}
			else if(_linePoints.length == 1)
			{
				_linePoints.push(_linePoints[0].clone());
			}
			
			var i:int = 0;	
			var lineNumber : int = _linePoints.length/2;
			for(i=0;i<lineNumber;i++)
			{
				updateOrAddSegment(i, _linePoints[i*2], _linePoints[i*2+1]);
			}
		}
		
		private function build(linePoints : Vector.<Vector3D>, color : uint) : void
		{			
			_linePoints = new Vector.<Vector3D>;
			for(var i:int=0; i<_linePoints.length; i++)
			{
				_linePoints.push(linePoints[i]);
			}
			this.color = color;
			
			removeAllSegments();
			invalidateGeometry();
		}
		
	}
}
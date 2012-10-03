/**
 *	路径制造器 
 */
package away3d.paths
{
	import flash.geom.Vector3D;

	public class PathMaker
	{
		static private var _zeroPointData : Vector.<Vector3D> = new <Vector3D>[new Vector3D(0,0,0), new Vector3D(0,0,0), new Vector3D(0,0,0)];
		
		public var pointData : Vector.<Vector3D>;				// 路径点
		private var _duration : int;							// 运动时间
		
		public function PathMaker()
		{
			pointData = new Vector.<Vector3D>;
		}
		
		public function set duration(dur:int):void {_duration = dur;}
		public function get duration():int {return _duration;}
		
		public function makePath():QuadraticPath
		{
			if(!pointData || pointData.length < 2)
				return new QuadraticPath(_zeroPointData);
			
			var pathPointData : Vector.<Vector3D> = new Vector.<Vector3D>;
			
			for(var i:int=1; i<pointData.length; i++)
			{
				pathPointData.push( pointData[i-1].clone() );
				
				var midPoint : Vector3D = pointData[i-1].add(pointData[i]);
				midPoint.scaleBy(0.5);
				pathPointData.push( midPoint );
				
				pathPointData.push( pointData[i].clone() );
			}
			
			return new QuadraticPath(pathPointData);
		}
	}
}
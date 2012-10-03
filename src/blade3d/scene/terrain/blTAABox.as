package blade3d.scene.terrain
{
	import flash.geom.Vector3D;
	
	public class blTAABox
	{
		public var minPosX : Number;
		public var minPosY : Number;
		public var maxPosX : Number;
		public var maxPosY : Number;
		
		private static var tiny:Number=0.000001;
		public function blTAABox()
		{
			clear();
		}
		
		public function SetAABox(cx : Number, cy : Number, sideX : Number, sideY : Number) : void
		{			
			minPosX = cx - sideX/2 - tiny;
			maxPosX = cx + sideX/2 + tiny;
			minPosY = cy - sideY/2 - tiny;
			maxPosY = cy + sideY/2 + tiny;
		}
		
		public function clear():void 
		{
			var huge:Number = 1000000000;
			minPosX = minPosY = huge;
			maxPosX = maxPosY = -huge;			
		}
		
		public function addPoint(pos:Vector3D):void
		{
			if (pos.x < minPosX) minPosX = pos.x - tiny;
			if (pos.x > maxPosX) maxPosX = pos.x + tiny;
			if (pos.z < minPosY) minPosY = pos.z - tiny;
			if (pos.z > maxPosY) maxPosY = pos.z + tiny;
		}
		
		public function clone():blTAABox 
		{
			var aabb:blTAABox = new blTAABox();
			aabb.minPosX = this.minPosX;
			aabb.minPosY = this.minPosY;
			aabb.maxPosX = this.maxPosX;
			aabb.maxPosY = this.maxPosY;
			return aabb;
		}
		// 对角线长
		public function get radius(): Number
		{
			return Math.sqrt( (maxPosY - minPosY)*(maxPosY - minPosY) + (maxPosX - minPosX)*(maxPosX - minPosX) );
		}
		
		public function get sideX(): Number
		{
			return maxPosX - minPosX;
		}
		
		public function get sideY(): Number
		{
			return maxPosY - minPosY;
		}		
		
		public function get centreX(): Number 
		{
			return (maxPosX - minPosX) * 0.5 + minPosX;
		}
		
		public function get centreY(): Number 
		{
			return (maxPosY - minPosY) * 0.5 + minPosY;
		}
		
		public function overlapTest(box:blTAABox):Boolean 
		{
			return (
				(minPosY >= box.maxPosY) ||
				(maxPosY <= box.minPosY) ||
				(minPosX >= box.maxPosX) ||
				(maxPosX <= box.minPosX) ) ? false : true;
		}
		
		public function isPointInside(pos:Vector3D):Boolean {
			return ((pos.x >= minPosX) && 
				(pos.x <= maxPosX) && 
				(pos.z >= minPosY) && 
				(pos.z <= maxPosY));
		}
		
		public function isIntersectLineSegment(p1x : Number, p1y : Number, p2x : Number, p2y : Number) : Boolean {
			var isIntersect : Boolean = false;
			// 直线方程p1-p2
			var A1 : Number = p1y - p2y;
			var B1 : Number = p2x - p1x;
			var C1 : Number = p1x * p2y - p2x * p1y;
			// 与AABox
			var LineIntersectY : Number = (-C1 - A1*minPosX) / B1;
			if(LineIntersectY <= maxPosY && LineIntersectY >= minPosY) isIntersect = true;
			LineIntersectY = (-C1 - A1*maxPosX) / B1;
			if(LineIntersectY <= maxPosY && LineIntersectY >= minPosY) isIntersect = true;
			var LineIntersectX : Number = (-C1 - B1*minPosY) / A1;
			if(LineIntersectX <= maxPosX && LineIntersectX >= minPosX) isIntersect = true;
			LineIntersectX = (-C1 - B1*maxPosY) / A1;
			if(LineIntersectX <= maxPosX && LineIntersectX >= minPosX) isIntersect = true;
			return isIntersect;
		}
		
	} // blTAABox	
}
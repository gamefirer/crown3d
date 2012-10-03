package org.poly2tri.utils {
	import org.poly2tri.Edge;
	import org.poly2tri.Point;
	import org.poly2tri.Triangle;

	public class PathFindChannel {
		public function PathFindChannel() {
		}
		
		static public var tmpPoint : Point = new Point;
		static public var tmpPoint1 : Point = new Point;
		static public var tmpPoint2 : Point = new Point;
		static public var fatScale : Number = 1.5;	// 肥胖检测时的放大尺度
		
		static public function channelToPortals(startPoint:Point, endPoint:Point, channel:Vector.<SpatialNode>, fatRadius : Number = 0):NewFunnel {
			
			fatRadius *= fatScale;
			var portals:NewFunnel = new NewFunnel();

			portals.push(startPoint);		// 起点

			if (channel.length >= 2) {
				var firstTriangle:Triangle = channel[0].triangle;
				var secondTriangle:Triangle = channel[1].triangle;
				var lastTriangle:Triangle  = channel[channel.length - 1].triangle;
				var startVertex:Point;
				
				//assert(firstTriangle.pointInsideTriangle(startPoint));
				//assert(lastTriangle.pointInsideTriangle(endPoint));
				
				startVertex = Triangle.getNotCommonVertex(firstTriangle, secondTriangle);
				
				var vertexCW0:Point = startVertex;
				var vertexCCW0:Point = startVertex;
				
				//Debug.bltrace(startVertex);
				
				var isFatToBlock : Boolean = false;
				for (var n:int = 0; n < channel.length - 1; n++) {
					var triangleCurrent:Triangle = channel[n + 0].triangle;
					var triangleNext:Triangle    = channel[n + 1].triangle;
					var commonEdge:Edge  = Triangle.getCommonEdge(triangleCurrent, triangleNext);
					var vertexCW1:Point  = triangleCurrent.pointCW (vertexCW0 );
					var vertexCCW1:Point = triangleCurrent.pointCCW(vertexCCW0);
					if (!commonEdge.hasPoint(vertexCW0)) {
						vertexCW0 = vertexCW1;
					}
					if (!commonEdge.hasPoint(vertexCCW0)) {
						vertexCCW0 = vertexCCW1;
					}
					// 体型肥胖检测
					if( ((vertexCW0.x-vertexCCW0.x)*(vertexCW0.x-vertexCCW0.x) + (vertexCW0.y-vertexCCW0.y)*(vertexCW0.y-vertexCCW0.y))
						< fatRadius*fatRadius*4)
					{	// 太胖卡住了
//						Debug.bltrace("fat break");
						isFatToBlock = true;
						break;
					}
					else
					{
//						Debug.bltrace(vertexCW0, vertexCCW0);
						
						tmpPoint.set( vertexCCW0.x, vertexCCW0.y );
						tmpPoint.sub(vertexCW0);
						tmpPoint.normalize();
						
						tmpPoint.mul(fatRadius);
						
						tmpPoint1.set( vertexCW0.x, vertexCW0.y );
						tmpPoint1.add(tmpPoint);
						
						tmpPoint.neg();
						tmpPoint2.set( vertexCCW0.x, vertexCCW0.y );
						tmpPoint2.add(tmpPoint);
						
					}
					
					portals.push(tmpPoint1.clone(), tmpPoint2.clone());
					
				}
			}
			if(!isFatToBlock)
				portals.push(endPoint);		// 终点
			
			portals.stringPull();		// portal -> path
			
			return portals;
		}
		
		static public function channelToPortals2(startPoint:Point, endPoint:Point, channel:Vector.<SpatialNode>):NewFunnel {
			/*
			var nodeStart:SpatialNode   = spatialMesh.getNodeFromTriangle(vp.getTriangleAtPoint(new Point(50, 50)));
			//var nodeEnd:SpatialNode     = spatialMesh.getNodeFromTriangle(vp.getTriangleAtPoint(new Point(73, 133)));
			//var nodeEnd:SpatialNode     = spatialMesh.getNodeFromTriangle(vp.getTriangleAtPoint(new Point(191, 152)));
			//var nodeEnd:SpatialNode     = spatialMesh.getNodeFromTriangle(vp.getTriangleAtPoint(new Point(316, 100)));
			var nodeEnd:SpatialNode     = spatialMesh.getNodeFromTriangle(vp.getTriangleAtPoint(new Point(300, 300)));
			channel[0].triangle.pointInsideTriangle();
			channel[0].triangle.points[0]
			*/

			var portals:NewFunnel = new NewFunnel();
			var firstTriangle:Triangle = channel[0].triangle;
			var secondTriangle:Triangle = channel[1].triangle;
			var lastTriangle:Triangle  = channel[channel.length - 1].triangle;
			
			assert(firstTriangle.pointInsideTriangle(startPoint));
			assert(lastTriangle.pointInsideTriangle(endPoint));

			var startVertexIndex:int = Triangle.getNotCommonVertexIndex(firstTriangle, secondTriangle);
			//firstTriangle.containsPoint(firstTriangle.points[0]);

			// Add portals.
			
			var currentVertexCW:Point  = firstTriangle.points[startVertexIndex];
			var currentVertexCCW:Point = firstTriangle.points[startVertexIndex];
			//var currentTriangle:Triangle = firstTriangle;
			
			portals.push(startPoint);
			
			for (var n:uint = 1; n < channel.length; n++) {
				var edge:Edge = Triangle.getCommonEdge(channel[n - 1].triangle, channel[n].triangle);
				portals.push(edge.p, edge.q);
				//Debug.bltrace(edge);
			}
			
			/*
			for (var n:uint = 0; n < channel.length; n++) {
				Debug.bltrace(currentVertexCW + " | " + currentVertexCCW);
				currentVertexCW = channel[n].triangle.pointCW(currentVertexCW);
				currentVertexCCW = channel[n].triangle.pointCCW(currentVertexCCW);
				portals.push(new FunnelPortal(currentVertexCW, currentVertexCCW));
				//firstTriangle.pointCW();
			}
			*/

			portals.push(endPoint);
			
			portals.stringPull();

			return portals;
		}
		
		static private function assert(test:Boolean):void {
			if (!test) throw(new Error("Assert error"));
		}
	}

}

/**
 *	场景划分显示 
 */
package away3d.debug
{
	import away3d.cameras.Camera3D;
	import away3d.core.math.Plane3D;
	import away3d.core.partition.Partition3D;
	import away3d.core.partition.QuadTree;
	import away3d.core.partition.QuadTreeNode;
	
	import blade3d.camera.BlCameraManager;
	import blade3d.scene.BlSceneManager;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	public class PartitionStats extends Sprite
	{
		private var _WIDTH : int = 150;
		
		private var _partition_graph : Shape;
		
		public function PartitionStats()
		{
			super();
			
			y = 550;
			
			init();
			
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			
			// 支持拖动
			addEventListener(MouseEvent.MOUSE_DOWN, _onDiagramMouseDown);
		}
		
		private function init():void
		{
			var _dia_bmp : BitmapData = new BitmapData(_WIDTH, _WIDTH, true, 0x30ff0000);
			var _diagram:Sprite = new Sprite;
			_diagram.graphics.beginBitmapFill(_dia_bmp);
			_diagram.graphics.drawRect(0, 0, _dia_bmp.width, _dia_bmp.height);
			_diagram.graphics.endFill();
			addChild(_diagram);
			
			addChild(_partition_graph = new Shape);
		}		
		
		private function _onEnterFrame(ev : Event) : void
		{
			if(!BlSceneManager.instance().currentScene)
				return;
				
			var partition3D : Partition3D = BlSceneManager.instance().currentScene.partition;
			if(!(partition3D is QuadTree)) return;
			
			var g : Graphics = _partition_graph.graphics;
			g.clear();
			// 绘制场景切割线
			redrawPartition(g, QuadTree(partition3D));
			// 绘制摄像机范围
			redrawCamera(g, QuadTree(partition3D));
			// 绘制坐标轴
			redrawAxis(g, QuadTree(partition3D));
		}
		
		private function redrawAxis(g:Graphics, quadTree :QuadTree):void
		{
			if(!BlCameraManager.instance().currentCamera) return;
			
			var cam : Camera3D = BlCameraManager.instance().currentCamera.camera;
			
			var axisLength : Number = 500;
			var size:Number = QuadTreeNode(quadTree.rootNode).quadSize;
			
			var p:Vector.<Vector3D> = new Vector.<Vector3D>(4);
			p[0] = new Vector3D(0, 0, 0);
			p[1] = new Vector3D(axisLength, 0, 0);
			p[2] = new Vector3D(0, axisLength, 0);
			p[3] = new Vector3D(0, 0, axisLength);
			
			for(var i:int=0; i<4; i++)
			{
				p[i] = p[i].add(cam.scenePosition);
				p[i].scaleBy( Number(_WIDTH) / size);
				p[i].x += _WIDTH/2;
				p[i].z += _WIDTH/2;
			}
			
			// X
			g.lineStyle(.5, 0xff0000, 1, true, LineScaleMode.NONE);
			g.moveTo(p[0].x, _WIDTH - p[0].z);
			g.lineTo(p[1].x, _WIDTH - p[1].z);
			// Y
			g.lineStyle(.5, 0x00ff00, 1, true, LineScaleMode.NONE);
			g.moveTo(p[0].x, _WIDTH - p[0].z);
			g.lineTo(p[2].x, _WIDTH - p[2].z);
			// Z
			g.lineStyle(.5, 0x0000ff, 1, true, LineScaleMode.NONE);
			g.moveTo(p[0].x, _WIDTH - p[0].z);
			g.lineTo(p[3].x, _WIDTH - p[3].z);
		}
		
		private function redrawPartition(g:Graphics, quadTree :QuadTree):void
		{
			g.lineStyle(.5, 0xff00cc, 1, true, LineScaleMode.NONE);
			
			var rootNode : QuadTreeNode = QuadTreeNode(quadTree.rootNode);
			
			recurDrawQuadNode(g, rootNode, 1, 0, 0);
			
		}
		
		private function recurDrawQuadNode(g:Graphics, quadNode : QuadTreeNode, quadrant:int, x:Number, y:Number):void
		{
			if(!quadNode) return;
			if (!quadNode.inCamera) return;
			
			if( (quadNode.rightFar && quadNode.rightFar.inCamera)
				|| (quadNode.leftFar && quadNode.leftFar.inCamera)
				|| (quadNode.leftNear && quadNode.leftNear.inCamera)
				|| (quadNode.rightNear && quadNode.rightNear.inCamera) )
				g.lineStyle(.5, 0x552211, 1, true, LineScaleMode.NONE);
			else
				g.lineStyle(.5, 0xff00cc, 1, true, LineScaleMode.NONE);
			
			var startX:Number = x;
			var startY:Number = y;
			
			var drawWide:Number = _WIDTH / Math.pow(2, quadNode.depth);
			var drawHeight:Number = _WIDTH / Math.pow(2, quadNode.depth);
			
			g.moveTo(startX, startY);
			g.lineTo(startX+drawWide, startY);
			g.lineTo(startX+drawWide, (startY+drawHeight));
			g.lineTo(startX, (startY+drawHeight));
			g.lineTo(startX, (startY));
			
			recurDrawQuadNode(g, quadNode.rightFar, 1, startX+drawWide/2, startY);
			recurDrawQuadNode(g, quadNode.leftFar, 2, startX, startY);
			recurDrawQuadNode(g, quadNode.leftNear, 3, startX, startY+drawHeight/2);
			recurDrawQuadNode(g, quadNode.rightNear, 4, startX+drawWide/2, startY+drawHeight/2);
		}
		
		private function redrawCamera(g:Graphics, quadTree :QuadTree):void
		{
			if(!BlCameraManager.instance().currentCamera) return;
			
			var size:Number = QuadTreeNode(quadTree.rootNode).quadSize;
			
			g.lineStyle(.5, 0xffff00, 1, true, LineScaleMode.NONE);
			
			var camera3D : Camera3D = BlCameraManager.instance().currentCamera.camera;
			var planes : Vector.<Plane3D> = camera3D.frustumPlanes;
			
			// 求8个交点(
			// 0 left
			// 1 right
			// 2 bottom
			// 3 top
			// 4 near
			// 5 far
			var p:Vector.<Vector3D> = new Vector.<Vector3D>(8);
			p[0] = calc3PlanesPoint(planes[4], planes[0], planes[2]);	// 0 near left bottom
			p[1] = calc3PlanesPoint(planes[4], planes[1], planes[2]);	// 1 near right bottom
			p[2] = calc3PlanesPoint(planes[4], planes[0], planes[3]);	// 2 near left top
			p[3] = calc3PlanesPoint(planes[4], planes[1], planes[3]);	// 3 near right top
			
			p[4] = calc3PlanesPoint(planes[5], planes[0], planes[2]);	// 4 far left bottom
			p[5] = calc3PlanesPoint(planes[5], planes[1], planes[2]);	// 5 far right bottom
			p[6] = calc3PlanesPoint(planes[5], planes[0], planes[3]);	// 6 far left top
			p[7] = calc3PlanesPoint(planes[5], planes[1], planes[3]);	// 7 far right top
			
			
			for(var i:int=0; i<8; i++)
			{
				p[i].scaleBy( Number(_WIDTH) / size);
				p[i].x += _WIDTH/2;
				p[i].z += _WIDTH/2;
			}
			// draw near
			g.moveTo(p[0].x, _WIDTH - p[0].z);
			g.lineTo(p[1].x, _WIDTH - p[1].z);
			g.lineTo(p[3].x, _WIDTH - p[3].z);
			g.lineTo(p[2].x, _WIDTH - p[2].z);
			g.lineTo(p[0].x, _WIDTH - p[0].z);
			
			// draw far
			g.moveTo(p[4].x, _WIDTH - p[4].z);
			g.lineTo(p[5].x, _WIDTH - p[5].z);
			g.lineTo(p[7].x, _WIDTH - p[7].z);
			g.lineTo(p[6].x, _WIDTH - p[6].z);
			g.lineTo(p[4].x, _WIDTH - p[4].z);
			
			//draw left
			g.moveTo(p[0].x, _WIDTH - p[0].z);
			g.lineTo(p[2].x, _WIDTH - p[2].z);
			g.lineTo(p[6].x, _WIDTH - p[6].z);
			g.lineTo(p[4].x, _WIDTH - p[4].z);
			g.lineTo(p[0].x, _WIDTH - p[0].z);
			
			// draw right
			g.moveTo(p[1].x, _WIDTH - p[1].z);
			g.lineTo(p[3].x, _WIDTH - p[3].z);
			g.lineTo(p[7].x, _WIDTH - p[7].z);
			g.lineTo(p[5].x, _WIDTH - p[5].z);
			g.lineTo(p[1].x, _WIDTH - p[1].z);
			
		}
		// 求3个平面的交点
		/**
		 * 根据Cramer规则有
		 * 
		 * |a1 b1 c1|   |x|   |-d1|
		 * |a2 b2 c2| * |y| = |-d2|
		 * |a3 b3 c3|   |z|   |-d3|
		 * 
		 * 
		 *     |-d1 b1 c1|
		 *     |-d2 b2 c2|
		 *     |-d3 b3 c3|
		 * x = -----------
		 *         d 
		 * 
		 *     |a1 -d1 c1|
		 *     |a2 -d2 c2|
		 *     |a3 -d3 c3|
		 * y = -----------
		 *         d
		 * 
		 *     |a1 b1 -d1|
		 *     |a2 b2 -d2|
		 *     |a3 b3 -d3|
		 * z = -----------
		 *         d
		 * 
		 * 其中
		 * 
		 *     |a1 b1 c1|
		 * d = |a2 b2 c2| = a1*|b2 c2| - b1 * |a2 c2| + c1 * |a2 b2|
		 *     |a3 b3 c3|      |b3 c3|        |a3 c3|        |a3 b3|
		 */
		private function calc3PlanesPoint(p1:Plane3D, p2:Plane3D, p3:Plane3D):Vector3D
		{
			var a1:Number = p1.a;
			var b1:Number = p1.b;
			var c1:Number = p1.c;
			var d1:Number = p1.d;
			var a2:Number = p2.a;
			var b2:Number = p2.b;
			var c2:Number = p2.c;
			var d2:Number = p2.d;
			var a3:Number = p3.a;
			var b3:Number = p3.b;
			var c3:Number = p3.c;
			var d3:Number = p3.d;
			
			var d:Number = a1*(b2*c3-c2*b3)-b1*(a2*c3-c2*a3)+c1*(a2*b3-b2*a3);
			
			var x:Number = ( -d1*(b2*c3-c2*b3) - b1*((-d2)*c3-c2*(-d3)) + c1*((-d2)*b3-b2*(-d3)) ) / d;
			var y:Number = ( a1*((-d2)*c3-c2*(-d3)) - (-d1)*(a2*c3-c2*a3) + c1*(a2*(-d3)-(-d2)*a3) ) / d;
			var z:Number = ( a1*(b2*(-d3)-(-d2)*b3) - b1*(a2*(-d3)-(-d2)*a3) + (-d1)*(a2*b3-b2*a3) ) / d;
			
			return new Vector3D(x, y, z);
		}
		
		public function stop(b:Boolean):void
		{
			if(b)
			{
				removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
			}
			else
			{
				addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			}
		}
		// 拖动
		private var _drag_dx : Number;
		private var _drag_dy : Number;
		private var _dragging : Boolean = false;
		private function _onDiagramMouseDown(ev : MouseEvent) : void
		{
			_drag_dx = this.mouseX;
			_drag_dy = this.mouseY;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUpOrLeave);
			stage.addEventListener(Event.MOUSE_LEAVE, _onMouseUpOrLeave);
		}
		
		private function _onMouseMove(ev : MouseEvent) : void
		{
			_dragging = true;
			this.x = stage.mouseX - _drag_dx;
			this.y = stage.mouseY - _drag_dy;
		}
		
		private function _onMouseUpOrLeave(ev : Event) : void
		{
			_endDrag();
		}
		
		private function _endDrag() : void
		{
			if (this.x < -_WIDTH)
				this.x = -(_WIDTH-20);
			else if (this.x > stage.stageWidth)
				this.x = stage.stageWidth - 20;
			
			if (this.y < 0)
				this.y = 0;
			else if (this.y > stage.stageHeight)
				this.y = stage.stageHeight - 15;
			
			// Round x/y position to make sure it's on
			// whole pixels to avoid weird anti-aliasing
			this.x = Math.round(this.x);
			this.y = Math.round(this.y);
			
			
			_dragging = false; 
			stage.removeEventListener(Event.MOUSE_LEAVE, _onMouseUpOrLeave);
			stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUpOrLeave);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
		}
	}
}


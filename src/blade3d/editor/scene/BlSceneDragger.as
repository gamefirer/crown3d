/**
 *	场景物体拖拽器 
 */
package blade3d.editor.scene
{
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.pick.PickingColliderType;
	import away3d.debug.Debug;
	import away3d.debug.data.TridentLines;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
	import away3d.events.MouseEvent3D;
	import away3d.events.Object3DEvent;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	
	import blade3d.camera.BlCameraManager;
	import blade3d.editor.BlSceneEditor;
	import blade3d.io.BlInputManager;
	import blade3d.resource.BlModelResource;
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceManager;
	import blade3d.scene.BlSceneManager;
	
	import editor.SceneViewer;
	
	import flash.display3D.Context3DCompareMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	
	public class BlSceneDragger
	{
		public var node : ObjectContainer3D;
		
		private var _axis : Vector.<Mesh>;
		private var _dragObj : ObjectContainer3D;
		
		private var _isDrag : int = 0;
		
		private var _startPos : Vector3D = new Vector3D;
		private var _startDragPos : Vector3D = new Vector3D;
		// 点法式平面 A(x-x0)+B(y-y0)+C(z-z0)=0
		private var A:Number;
		private var B:Number;
		private var C:Number;
		private var x0:Number;
		private var y0:Number;
		private var z0:Number;
		
		
		public function BlSceneDragger()
		{
			node = new ObjectContainer3D;
			node.name = "scene_dragger";
			node.visible = false;
			buildTrident();
		}
		
		public function setDraggerObject(obj:ObjectContainer3D):void
		{
			if(_dragObj)
			{
				_dragObj.removeEventListener(Object3DEvent.POSITION_CHANGED, onPosChange);
				_dragObj.removeEventListener(Object3DEvent.DISPOSE, onObjDispose);
			}
			_dragObj = obj;
			if(_dragObj)
			{
				node.visible = true;
				node.position = _dragObj.scenePosition;
				_dragObj.addEventListener(Object3DEvent.POSITION_CHANGED, onPosChange, false, 0, true);
				_dragObj.addEventListener(Object3DEvent.DISPOSE, onObjDispose, false, 0 ,true);
				
				
			}
			else
				node.visible = false;
		}
		
		public function getDraggerObject():ObjectContainer3D {return _dragObj;}
		
		private function onPosChange(evt:Object3DEvent):void
		{
			node.position = ObjectContainer3D(evt.object).scenePosition;
		}
		
		private function onObjDispose(evt:Object3DEvent):void
		{
			setDraggerObject(null);
		}
		
		private function buildTrident():void
		{
			_axis = new Vector.<Mesh>(3);		// 0 x 1 y 2 z
			var resX : BlModelResource = BlResourceManager.instance().findModelResource("base/axis_x.3ds");
			resX.asycLoad(onAxisMesh);
		}
		
		private function onAxisMesh(res:BlResource):void
		{
			for(var i:int=0; i<3; i++)
			{
				var color:uint;
				if(i==0) color = 0xFF0000;
				else if(i==1) color = 0x00FF00;
				else if(i==2) color = 0x0000FF;
				
				var material : ColorMaterial = new ColorMaterial(color);
				_axis[i] = new Mesh(BlModelResource(res).geo, material);
				_axis[i].renderLayer = Entity.Editor_Layer;
				material.depthWrite = false;
				material.depthCompareMode = Context3DCompareMode.ALWAYS;
				
				if(i==0)
				{
					_axis[i].x = 2;
				}
				else if(i==1)
				{
					_axis[i].rotationZ = 90;
					_axis[i].y = 2;
				}
				else if(i==2)
				{
					_axis[i].rotationY = -90;
					_axis[i].z = 2;
				}
				
				node.addChild(_axis[i]);
				
				_axis[i].mouseEnabled = true;
				_axis[i].shaderPickingDetails = true;
				_axis[i].pickingCollider = PickingColliderType.PB_FIRST_ENCOUNTERED;
				_axis[i].addEventListener( MouseEvent3D.MOUSE_DOWN, onAxisMouseDown );
				_axis[i].addEventListener( MouseEvent3D.MOUSE_OVER, onAxisMouseOver );
				_axis[i].addEventListener( MouseEvent3D.MOUSE_OUT, onAxisMouseOut );
				BlInputManager.addMouseMoveHandler(onMouseMove);
				BlInputManager.addMouseUpHandler(onMouseUp);
			}
		}
		
		private function onAxisMouseDown( event:MouseEvent3D ):void 
		{
//			Debug.log("onAxisMouseDown");
			var mesh:Mesh = event.object as Mesh;
			
			if(mesh == _axis[0])
				_isDrag = 1;
			else if(mesh == _axis[1])
				_isDrag = 2;
			else if(mesh == _axis[2])
				_isDrag = 3;
				
			_startPos.copyFrom(node.position);
			
			// 确定平面
			var mouseRay : Vector3D = BlCameraManager.instance().currentCamera.getMouseRay();
			mouseRay.normalize();
			
			var moveRay : Vector3D;
			if(_isDrag == 1) moveRay = Vector3D.X_AXIS;
			if(_isDrag == 2) moveRay = Vector3D.Y_AXIS;
			if(_isDrag == 3) moveRay = Vector3D.Z_AXIS;
			
			var up : Vector3D = moveRay.crossProduct(mouseRay);
			up.normalize();
			var planeN : Vector3D = up.crossProduct(moveRay);
			planeN.normalize();
			
			A = planeN.x;	// 平面法向
			B = planeN.y;
			C = planeN.z;
//			Debug.log(planeN);
			
			x0 = event.scenePosition.x;
			y0 = event.scenePosition.y;
			z0 = event.scenePosition.z;
			
			// 求鼠标射线与平面交点
			var angel:Number = Vector3D.angleBetween(mouseRay, new Vector3D(A, B, C));
			
			var camPos : Vector3D = BlCameraManager.instance().currentCamera.camera.scenePosition;
			
			var x : Number = camPos.x;
			var y : Number = camPos.y;
			var z : Number = camPos.z;
			
			var disO:Number = A*(x-x0)+B*(y-y0)+C*(z-z0);
			var dis:Number = Math.abs(disO) / Math.cos(angel);
			//				Debug.log(dis);
			
			var dx : Number = camPos.x + mouseRay.x * dis;
			var dy : Number = camPos.y + mouseRay.y * dis;
			var dz : Number = camPos.z + mouseRay.z * dis;
			
//			Debug.log(dx +" "+ dy +" "+ dz);
			
			
			_startDragPos.x = dx;
			_startDragPos.y = dy;
			_startDragPos.z = dz;
//			Debug.log("start "+_startDragPos);
		}
		
		private function onMouseUp( event:MouseEvent ):Boolean
		{
			if(_isDrag == 1)
				ColorMaterial(_axis[0].material).color = 0xFF0000;
			else if(_isDrag == 2)
				ColorMaterial(_axis[1].material).color = 0x00FF00;
			else if(_isDrag == 3)
				ColorMaterial(_axis[2].material).color = 0x0000FF;
			
			_isDrag = 0;
			return true;
		}
		
		private function onMouseMove( event:MouseEvent ):Boolean
		{
			if(_isDrag)
			{
				// 求鼠标射线与平面交点
				var mouseRay : Vector3D = BlCameraManager.instance().currentCamera.getMouseRay();
				mouseRay.normalize();
				
				var angel:Number = Vector3D.angleBetween(mouseRay, new Vector3D(A, B, C));
				
				var camPos : Vector3D = BlCameraManager.instance().currentCamera.camera.scenePosition;
				
				var x : Number = camPos.x;
				var y : Number = camPos.y;
				var z : Number = camPos.z;
				
				var dis:Number = A*(x-x0)+B*(y-y0)+C*(z-z0);
				dis = Math.abs(dis) / Math.cos(angel);
				//				Debug.log(dis);
				
				var dx : Number = camPos.x + mouseRay.x * dis;
				var dy : Number = camPos.y + mouseRay.y * dis;
				var dz : Number = camPos.z + mouseRay.z * dis;
				
				// 求交点在拖动轴上的投影点
				if(_isDrag == 1) // x轴
				{
//					Debug.log(dx + " " + (dx - _startDragPos.x));
					node.x = _startPos.x + (dx - _startDragPos.x);
				}
				else if(_isDrag == 2) // y轴
				{
					node.y = _startPos.y + (dy - _startDragPos.y);
				}
				else if(_isDrag == 3) // z轴
				{
					node.z = _startPos.z + (dz - _startDragPos.z);
				}
				
				// 修改被拖动对象的位置
				if(_dragObj)
				{
					_dragObj.position = node.scenePosition;
				}
			}
			return true;
		}
		
		private function onAxisMouseMove( event:MouseEvent3D ):void
		{
//			Debug.log("onAxisMouseMove");
			
		}
		
		private function onAxisMouseOver( event:MouseEvent3D ):void
		{
			if(!_isDrag)
			{
				var mesh:Mesh = event.object as Mesh;
				ColorMaterial(mesh.material).color = 0xFFFF00;
			}
		}
		
		private function onAxisMouseOut( event:MouseEvent3D ):void 
		{
			if(!_isDrag)
			{
				var mesh:Mesh = event.object as Mesh;
				if(mesh == _axis[0])
					ColorMaterial(mesh.material).color = 0xFF0000;
				else if(mesh == _axis[1])
					 ColorMaterial(mesh.material).color = 0x00FF00;
				else if(mesh == _axis[2])
					ColorMaterial(mesh.material).color = 0x0000FF;
			}
		}
	}
}

/**
 *	渲染3Dui用的camera 
 */
package sl2d.display
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public class slCamera extends slObject
	{
		protected var renderMatrix:Matrix3D = new Matrix3D();
		protected var viewMatrix:Matrix3D = new Matrix3D();
		
		
		private var _zoom:Number = 1.0;
		private var _rotation:Number = 0.0;
		
		protected var _sceneWidth:Number;
		protected var _sceneHeight:Number;
		private var _target:slPoint;
		private var invalidated:Boolean = true;
		
		public function slCamera(w:Number, h:Number)
		{
			resizeCameraStage(w, h);
			setPosition(0, 0);
		}
		
		public function resizeCameraStage(w:Number, h:Number):void
		{
			_sceneWidth = w;
			_sceneHeight = h;
			invalidated = true;
		}
		
		public function lookAt(target:slPoint):void
		{
			_target = target;
		}
		
		public function getViewProjectionMatrix():Matrix3D 
		{
			if(invalidated)
			{
				invalidated = false;
				viewMatrix.identity();
				viewMatrix.appendScale(2/_sceneWidth * zoom,-2/_sceneHeight * zoom,1/100000);
				viewMatrix.appendTranslation(-1 - (x/_sceneWidth) * 2, 1 +  (y/_sceneHeight) * 2,0);
				viewMatrix.appendRotation(_rotation, Vector3D.Z_AXIS);
			}
			return viewMatrix;
		}
		
		public function reset():void 
		{
			_x = _y = _rotation = 0;
			_zoom = 1;
		}
		
		override public function set x(value:Number):void 
		{
			invalidated = true;
			_x = value;
		}
		
		override public function set y(value:Number):void 
		{
			invalidated = true;
			_y = value;
		}
		
		override public function setPosition(X:Number, Y:Number):void
		{
			_x = X;
			_y = Y;
			invalidated = true;
		}
		
		public function get zoom():Number 
		{
			return _zoom;
		}
		
		public function set zoom(value:Number):void 
		{
			invalidated = true;
			_zoom = value;
		}
		
		public function get rotation():Number
		{
			return _rotation;
		}
		
		public function set rotation(value:Number):void 
		{
			invalidated = true;
			_rotation = value;
		}
		
		public function get sceneWidth():Number 
		{
			return _sceneWidth;
		}
		
		public function get sceneHeight():Number 
		{
			return _sceneHeight;
		}
		
	}
}

package sl2d.renderer
{
	import away3d.core.managers.Context3DProxy;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.Debug;
	
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.geom.*;
	
	import sl2d.display.slBounds;
	import sl2d.display.slCamera;
	import sl2d.renderer.slBallRenderer;
	import sl2d.renderer.slRenderer;
	import sl2d.utils.HashTable;
	
	
	public class slAGALHelper 
	{
		private var _camara : slCamera;
		private var _indexBufferTable:HashTable = new HashTable();
		private var _vertexBufferTable:HashTable = new HashTable();
		private var _vertexBuffer : VertexBuffer3D;
		private var _context:Context3D;
		private var _stage3d:Stage3DProxy;
		
		public function slAGALHelper() : void 
		{
			
		}
		
		public function setContext(stage3d:Stage3DProxy, context:Context3D):void
		{
			_context = context;
			_stage3d = stage3d;
			Debug.assert(_stage3d.context3D == _context);
			_context.enableErrorChecking = Debug.context3DErrorCheck;
			initialize();
		}
		
		public function setCamera(camara : slCamera) : void 
		{
			_camara = camara;	
		}
		
		private function dispose():void
		{
			_vertexBufferTable.eachValue(
				function(vb:VertexBuffer3D):void
				{
					Context3DProxy.disposeVertexBuffer(vb);
				}
			);
			_vertexBufferTable.clear();
			
			_indexBufferTable.eachValue(
				function(ib:IndexBuffer3D):void
				{
					Context3DProxy.disposeIndexBuffer(ib);
				}
			);
			_indexBufferTable.clear();
			
			_vertexBuffer = null;
		}
		
		private function initialize():void
		{
			dispose();
			
			var list:Array = [1,2,4,8,16,32];		// 最多一次32个矩形
			
			// 创建VertexBuffer
			// 1----2
			// \    \
			// 3----4
			_vertexBuffer = Context3DProxy.createVertexBuffer(32*4, 4);
			var vertexData : Vector.<Number> = new Vector.<Number>; 
			for(var vbi:int=0;vbi<32;vbi++)
			{	
				// 1
				vertexData.push(vbi);		// x	第几个矩形
				vertexData.push(0);			// y	第几个顶点
				vertexData.push(1);			// z
				vertexData.push(1);			// w
				// 2
				vertexData.push(vbi);
				vertexData.push(1);
				vertexData.push(0);
				vertexData.push(1);
				// 3
				vertexData.push(vbi);
				vertexData.push(2);
				vertexData.push(1);
				vertexData.push(0);
				// 4
				vertexData.push(vbi);
				vertexData.push(2);
				vertexData.push(0);
				vertexData.push(0);
			}
			Context3DProxy.uploadVertexBufferFromVector(_vertexBuffer, vertexData, 0, 32*4);
			
			_vertexBufferTable.put(0, _vertexBuffer);
			// 创建IndexBuff
			var indexBuffer:IndexBuffer3D;
			for(var ibi:int=0; ibi<list.length; ibi++)
			{
				var unitCount:int = list[ibi];
				
				var indexVector:Vector.<uint> = new Vector.<uint>;
				for(var j:int = 0; j < unitCount; j++)
				{
					var vertexOffset:Number = j*4;
					indexVector.push(vertexOffset, vertexOffset+1, vertexOffset+2,vertexOffset+1,vertexOffset+2,vertexOffset+3);
				}
				
				indexBuffer =Context3DProxy.createIndexBuffer(unitCount * 6);
				
				Context3DProxy.uploadIndexBufferFromVector(indexBuffer, indexVector, 0, indexVector.length);
				
				_indexBufferTable.put(unitCount, indexBuffer);
			}
			
			
		}
		
		private var _renderer:slRenderer = new slRenderer();
		private var _ballRenderer:slBallRenderer = new slBallRenderer();
		
		public function readyRenderItem():void
		{
			_renderer.clear();
			_context.setCulling(Context3DTriangleFace.NONE);
			_context.setDepthTest(false,  Context3DCompareMode.LESS);
			_context.setVertexBufferAt(0, null, 0);
			_context.setVertexBufferAt(1, null, 0);
			_context.setVertexBufferAt(2, null, 0);
			_context.setVertexBufferAt(3, null, 0);
		}
		
		public function endRenderItem() : void 
		{
			_renderer.clear();
			_context.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_2);
			_context.setVertexBufferAt(1, null, 2, Context3DVertexBufferFormat.FLOAT_2);
			_context.setVertexBufferAt(2, null, 0);
			_context.setVertexBufferAt(3, null, 0);
			_context.setCulling(Context3DTriangleFace.BACK);			// 恢复
			_context.setTextureAt(0, null);
			_context.setTextureAt(1, null);
			_context.setTextureAt(2, null);
			_context.setTextureAt(3, null);
		}
		
		public function renderHpMpBall(item:slBounds, texture1:Texture, texture2:Texture, color1:Vector.<Number>, color2:Vector.<Number>, progress1:Number, progress2:Number):void
		{
			executeRender();
			_renderer.clear();
			_ballRenderer.render(_context, _vertexBufferTable, _indexBufferTable, item, texture1, texture2, color1, color2, progress1, progress2);
			readyRenderItem();
		}
		
		public function addItemToRender(item:slBounds):void
		{
			_renderer.addItem(item);
		}
		
		public function executeRender():void
		{
			_renderer.render(_context, _vertexBufferTable, _indexBufferTable);
		}
		
		
		
		
		
		
		

		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	}
}

/**
 *	3D设备的接口 
 */
package away3d.core.managers
{
	import away3d.animators.SkeletonAnimator;
	import away3d.arcane;
	import away3d.debug.Debug;
	
	import blade3d.profiler.Profiler;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.CubeTexture;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;

	use namespace arcane;
	
	public class Context3DProxy
	{
		private static var _stage3DProxy : Stage3DProxy;
		public static var _stage3DProxys : Vector.<Stage3DProxy> = new Vector.<Stage3DProxy>(4);
		
		static public var drawCall : uint = 0;		// drawcall 数
		static public var drawUICall : uint = 0;		// 3D UI 的drawcall数
		
		public static var vbCount : int = 0;			// vertexbuffer	个数
		public static var ibCount : int = 0;			// indexbuffer 个数
		public static var texCount : int = 0;			// 贴图数
		public static var programCount : int = 0;		// shader数
		
		// upload 次数
		public static var _vbUploadCount : int = 0;
		public static var _ibUploadCount : int = 0;
		public static var _bmpUploadCount : int = 0;
		
		public static function setStage3DProxy(stage3d:Stage3DProxy, index:int=0):void
		{
			if(index == 0)
				_stage3DProxy = stage3d;
//			else
//				Debug.assert(false, "more stage");
			_stage3DProxys[index] = stage3d;
		}
		public static function get stage3DProxy() : Stage3DProxy {return _stage3DProxy;}
		public static function get context3D() : Context3D {return _stage3DProxy._context3D;}
		
		public static function createProgram(stageIndex:int = 0) : Program3D
		{
			programCount++;
			return _stage3DProxys[stageIndex]._context3D.createProgram();
		}
		
		public static function disposeProgram(p : Program3D) : void
		{
			p.dispose();
			programCount--;
		}
		
		public static function createVertexBuffer(numVertices:int, data32PerVertex:int) : VertexBuffer3D
		{
			vbCount++;
			return _stage3DProxy._context3D.createVertexBuffer(numVertices, data32PerVertex);
		}
		
		public static function disposeVertexBuffer(vb : VertexBuffer3D) : void
		{
			vb.dispose();
			vbCount--;
		}
		
		public static function createIndexBuffer(numIndices:int) : IndexBuffer3D
		{
			ibCount++;
			return _stage3DProxy._context3D.createIndexBuffer(numIndices);
		}
		
		public static function disposeIndexBuffer(ib : IndexBuffer3D) : void
		{
			ib.dispose();
			ibCount--;
		}
		
		public static function createTexture(width:int, height:int, format:String, optimizeForRenderToTexture:Boolean):Texture
		{
			texCount++;
			return _stage3DProxy._context3D.createTexture(width, height, format, optimizeForRenderToTexture);
		}
		
		public static function createCubeTexture(size:int, format:String, optimizeForRenderToTexture:Boolean):CubeTexture
		{
			texCount++;
			return _stage3DProxy._context3D.createCubeTexture(size, format, optimizeForRenderToTexture);
		}
		
		public static function disposeTexture(texture:TextureBase):void
		{
			texture.dispose();
			texCount--;
		}
		
		public static function drawTriangles(indexBuffer:IndexBuffer3D, firstIndex:int = 0, numTriangles:int = -1):void
		{
			Profiler.start("drawTriangles");
			drawCall++;
			_stage3DProxy._context3D.drawTriangles(indexBuffer, firstIndex, numTriangles);
			Profiler.end("drawTriangles");
		}
		
		public static function uploadVertexBufferFromVector(vb : VertexBuffer3D, data:Vector.<Number>, startVertex:int, numVertices:int) : void
		{
			vb.uploadFromVector(data, startVertex, numVertices);
			_vbUploadCount++;
		}
		
		public static function uploadIndexBufferFromVector(ib : IndexBuffer3D, data:Vector.<uint>, startOffset:int, count:int) : void
		{
			ib.uploadFromVector(data, startOffset, count);
			_ibUploadCount++;
		}
		
		public static function uploadTextureFromBitmapData(tex : Texture, bmpData : BitmapData, miplevel:uint = 0) : void
		{
			tex.uploadFromBitmapData(bmpData, miplevel);
			_bmpUploadCount++;
		}
		
		public static function reset():void
		{
			drawCall = drawUICall = 0;
			_vbUploadCount = _ibUploadCount = _bmpUploadCount = 0;
			SkeletonAnimator.calcTimes = 0;
		}
		
	}
}
package sl2d.renderer
{
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.Debug;
	
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	
	import sl2d.shader.slProgram;
	import sl2d.utils.HashTable;
	import sl2d.utils.HashVector;

	public class slRenderer
	{
		private var _context:Context3D;
		private var _texture:Texture;
		private var _shader:slProgram;
		private var _color:Vector.<Number>;
		private var _indexTable:HashTable;
		private var _vertexTable:HashTable;
		
		private var _itemsAtSameVDepth:HashVector = new HashVector();
		private var _renderGroupList:Vector.<RenderGroup> = new Vector.<RenderGroup>();
		private var _renderGroupRecycler:Vector.<RenderGroup> = new Vector.<RenderGroup>();
		//灰度
		private var _grayColor:Vector.<Number> = Vector.<Number>([0.3, 0.59, 0.11, 1]);
		
		
		public function clear():void{
			for each(var group:RenderGroup in _renderGroupList){
				_renderGroupRecycler.push(group);
			}
			_renderGroupList.length = 0;
			_itemsAtSameVDepth.clear();
			_texture = null;
			_shader = null;
			_color = null;
		}
		
		public function slRenderer()
		{
			
		}
		
		public function addItem(item:slBounds):void{
			var vDepth:int = item.vDepth;
			var list:Vector.<Object> = _itemsAtSameVDepth.getValueByKey(vDepth);
			if(list == null){
				list = new Vector.<Object>();
				_itemsAtSameVDepth.put(vDepth, list);
			}
			list.push(item);
		}
		
		public function render(context:Context3D, vertexTabel:HashTable, indexTable:HashTable):void{
			_context = context;
			_indexTable = indexTable;
			_vertexTable = vertexTabel;
//			Profiler.start("setProgramConstantsFromVector");
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, _grayColor);
//			Profiler.end("setProgramConstantsFromVector");
//			Profiler.start("sort render");
			//按照从0开始的纵向深度，绘制对象。
			var list:Vector.<Object> = _itemsAtSameVDepth.getValues();
			var keyList:Vector.<Object> = _itemsAtSameVDepth.getKeys();
			var vDepthCount:int = list.length;
			var vDepth:int;
			//生成可以一次性绘制的列表
			var i:int;
			var vList:Array = [];
			for(i = 0; i < vDepthCount; i ++){
				vDepth = int(keyList[i]);
				vList.push(vDepth);
			}
			vList.sort();
			for(i = 0; i < vDepthCount; i ++){
				vDepth = vList[i];
				getRenderList(_itemsAtSameVDepth.getValueByKey(vDepth) as Vector.<Object>, vDepth);
			}
//			Profiler.end("sort render");
			//一组一组的绘制
			var groupCount:int = _renderGroupList.length;
			for(i = 0; i < groupCount; i ++){
				renderGroup(_renderGroupList[i]);
			}
		}
		
		
		
		private function getRenderList(list:Vector.<Object>, vDepth:int):void{
			var group:RenderGroup;
			var item:slBounds;
			var count:int = list.length;
			
			var itemColor:Vector.<Number>;
			var itemShader:slProgram;
			var itemTexture:Texture;
			var itemHDepth:int;
			
			
			var groupColor:Vector.<Number>;
			var groupTexture:Texture;
			var groupShader:slProgram;
			var groupHDepth:int;
			
			var insertToGroup:RenderGroup;
			var groupCount:int;
			var groupList:Array = [];
			for(var i:int = 0; i < count; i ++){
				item = list[i] as slBounds;
				if(item == null)
					continue;
				itemColor = item.colorData;
				itemShader = item.shader;
				itemTexture = item.cacheTexture;
				itemHDepth = item.hDepth;
				if(itemColor == null || itemShader == null || itemTexture == null)
					continue;
				
				insertToGroup = null;
				groupCount = groupList.length;
				for(var j:int = 0; j < groupCount; j ++){
					group = groupList[j];
					groupColor = group.colorInfo;
					groupTexture = group.texture;
					groupShader = group.shader;
					groupHDepth = group.hDepth;
					
					if(	groupTexture == itemTexture			//texture 相同
						&& groupShader == itemShader		//shader 相同
						&& groupHDepth == itemHDepth		//hdepth 相同
						&& groupColor[0] == itemColor[0]		//r	相同
						&& groupColor[1] == itemColor[1]	//g	相同
						&& groupColor[2] == itemColor[2]	//b	相同
						&& groupColor[3] == itemColor[3]	//a	相同
						
					){
						//找到了可以插入到某个组中。
						insertToGroup = group;
						break;
					}
				}
				
				//如果没有找到，新增一个对象。
				if(insertToGroup == null){
					insertToGroup = _renderGroupRecycler.shift();
					if(insertToGroup == null){
						insertToGroup = new RenderGroup();
					}else{
						insertToGroup.boundsInfo.length = 0;
					}
					insertToGroup.hDepth = itemHDepth;
					insertToGroup.colorInfo = itemColor;
					insertToGroup.shader = itemShader;
					insertToGroup.texture = itemTexture;
					insertToGroup.boundsInfo = new Vector.<Vector.<Number>>();
					groupList.push(insertToGroup);
				}
				
				insertToGroup.boundsInfo.push(item.boundsInfo);
			}
			groupList.sortOn("hDepth", Array.NUMERIC | Array.DESCENDING);
			groupList.sortOn("hDepth", Array.NUMERIC | Array.CASEINSENSITIVE);
//			groupList.sortOn("hDepth", Array.NUMERIC);
			count = groupList.length;
			
			for(i = 0; i < count; i ++){
				_renderGroupList.push(groupList[i]);
			}
				
			
		}
		
		
		
		private function renderGroup(group:RenderGroup):void{
			//换一个顶点和uv坐标的缓冲。。
			var color:Vector.<Number> = group.colorInfo;
			var texture:Texture = group.texture;
			var shader:slProgram = group.shader;
			if(texture != _texture){
				_texture = texture;
				_context.setTextureAt(0, _texture);
			}
			if(_shader != shader){
				_shader = shader;
				_context.setProgram(_shader.program);
				_context.setBlendFactors(_shader.blendSrc, _shader.blendDst);
			}
			if(color != _color){
				_color = color;
				_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _color);
			}
			//判断应该选择哪一个indexBuffer和vertexBuffer
			while(group.boundsInfo.length > 0){
				var unitCount:int = getUnitCount(group.boundsInfo.length);
				doRenderUnionSegment(group.boundsInfo.splice(0, unitCount), unitCount);
			}
		}
		
		private function getUnitCount(value:int):int
		{
			// 最大一次渲染32个矩形
			if(value > 32)
				value = 32;
			else if(value > 0)
				value = Math.pow(2, Math.ceil(Math.LOG2E * Math.log(value)));
			
			return value;
		}
		
		// v0-v3 camera 矩阵
		// v4 shader用常量
		// v5-v31 保留
		// v32-v127 提供32个矩形，每个矩形使用3个vc。分别用做 pos uv 保留
		
		private var _vertexVector:Vector.<Number> = new Vector.<Number>();
		
		private var _vertexVectorVc0:Vector.<Number> = new Vector.<Number>(4, true);
		private var _vertexVectorVc1:Vector.<Number> = new Vector.<Number>(4, true);
		private var _vertexVectorVc2:Vector.<Number> = new Vector.<Number>(4, true);		// 保留
		
		private var _vertexConstantVc0:Vector.<Number> = Vector.<Number>([32, 3, 1, 0]);
		
		private function doRenderUnionSegment(vList:Vector.<Vector.<Number>>, unitCount:int):void
		{
			if(vList.length == 0 || unitCount == 0) return;
			Profiler.start("doRenderUnionSegment");
			//赋值数据
			var vertexBuffer:VertexBuffer3D = _vertexTable.getValue(0);
			var indexBuffer:IndexBuffer3D = _indexTable.getValue(unitCount);
						
			// 计算各矩形的顶点
			var boundsCount:int = vList.length;		// 矩形数
			
			for(var i:int=0; i<unitCount; i++)
			{	
				_vertexVectorVc2[0] = _vertexVectorVc2[1] = _vertexVectorVc2[2] = _vertexVectorVc2[3] = 0;
				if(i<boundsCount)
				{
					_vertexVector = vList[i];
					// 位置
					Debug.assert(_vertexVector[0] == _vertexVector[4*2]);
					Debug.assert(_vertexVector[1] == _vertexVector[4*1+1]);
					Debug.assert(_vertexVector[4*3] == _vertexVector[4*1]);
					Debug.assert(_vertexVector[4*3+1] == _vertexVector[4*2+1]);
					_vertexVectorVc0[0] = _vertexVector[0];
					_vertexVectorVc0[1] = _vertexVector[1];
					_vertexVectorVc0[2] = _vertexVector[4*3];
					_vertexVectorVc0[3] = _vertexVector[4*3+1];
					// uv
					_vertexVectorVc1[0] = _vertexVector[2];
					_vertexVectorVc1[1] = _vertexVector[3];
					_vertexVectorVc1[2] = _vertexVector[4*3+2];
					_vertexVectorVc1[3] = _vertexVector[4*3+3];
					
					_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 32+i*3, _vertexVectorVc0, 1);
					_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 32+i*3+1, _vertexVectorVc1, 1);
					_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 32+i*3+2, _vertexVectorVc2, 1);
				}
				else
				{
					_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 32+i*3, _vertexVectorVc2, 1);
					_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 32+i*3+1, _vertexVectorVc2, 1);
					_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 32+i*3+2, _vertexVectorVc2, 1);
				}
			}
			// 设置常量
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, _vertexConstantVc0, 1);
			
//			var boundsCount:int = vList.length;
//			
//			var position:int;
//			_vertexVector.length = 0;
//			_vertexVector.length = unitCount * 16;
//			for(var i:int = 0; i < boundsCount; i ++){
//				vertexVector = vList[i];
//				for(var j:int = 0; j < 16; j ++){
//					_vertexVector[position + j] = vertexVector[j];
//				}
//				position += 16;
//			}

			//可以使用
//			Profiler.start("uploadFromVector");
//			Stage3DProxy.uploadVertexBufferFromVector(vertexBuffer, _vertexVector, 0, unitCount * 4);
//			Profiler.end("uploadFromVector");
			
//			Profiler.start("drawTriangles");
			_context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
//			_context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
//			if(View3D._drawUICount <= blUIEditor.arg1 && View3D._drawUICount != blUIEditor.arg2)
				_context.drawTriangles(indexBuffer, 0, boundsCount * 2);
			View3D._drawUICount++;
//			Profiler.end("drawTriangles");
			
			Profiler.end("doRenderUnionSegment");
			
		}
		
		
		
	}
}




import flash.display3D.textures.Texture;

import sl2d.shader.slProgram;

class RenderGroup{
	public var texture:Texture;
	public var colorInfo:Vector.<Number>;
	public var boundsInfo:Vector.<Vector.<Number>>;
	public var shader:slProgram;
	public var hDepth:int;
	public function RenderGroup(){
		
	}
}





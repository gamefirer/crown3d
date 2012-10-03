/**
 *	编辑器用，辅助对象 
 */
package away3d.entities
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.debug.Debug;
	import away3d.events.Object3DEvent;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTextureCache;
	
	import blade3d.effect.BlEffect;
	import blade3d.resource.BlImageResource;
	import blade3d.resource.BlModelResource;
	import blade3d.resource.BlResourceManager;
	import blade3d.utils.BlEditorUtils;
	
	import flash.display3D.Context3DCompareMode;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	public class EditHelper extends Mesh
	{
		private var _editObj:ObjectContainer3D;
		private var _type:int;
		
		static private var _EditorList : Vector.<ObjectContainer3D> = new Vector.<ObjectContainer3D>;
		
		static public function allVisible(val:Boolean):void
		{
			for each(var obj : ObjectContainer3D in _EditorList)
			{
				obj.visible = val;
			}
		}
		
		public function EditHelper(obj:ObjectContainer3D)
		{
			editObject = obj;
			
			var material : TextureMaterial;
			var imageRes : BlImageResource;
			// 贴图灯
			if(obj is Sprite3D && Sprite3D(obj).castsLightMap)
			{
				imageRes = BlResourceManager.instance().findImageResource(BlEditorUtils.texLight_bmp);
			}
			// 特效
			else if(obj is BlEffect)
			{
				imageRes = BlResourceManager.instance().findImageResource(BlEditorUtils.effect_bmp);
			}
			else
				Debug.assert(false, "帮助物体错误");
			
			material = new TextureMaterial(BitmapTextureCache.instance().getTexture(imageRes.bmpData));
			
			material.colorTransform = new ColorTransform;		// 拾取变色用
			
			var modelRes : BlModelResource;
			modelRes = BlResourceManager.instance().findModelResource(BlEditorUtils.box_mesh);
			
			super(modelRes.geo, material);
			
			this.renderLayer = Entity.Editor_Layer;
			material.depthCompareMode = Context3DCompareMode.ALWAYS;
			
			position = editObject.scenePosition;
			
			_EditorList.push(this);
		}
		
		public function set editObject(obj:ObjectContainer3D):void
		{
			if(_editObj)
			{
				_editObj.removeEventListener(Object3DEvent.POSITION_CHANGED, onPosChange);
				_editObj.removeEventListener(Object3DEvent.DISPOSE, onObjDispose);
			}
			_editObj = obj;
			if(_editObj)
			{
				_editObj.addEventListener(Object3DEvent.POSITION_CHANGED, onPosChange);
				_editObj.addEventListener(Object3DEvent.DISPOSE, onObjDispose);
			}
			
		}
		
		public function get editObject() : ObjectContainer3D {return _editObj;}
		
		private function onPosChange(evt:Event):void
		{
			position = editObject.scenePosition;
		}
		
		private function onObjDispose(evt:Event):void
		{
			_EditorList.splice(_EditorList.indexOf(this), 1);
			
			editObject = null;
			dispose();
		}
		
	}
}


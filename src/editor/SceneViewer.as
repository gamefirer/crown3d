/**
 *	场景浏览器 
 */
package editor
{
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;
	import away3d.primitives.WireframePlane;
	
	import blade3d.BlConfiguration;
	import blade3d.BlEngine;
	import blade3d.editor.BlEditorManager;
	import blade3d.profiler.Profiler;
	import blade3d.scene.BlSceneManager;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Vector3D;
	
	import sl2d.slWorld;
	
	[SWF(backgroundColor="#ffffff", frameRate="60", quality="LOW")]
	public class SceneViewer extends Sprite
	{
		public function SceneViewer()
		{
			super();
			// 系统配置
			BlConfiguration.editorMode = true;
			BlConfiguration.debug();
//			BlConfiguration.release();

			slWorld.RenderUI = true;
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(e:Event):void
		{
			InitEngine();
		}
		
		private function InitEngine():void
		{
			addChild(BlEngine.init(this, onInitEngine));
		}
		
		private function onInitEngine():void
		{
			// 显示场景编辑界面
//			BlEditorManager.instance().showResourceEditor(true);
//			BlEditorManager.instance().showSceneEditor(true);
			BlEditorManager.instance().showEffectEditor(true);
			
			
			if(BlEditorManager.instance()._sceneEditor)
				BlEditorManager.instance()._sceneEditor.switchAxis("网格");
			
			
			
		}
		
		
		
	}
}
package editor
{
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.base.Geometry;
	import away3d.core.partition.Partition3D;
	import away3d.debug.AwayStats;
	import away3d.debug.Debug;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.PrimitiveBase;
	import away3d.primitives.WireframePlane;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;
	
	import blade3d.BlEngine;
	import blade3d.camera.BlCameraManager;
	import blade3d.editor.BlEditorManager;
	import blade3d.profiler.Profiler;
	import blade3d.scene.BlSceneManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	
	import org.aswing.AsWingManager;
	import org.aswing.BorderLayout;
	import org.aswing.Insets;
	import org.aswing.JButton;
	import org.aswing.JPanel;
	import org.aswing.JWindow;
	import org.aswing.SoftBox;
	import org.aswing.SolidBackground;
	import org.aswing.UIManager;
	import org.aswing.border.EmptyBorder;
	import org.aswing.event.AWEvent;

	[SWF(backgroundColor="#ffffff", frameRate="60", quality="LOW")]
	public class EffectViewer extends Sprite
	{ 
		
		private var _view:View3D;
		private var _camController:HoverController;
		
		private var _light:DirectionalLight;
		private var _lightPicker:StaticLightPicker;
		
		private var _testMaterial:TextureMaterial;
		private var _ground:Mesh;
		
		private var _openBtn:JButton;			// 打开
		
		
		public function EffectViewer() 
		{
//			Profiler.isProfiler = false;
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(e:Event):void
		{
			InitUI();
			InitEngine();
			
		}
		
		private function InitEngine():void
		{
			addChild(BlEngine.init(this, onInitEngine));
		}
		
		private function InitUI():void
		{
			
		}
		
		private function onInitEngine():void
		{
			BlEditorManager.instance().showEffectEditor(true);
			BlEditorManager.instance()._sceneEditor.switchAxis("坐标轴");
						
			// 选择camera
//			BlCameraManager.instance().switchCameraByName(BlCameraManager.CAMERA_NAME_THIRD);
			
		}
		
		
		
	}
};
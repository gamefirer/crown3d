package editor
{
	import blade3d.BlEngine;
	import blade3d.editor.BlEditorManager;
	import blade3d.profiler.Profiler;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	[SWF(backgroundColor="#ffffff", frameRate="60", quality="LOW")]
	public class CharacterViewer extends Sprite
	{
		public function CharacterViewer()
		{
			super();
			
			Profiler.isProfiler = true;
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
			BlEditorManager.instance().showAvatarEditor(true);
			
		}
		
	}
}
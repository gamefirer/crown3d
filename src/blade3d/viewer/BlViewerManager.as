/**
 *	3D视图管理器 
 */
package blade3d.viewer
{
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	
	import blade3d.BlManager;
	
	public class BlViewerManager extends BlManager
	{
		static private var _instance : BlViewerManager;
		
		private var _stage3DProxy : Stage3DProxy;
		private var _viewers : Vector.<BlViewer> = new Vector.<BlViewer>;
		
		public function viewerNumber() : uint {return _viewers.length;}
		public function viewer(index:uint) : BlViewer {return _viewers[index];}
		
		public function BlViewerManager()
		{
			super();
		}
		
		static public function instance() : BlViewerManager
		{
			if(!_instance)
				_instance = new BlViewerManager;
			return _instance;
		}
		
		public function init(view:View3D, callBack:Function):Boolean
		{
			_stage3DProxy = view.stage3DProxy;
			
			callBack(this);
			return true;
		}
		
		public function createViewer(width:uint, height:uint) : BlViewer
		{
			var viewer : BlViewer = new BlViewer;
			viewer.stage3DProxy = _stage3DProxy;
			
			viewer.width = width;
			viewer.height = height;
			
			_viewers.push(viewer);
			
			return viewer;
		}
		
		public function destoryViewer(viewer:BlViewer):void
		{
			viewer.dispose();
			_viewers.splice( _viewers.indexOf(viewer), 1);
		}
		
		public function render(time:uint, deltaTime:uint):void
		{
			for(var i:int=0; i<_viewers.length; i++)
			{
				if(_viewers[i].visible)
					_viewers[i].render(time, deltaTime);
			}
		}
		
	}
}
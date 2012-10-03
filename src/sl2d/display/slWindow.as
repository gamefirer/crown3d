/**
 *	3D ui的根节点基类，应用层用此类继承 
 * 	支持排版
 */
package sl2d.display
{
	
	public class slWindow extends slGroup
	{
		private var _childWindows : Vector.<slWindow> = new Vector.<slWindow>;
		
		public function slWindow()
		{
		}
		
		public function initializeData():void
		{
			
		}
		
		override public function addChild(child:slObject) : slObject
		{
			var retObj : slObject = super.addChild(child);
			
			if(retObj && retObj is slWindow)
				_childWindows.push(retObj);
			
			return retObj;
		}
		
		override public function removeChild(child:slObject) : slObject
		{
			var retObj : slObject = super.removeChild(child);
			
			if(retObj && retObj is slWindow)
			{
				_childWindows.splice(_childWindows.indexOf(retObj), 1);
			}
			
			return retObj;
		}
		
		public function clearView():void
		{
			
		}
		
		public function onResizeView(rectWidth:int, rectHeight:int):void
		{
			for(var i:int = 0;i < _childWindows.length; i++)
				_childWindows[i].onResizeView(rectWidth, rectHeight);
		}
		
		
		
	
	}
}
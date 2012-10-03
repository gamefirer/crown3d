package sl2d.utils
{
	public class TweenVector
	{
		private var _current:Vector.<Object> = new Vector.<Object>();
		private var _recycle:Vector.<Object> = new Vector.<Object>();
		public function TweenVector()
		{
		}
		
		public function getItem():*{
			var item:* = _recycle.shift();
			if(item){
				_current.push(item);
			}
			return item;
		}
		
		public function putItem(item:Object):void{
			var index:int = _current.indexOf(item);
			if(index == -1){
				_current.push(item);
			}
			index = _recycle.indexOf(item);
			_recycle.splice(index, 1);
			
		}
		
		
		public function recycleItem(item:Object):void{
			var index:int = _current.indexOf(item);
			_current.splice(index, 1);
			index = _recycle.indexOf(item);
			if(index == -1){
				_recycle.push(item);
			}
		}
		
		public function get current():Vector.<Object>{
			return _current;
		}
		
		public function get reverse():Vector.<Object>{
			return _recycle;
		}
		
	}
}
package sl2d.utils
{
	public class HashVector
	{
		
		private var _keys : Vector.<Object> = new Vector.<Object>();
		private var _values : Vector.<Object> = new Vector.<Object>();
		public function HashVector()
		{
		}
		
		public function getIndexByKey(key:Object):int{
			return _keys.indexOf(key);
		}
		
		public function getValueByKey(key:Object):* {
			var index:int = getIndexByKey(key);
			if(index > -1){
				return _values[index];
			}
			return null;
		}
		
		public function put(key:Object, value:Object):Object{
			if(key == null) return null;
			var old:Object = remove(key);
			_keys.push(key);
			_values.push(value);
			return old;
		}
		public function remove(key:Object):Object{
			var index:int = getIndexByKey(key);
			var item:Object;
			if(index > -1){
				item = _values[index];
				_keys.splice(index, 1);
				_values.splice(index, 1);
			}
			return item;
		}
		public function getValues():Vector.<Object>{
			return _values;
		}
		
		public function getKeys():Vector.<Object>{
			return _keys;
		}
		public function clear():void{
			_values.length = 0;
			_keys.length = 0;
		}
	}
}
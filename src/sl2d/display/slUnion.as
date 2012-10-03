package sl2d.display
{
	import flash.display3D.textures.Texture;
	import flash.utils.Dictionary;
	
	import sl2d.shader.slProgram;
	import sl2d.texture.slTexture;

	public class slUnion extends slGroup
	{
		protected var _unionTexture:slTexture;
		protected var _unionShader:slProgram = slShader.Alpha;
		public function slUnion()
		{
		}
		
		override public function collectRenderer():void{
			collectUnion();
		}
		
		protected function collectUnion():void{
			if(visible == false)
				return;
			if(_unionTexture == null || _unionTexture.validate == false || _unionShader == null)
				return;
			var textureDic:Dictionary = sortBoundsByTexture();
			var itemList:Vector.<slBounds>;
			var item:slBounds;
			for each(itemList in textureDic){
				for each(item in itemList){
					slGlobal.Helper.addItemToRender(item);
				}
			}
		}
		
		private function sortBoundsByTexture():Dictionary{
			var dic:Dictionary = new Dictionary();
			var item:slBounds;
			var itemList:Vector.<slBounds>;
			var texture:Texture;
			for(var i:int = 0; i < _numChildren; i ++){
				item = _children[i];
				texture = item.cacheTexture;
				itemList = dic[texture];
				if(itemList == null){
					itemList = new Vector.<slBounds>;
					dic[texture] = itemList;
				}
				itemList.push(item);
			}
			
			return dic;
			
		}
		
		
	}
}
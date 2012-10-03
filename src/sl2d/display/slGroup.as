/**
 *	包含子对象的3d ui 
 */
package sl2d.display
{
    public class slGroup extends slSprite 
	{
        protected var _children:Array = [];
		protected var _numChildren : int = 0;

		public function get numChildren() : int 
		{
			return _numChildren;
		}
		
        public function slGroup() : void 
		{

		}
		
		//NODE FUNCTIONS
        public function addChild(child:slObject) : slObject
		{
			if(child == null) 
				return child;
			if(child.parent)
			{
				child.parent.removeChild(child);
			}
			child.parent = this;
			_children.push(child);
			_numChildren = _children.length;
			return child;
			
        }
		public function get children():Array
		{
			return _children;
		}
		
		
		override internal function setTextureDirty():void
		{
			var child : slObject;
			for(var i : int = 0; i < _numChildren; i++) 
			{
				child = _children[i];
				child.setTextureDirty();
			}
			
			super.setTextureDirty();
		}
		
		
        public function removeChild(child:slObject) : slObject 
		{
			var index:int = _children.indexOf(child);
			if(index > -1)
			{
				_children.splice(index, 1);
				_numChildren = _children.length;
				child.parent = null;
			}
			if(child)
				child.setTextureDirty();
			return child;
        }
		
		protected function sortChildren():void
		{
			//默认是不排序
		}
		override public function update() : void 
		{
			//更新自己
			preUpdate();
			updatePos();
			updateAnim();
			bindFrame();
			setOffset();
			afterUpdate();
			
			//更新孩子
			var child : slObject;
			for(var i : int = 0; i < _numChildren; i++) 
			{
				child = _children[i];
				child.setGlobalOffset(_globalX, _globalY);
				child.update();
			}
			//更新完之后排序。
			sortChildren();
		}
		
		override public function validateProperty():void
		{
			//更新自己
			super.validateProperty();
			//更新孩子
			var child : slObject;
			for(var i : int = 0; i < _numChildren; i++) 
			{
				child = _children[i];
				child.validateProperty();
			}
		}
		override public function collectRenderer():void
		{
			if(visible && insideViewPort)
			{
				//画自己
				super.collectRenderer();
				//画孩子
				var child : slObject;
				for(var i : int = 0; i < _numChildren; i++)
				{
					child = _children[i];
					//没有离开视窗。
					if(child.insideViewPort) 
						child.collectRenderer();
				}
			}
		}
		
		override public function onContextChanged():void
		{
			super.onContextChanged();
			var child : slObject;
			for(var i : int = 0; i < _numChildren; i++) 
			{
				child = _children[i];
				child.onContextChanged();
			}
		}
		
		override public function dispose():void
		{
			var child:slObject;
			for each(child in _children)
			{
				if(child)
					child.dispose();
			}
			super.dispose();
			
			removeAllChildren();
		}
		
		public function removeAllChildren():void
		{
			while(_numChildren != 0)
			{
				removeChild(_children[_numChildren - 1]);
			}
		}
		
		
		override internal function get insideViewPort():Boolean
		{
			return true;
		}
		
		
		
	}
}


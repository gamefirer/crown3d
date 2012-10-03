/**
 *	输入管理器 
 */
package blade3d.io
{
	import away3d.containers.View3D;
	import away3d.debug.Debug;
	
	import blade3d.BlManager;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class BlInputManager extends BlManager
	{
		static private var _instance : BlInputManager;
		
		static private var _view : View3D;
		
		static private var _isTextFieldFocus:Boolean;		// 是否在文本输入框
		static private var _keyDownList : Vector.<Boolean> = new Vector.<Boolean>(400, true);	// 键盘码
		
		static public function mouseX() : Number { return _view.mouseX; }
		static public function mouseY() : Number { return _view.mouseY; }
		
		
		
		public function BlInputManager()
		{
			if(_instance)
				Debug.error("BlInputManager error");
		}
		
		static public function instance() : BlInputManager
		{
			if(!_instance)
				_instance = new BlInputManager();
			return _instance;
		}
		
		public function init(view:View3D, callBack:Function):Boolean
		{
			_view = view;
			
			// 键盘
			_view.stage.addEventListener(FocusEvent.FOCUS_IN, onFocusChange);
			_view.stage.addEventListener(FocusEvent.FOCUS_OUT, onFocusChange);
			_view.stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, onFocusChange);
			_view.stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusChange);
			_view.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_view.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_view.stage.addEventListener(MouseEvent.ROLL_OUT, onMouseLeave);
			_view.stage.addEventListener(Event.DEACTIVATE, onMouseLeave);
			
			// 鼠标
			_view.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_view.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_view.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_view.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_view.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_view.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			_view.addEventListener(MouseEvent.CLICK, onMouseClick);
			_view.addEventListener(MouseEvent.DOUBLE_CLICK, onMouseDouble);
			_view.addEventListener(MouseEvent.ROLL_OUT, onLostMouse);
			_view.addEventListener(Event.DEACTIVATE, onLostMouse);
			
			
			
			callBack(this);
			return true;
		}
		
		/**
		 *	键盘事件	 
		 */
		public static function keyIsDown(keyCode : int) : Boolean 
		{
			if(_isTextFieldFocus)
				return false;
			return _keyDownList[keyCode];
		}
		
		private static function onFocusChange(e:Event) : void
		{
//			Debug.log("onFocusChange");
			_isTextFieldFocus = (_view.stage.focus is TextField);
			if(_isTextFieldFocus)
				_keyDownList =  new Vector.<Boolean>(400, true);
		}
		//丢失焦点要清空列表！
		private static function onMouseLeave(e:Event):void
		{
			_keyDownList =  new Vector.<Boolean>(400, true);
		}
		
		// key down
		private static var keyDownHandler : Vector.<Function> = new Vector.<Function>();
		public static function onKeyDown(evt : KeyboardEvent) : void 
		{
			if(_isTextFieldFocus)
				return;
//			Debug.log("onKeyDown");
			_keyDownList[evt.keyCode] = true;
			var len : uint = keyDownHandler.length;
			for(var i : int; i < len; i++)
			{
				var f : Function = keyDownHandler[i];
				if(!f.call(null, evt.keyCode))
					break;
			}
		}
		
		public static function addKeyDownHandler(f : Function) : void 
		{
			if(keyDownHandler.indexOf(f) < 0)
				keyDownHandler.push(f);
		}
		
		public static function removeKeyDownHandler(f : Function) : void 
		{
			var index : int = keyDownHandler.indexOf(f);
			if(index >= 0)
				keyDownHandler.splice(index, 1);
		}
		
		// key up
		private static var keyUpHandler : Vector.<Function> = new Vector.<Function>();
		public static function onKeyUp(evt : KeyboardEvent) : void 
		{
			if(_isTextFieldFocus)
				return;
//			Debug.log("onKeyUp");
			_keyDownList[evt.keyCode] = false;
			var len : uint = keyUpHandler.length;
			for(var i : int; i < len; i++)
			{
				var f : Function = keyUpHandler[i];
				if(!f.call(null, evt.keyCode))
					break;
			}
		}
		
		public static function addKeyUpHandler(f : Function) : void
		{
			if(keyUpHandler.indexOf(f) < 0)
				keyUpHandler.push(f);
		}
		
		public static function removeKeyUpHandler(f : Function) : void 
		{
			var index : int = keyUpHandler.indexOf(f);
			if(index >= 0)
				keyUpHandler.splice(index, 1);
		}
		
		/**
		 *	鼠标事件 
		 */		
		
		// 鼠标左键按下
		private static var mouseDownHandler : Vector.<Function> = new Vector.<Function>();
		public static function onMouseDown(evt : MouseEvent) : void {
			//Debug.log("onMouseDown");
			var len : uint = mouseDownHandler.length;
			for(var i : int; i < len; i++){
				var f : Function = mouseDownHandler[i];
				if(!f(evt))
					break;
			}
		}
		
		public static function addMouseDownHandler(f : Function) : void {
			if(mouseDownHandler.indexOf(f) < 0){
				mouseDownHandler.push(f);
			}
		}
		
		public static function removeMouseDownHandler(f : Function) : void {
			var index : int = mouseDownHandler.indexOf(f);
			if(index >= 0){
				mouseDownHandler.splice(index, 1);
			}
		}
		// 鼠标左键放开
		private static var mouseUpHandler : Vector.<Function> = new Vector.<Function>();
		public static function onMouseUp(evt : MouseEvent) : void {
			//Debug.log("onMouseUp");
			var len : uint = mouseUpHandler.length;
			for(var i : int; i < len; i++){
				var f : Function = mouseUpHandler[i];
				if(!f(evt))
					break;
			}
		}
		
		public static function addMouseUpHandler(f : Function) : void {
			if(mouseUpHandler.indexOf(f) < 0){
				mouseUpHandler.push(f);
			}
		}
		
		public static function removeMouseUpHandler(f : Function) : void {
			var index : int = mouseUpHandler.indexOf(f);
			if(index >= 0){
				mouseUpHandler.splice(index, 1);
			}
		}
		// 鼠标移动
		private static var mouseMoveHandler : Vector.<Function> = new Vector.<Function>();
		public static function onMouseMove(evt : MouseEvent) : void {
//			//Debug.log("onMouseMove");
			var len : uint = mouseMoveHandler.length;
			for(var i : int; i < len; i++){
				var f : Function = mouseMoveHandler[i];
				if(!f(evt))
					break;
			}
		}
		
		public static function addMouseMoveHandler(f : Function) : void {
			if(mouseMoveHandler.indexOf(f) < 0){
				mouseMoveHandler.push(f);
			}
		}
		
		public static function removeMouseMoveHandler(f : Function) : void {
			var index : int = mouseMoveHandler.indexOf(f);
			if(index >= 0){
				mouseMoveHandler.splice(index, 1);
			}
		}
		// 鼠标丢失
		private static var mouseLostHandler : Vector.<Function> = new Vector.<Function>();
		public static function onLostMouse(evt:Event):void {
			//Debug.log("onLostMouse");
			var len : uint = mouseLostHandler.length;
			for(var i : int; i < len; i++){
				var f : Function = mouseLostHandler[i];
				if(!f(evt))
					break;
			}
		}
		
		public static function addMouseLostHandler(f : Function) : void {
			if(mouseLostHandler.indexOf(f) < 0){
				mouseLostHandler.push(f);
			}
		}
		
		public static function removeMouseLostHandler(f : Function) : void {
			var index : int = mouseLostHandler.indexOf(f);
			if(index >= 0){
				mouseLostHandler.splice(index, 1);
			}
		}
		// 鼠标出界
		private static var mouseOutHandler : Vector.<Function> = new Vector.<Function>();
		public static function onMouseOut(evt:Event):void		{
			//Debug.log("onMouseOut");
			var len : uint = mouseOutHandler.length;
			for(var i : int; i < len; i++){
				var f : Function = mouseOutHandler[i];
				if(!f(evt))
					break;
			}
		}
		
		public static function addMouseOutHandler(f : Function) : void {
			if(mouseOutHandler.indexOf(f) < 0){
				mouseOutHandler.push(f);
			}
		}
		
		public static function removeMouseOutHandler(f : Function) : void {
			var index : int = mouseOutHandler.indexOf(f);
			if(index >= 0){
				mouseOutHandler.splice(index, 1);
			}
		}
		// 鼠标进入
		private static var mouseOverHandler : Vector.<Function> = new Vector.<Function>();
		public static function onMouseOver(evt:Event):void{
			//Debug.log("onMouseOver");
			var len : uint = mouseOverHandler.length;
			for(var i : int; i < len; i++){
				var f : Function = mouseOverHandler[i];
				if(!f(evt))
					break;
			}
		}
		
		public static function addMouseOverHandler(f : Function) : void {
			if(mouseOverHandler.indexOf(f) < 0){
				mouseOverHandler.push(f);
			}
		}
		
		public static function removeMouseOverHandler(f : Function) : void {
			var index : int = mouseOverHandler.indexOf(f);
			if(index >= 0){
				mouseOverHandler.splice(index, 1);
			}
		}
		// 鼠标滚轮
		private static var mouseWheelHandler : Vector.<Function> = new Vector.<Function>();
		public static function onMouseWheel(evt:Event):void{
			//Debug.log("onMouseWheel");
			var len : uint = mouseWheelHandler.length;
			for(var i : int; i < len; i++){
				var f : Function = mouseWheelHandler[i];
				if(!f(evt))
					break;
			}
		}
		
		public static function addMouseWheelHandler(f : Function) : void {
			if(mouseWheelHandler.indexOf(f) < 0){
				mouseWheelHandler.push(f);
			}
		}
		
		public static function removeMouseWheelHandler(f : Function) : void {
			var index : int = mouseWheelHandler.indexOf(f);
			if(index >= 0){
				mouseWheelHandler.splice(index, 1);
			}
		}
		// 鼠标单击
		private static var mouseClickHandler : Vector.<Function> = new Vector.<Function>();
		public static function onMouseClick(evt:Event):void{
			//Debug.log("onMouseClick");
			var len : uint = mouseClickHandler.length;
			for(var i : int; i < len; i++){
				var f : Function = mouseClickHandler[i];
				if(!f(evt))
					break;
			}
		}
		
		public static function addMouseClickHandler(f : Function) : void {
			if(mouseClickHandler.indexOf(f) < 0){
				mouseClickHandler.push(f);
			}
		}
		
		public static function removeMouseClickHandler(f : Function) : void {
			var index : int = mouseClickHandler.indexOf(f);
			if(index >= 0){
				mouseClickHandler.splice(index, 1);
			}
		}
		// 鼠标双击
		private static var mouseDoubleHandler : Vector.<Function> = new Vector.<Function>();
		public static function onMouseDouble(evt:Event):void{
			//Debug.log("onMouseDouble");
			var len : uint = mouseDoubleHandler.length;
			for(var i : int; i < len; i++){
				var f : Function = mouseDoubleHandler[i];
				if(!f(evt))
					break;
			}
		}
		
		public static function addMouseDoubleHandler(f : Function) : void {
			if(mouseDoubleHandler.indexOf(f) < 0){
				mouseDoubleHandler.push(f);
			}
		}
		
		public static function removeMouseDoubleHandler(f : Function) : void {
			var index : int = mouseDoubleHandler.indexOf(f);
			if(index >= 0){
				mouseDoubleHandler.splice(index, 1);
			}
		}
		
		
		
		
		
	}
}
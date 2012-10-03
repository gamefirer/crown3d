package away3d.debug
{
	import blade3d.editor.BlEditorManager;

    /** Class for emmiting debuging messages, warnings and errors */
    public class Debug
    {
		public static var context3DErrorCheck : Boolean = true;			// 设备验错
		public static var logEnable:Boolean = true;						// 是否log
        public static var active:Boolean = true;					// 是否trace
        public static var warningsAsErrors:Boolean = false;
		public static var assertEnable:Boolean = true;			// 是否assert
		public static var agalEnable:Boolean = false;
		

        public static function clear():void
        {
        }
        
        public static function delimiter():void
        {
        }
		
		public static function assert(val:Boolean, error:String = ""):void
		{
			if(assertEnable && !val)
			{
				throw new Error("assert: "+error); 
			}
		}
		
		public static function log(message:Object):void
		{
			if(logEnable)
			{
				trace(message);
				if(BlEditorManager.instance()._logEditor)
					BlEditorManager.instance()._logEditor.log(message);			// 输出log到界面
			}
		}
        
        public static function trace(message:Object):void
        {
        	if (active)
           		dotrace(message);
        }
        
        public static function warning(message:Object):void
        {
            if (warningsAsErrors)
            {
                error(message);
                return;
            }
			else
            	trace("WARNING: "+message);
        }
        
        public static function error(message:Object):void
        {
            trace("ERROR: "+message);
			if(BlEditorManager.instance()._logEditor)
				BlEditorManager.instance()._logEditor.log(message);			// 输出log到界面
            throw new Error(message);
        }
		
		public static function agalTrace(message:Object):void
		{
			if(agalEnable)
				dotrace(message);
		}
    }
}

/**
 * @private
 */
function dotrace(message:Object):void
{
    trace(message);
}
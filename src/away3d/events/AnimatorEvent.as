package away3d.events
{
	import away3d.animators.*;
	import away3d.animators.data.AnimationSequenceBase;
	
	import flash.events.*;

	/**
	 * Dispatched to notify changes in an animator's state.
	 */
	public class AnimatorEvent extends Event
	{
		public static const SEQUENCE_DONE : String = "SequenceDone";
		
		/**
    	 * Defines the value of the type property of a start event object.
    	 */
    	public static const START:String = "start";

    	/**
    	 * Defines the value of the type property of a stop event object.
    	 */
    	public static const STOP:String = "stop";
		
		private var _sequence : AnimationSequenceBase;
		private var _animator : AnimatorBase;

		/**
		 * Create a new <code>AnimatorEvent</code> object.
		 * 
		 * @param type The event type.
		 * @param animator The animator object that is the subject of this event.
		 */
		public function AnimatorEvent(type : String, animator : AnimatorBase, sequence : AnimationSequenceBase = null) : void
		{
			super(type, false, false);
			_animator = animator;
			_sequence = sequence;
		}

		public function get animator() : AnimatorBase
		{
			return _animator;
		}
		
		public function get sequence() : AnimationSequenceBase
		{
			return _sequence;
		}

		/**
		 * Clones the event.
		 * 
		 * @return An exact duplicate of the current event object.
		 */
		override public function clone() : Event
		{
			return new AnimatorEvent(type, _animator);
		}
	}
}

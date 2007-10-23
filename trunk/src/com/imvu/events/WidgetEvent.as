package com.imvu.events {
	import flash.events.Event;
	
	public class WidgetEvent extends Event {
		
		public var data:WidgetEventData;
	
		public function WidgetEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, data:WidgetEventData = null) {
			this.data = data;
			super(type, bubbles, cancelable);
		}
		
		// Every custom event class must override clone(  )
	    public override function clone():Event {
	    	return new WidgetEvent(type, bubbles, cancelable, data);
	    }

	    // Every custom event class must override toString(  ). Note that
	    // "eventPhase" is an instance variable relating to the event flow.
	    public override function toString():String {
	    	return formatToString("WidgetEvent", "type", "bubbles",
	                            "cancelable", "eventPhase", "data");
	    }
	}
}
/*
IMVU Flash Widget API, Copyright 2007 IMVU
    
This file is part of the IMVU Flash Widget API.

The IMVU Flash Widget API is free software: you can redistribute it 
and/or modify it under the terms of the GNU General Public License 
as published by the Free Software Foundation, either version 3 of 
the License, or (at your option) any later version.

The IMVU Flash Widget API is distributed in the hope that it will be 
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with the IMVU Flash Widget API. If not, see <http://www.gnu.org/licenses/>.
*/
package com.imvu.events {
	import flash.events.Event;

	/**
	 * WidgetEvent extends Event, and adds an extra WidgetEventData argument to 
	 * allow events fired by widgets to pass data to widget event handlers.
	 * @see com.imvu.events.WidgetEventData WidgetEventData
	 */	
	public class WidgetEvent extends Event {
		
		/**
		 * The data object associated with the WidgetEvent
		 */
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
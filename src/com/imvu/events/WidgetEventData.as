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
	
	/**
	 * A data object that is contained within WidgetEvent instances, allowing
	 * widgets to pass both specific and arbitrary data to widget event handlers.
	 * @see com.imvu.events.WidgetEvent WidgetEvent
	 */
	public class WidgetEventData {
		
		/**
		 * The event type
		 */
		public var type:String;
		
		/**
		 * The URL of the widget that fired the event
		 */
		public var sourceWidget:String;
		
		/**
		 * The name of the widget that fired the event (see ClientWidget.widgetName)
		 * @see com.imvu.widget.ClientWidget.widgetName
		 */
		public var sourceWidgetName:String;
		
		/**
		 * The remote widget that this event is intended for
		 */
		public var targetWidget:String;
		
		/**
		 * The avatar name of the user whose widget fired the event
		 */
		public var fromUser:String;
		
		/**
		 * An array of avatar names that this event is intended for. If this argument
		 * is null, the event will be delivered to all other users who are currently 
		 * running the target widget.
		 */
		public var recipients:Array;
		
		/**
		 * An arbitrary data object containing argument data to be passed to the
		 * widget event handler.
		 */
		public var args:Object = {};
		
		
		public function WidgetEventData(dataObject:Object=null) {
			if (dataObject) {
				this.loadFromObject(dataObject);
			}
		}
		
		/**
		 * Allows the public fields of a WidgetEventData instance to be set from the
		 * fields of an arbitrary object (i.e., one that is decoded from JSON).
		 * @param obj The object from which to load the WidgetEventData fields
		 */
		public function loadFromObject(obj:Object):void {
			for (var i:* in obj) {
				this[i] = obj[i];
			}
		}
		
		/**
		 * Adds a recipient to the recipients list that determines who will actually
		 * receive this event.
		 * @param avatarName The name of the recipient to add to the recipients list
		 */
		public function addRecipient(avatarName:String):void {
			if (! this.recipients) {
				this.recipients = [];
			}
			this.recipients.push(avatarName);
		}
		
	}
	
}
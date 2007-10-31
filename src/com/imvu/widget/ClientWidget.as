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
package com.imvu.widget {
	
	import com.adobe.serialization.json.*;
	import com.imvu.events.*;
	import com.interactiveAlchemy.utils.Debug;
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	
	/**
	 * ClientWidget is the base class used for writing widgets that run in the IMVU 3D client.
	 * ClientWidget is intended to be used as the document class for Flash movies intended to be
	 * used as IMVU widgets. Widgets are loaded as child movies of an empty movie called WidgetSpace
	 * that is always running in the 3D client and manages communication between widgets across the
	 * IMVU chat pipeline.
	 * @see com.imvu.widget.WidgetSpace WidgetSpace
	 */
	public class ClientWidget extends MovieClip {
		
		public static const JOIN_WIDGET:String = "joinWidget";
		
		/**
		 * Reference to the ClientWidget's parent WidgetSpace
		 */
		public var space:WidgetSpace = null;
		
		/**
		 * The URL of this widget's SWF
		 */
		public var url:String = "";
		
		/**
		 * The folder path where the widget resides 
		 */
		public var path:String = "";
		
		/**
		 * An object containing the parameters passed to the widget via the query string
		 */
		public var config:Object = {};
		
		/**
		 * The name of the current widget instance
		 */
		public var widgetName:String = "Widget";
		
		public function ClientWidget() {
			Security.allowDomain("*");
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
				init();
			});
		}
		
		/**
		 * Initializes the widget and fires a remote event notifying other clients that the 
		 * widget has been loaded by the current user. Also loads the configuration parameters,
		 * the URL, and calls the "initWidget" function if it has been defined by a subclass.
		 */
		public final function init():void {
			if (this.loaderInfo) {
				if (this.loaderInfo && this.loaderInfo.url) {
					this.url = this.loaderInfo.url.split('?', 1)[0];
				}
				this.config = this.loaderInfo.parameters;
			}
			if (this["initWidget"] && this["initWidget"] is Function) {
				var fn:Function = this["initWidget"];
				fn.call(this);
			}
			this.fireRemoteEvent(ClientWidget.JOIN_WIDGET);
		}

		/**
		 * Fires a remote WidgetEvent that will be received by other clients running the same
		 * widget.
		 * @param type The event type to fire
		 * @param args An object containing an arbitrary set of arguments to pass with the event
		 * @param recipients A list of avatar names of users that will receive this event. A null value
		 *                   indicates that the event will be sent to everyone.
		 * @param global	 When true, specifies that this event will be dispatched at the WidgetSpace level
		 */
		public function fireRemoteEvent(type:String, args:Object=null, recipients:Array=null, global:Boolean=false):void {			
			Debug.write("Firing event: " + type);
			
			var eventData:WidgetEventData = new WidgetEventData();
			eventData.type = type;
			eventData.sourceWidget = this.url;
			eventData.sourceWidgetName = this.widgetName;
			if (! global) {
				eventData.targetWidget = this.url;
			}
			if (this.space) {
				eventData.fromUser = this.space.avatarName;
			}
			eventData.args = args;
			if (recipients) {
				eventData.recipients = recipients;
			}
			this.sendEvent(eventData);
		}
		
		private function sendEvent(eventData:WidgetEventData):void {
			if (this.space) {
				this.space.sendEvent(eventData);
			}
		}
		
		/**
		 * Receives a WidgetEvent object from a remote client and dispatches it to the current widget.
		 * @param event A WidgetEvent that was sent by a remote client.
		 */
		public function receiveEvent(event:WidgetEvent):void {
			Debug.write("Widget received event: " + event.type, this.space.avatarName);
			this.dispatchEvent(event);
		}
		
		/*public function inviteAllUsers():void {
			Debug.write("Inviting all chat users to widget " + this.widgetName, this.space.avatarName);
			this.fireRemoteEvent("widgetInvite", null, null, true);
		}
		
		public function inviteUser(avatarName:String):void {
			Debug.write("Inviting user " + avatarName + " to widget " + this.widgetName, this.space.avatarName);
			this.space.fireRemoteEvent("widgetInvite", null, null, [avatarName]);
		}*/
	}
}
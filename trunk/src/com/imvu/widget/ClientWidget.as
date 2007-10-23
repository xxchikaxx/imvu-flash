package com.imvu.widget {
	
	import com.adobe.serialization.json.*;
	import com.imvu.events.*;
	import com.interactiveAlchemy.utils.Debug;
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	
	public class ClientWidget extends MovieClip {
		
		public var space:WidgetSpace = null;
		public var url:String = "";
		public var config:Object = {};
		public var widgetName:String = "Widget";
		
		public function ClientWidget() {
			Security.allowDomain("*");
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
				init();
			});
		}
		
		public function init():void {
			if (this.loaderInfo) {
				//this.url = this.loaderInfo.url.split('?', 1)[0];
				this.config = this.loaderInfo.parameters;
			}
			this.fireRemoteEvent("joinWidget");
		}

		public function fireRemoteEvent(type:String, args:Object=null, recipients:Array=null, global:Boolean=false):void {			
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
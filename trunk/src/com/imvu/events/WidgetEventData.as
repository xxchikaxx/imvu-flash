package com.imvu.events {
	
	public class WidgetEventData {
		
		public var type:String;
		
		public var sourceWidget:String;
		public var sourceWidgetName:String;
		public var targetWidget:String;
		
		public var fromUser:String;
		public var recipients:Array;
		
		public var args:Object = {};
		
		
		public function WidgetEventData(dataObject:Object=null) {
			if (dataObject) {
				this.loadFromObject(dataObject);
			}
		}
		
		public function loadFromObject(obj:Object):void {
			for (var i:* in obj) {
				this[i] = obj[i];
			}
		}
		
		public function addRecipient(avatarName:String):void {
			if (! this.recipients) {
				this.recipients = [];
			}
			this.recipients.push(avatarName);
		}
		
		/*public override function toString():String {
			
		}*/
		
	}
	
}
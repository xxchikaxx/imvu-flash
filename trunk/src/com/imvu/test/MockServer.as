package com.imvu.test
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.LocalConnection;
	import com.interactiveAlchemy.utils.Debug;
	
	[ExcludeClass]
	public class MockServer extends MovieClip {
		
		public var bridge:LocalConnection = new LocalConnection();
		public var users:Object = {};
		
		public function MockServer() {
			this.connect();
		}
		
		public function receiveMessage(avatarName:String, message:String) {
			connectClient(avatarName);
			txtChatOutput.htmlText += "<b>" + avatarName + "</b>: " + message + "\n";
			txtChatOutput.verticalScrollPosition = txtChatOutput.maxVerticalScrollPosition;
			// Broadcast out to others
			for (var i in users) {
				var outgoingConn:LocalConnection = new LocalConnection();
				try { outgoingConn.connect(i); } catch (ex:Error) {}
				outgoingConn.send(i,"receiveMessage",avatarName,message);
				try { outgoingConn.close(); } catch (ex:Error) {}
			}
		}
		
		public function connect():void {
			try {
				bridge.connect("mockchat");
				bridge.client = this;
			} catch (ex:Error) {}		
		}
		
		public function connectClient(avatarName:String):void {
			users[avatarName] = 1;
		}
		
	}
}
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
/**
 * @private
 */
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
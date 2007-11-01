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
	import asunit.framework.TestCase;
	import com.imvu.widget.*;
	import flash.events.Event;
	import com.interactiveAlchemy.utils.Debug;
	import com.adobe.serialization.json.*;
	
	public class MultiUserTest extends TestCase {
		private var ws1:WidgetSpace;
		private var ws2:WidgetSpace;
		
		public function MultiUserTest(testMethod:String) {
			super(testMethod);
		}
				
		protected override function setUp():void {
			ws1 = new WidgetSpace();
			ws1.avatarName = "user1";
			ws1.dispatchEvent(new Event(Event.ADDED_TO_STAGE));
			
			ws2 = new WidgetSpace();
			ws2.avatarName = "user2";
			ws2.dispatchEvent(new Event(Event.ADDED_TO_STAGE));
			
			var interface1:MockExternalInterface = MockExternalInterface(ws1.ext);
			interface1.scope = {
				sendMessage : function(message:String):void {
					var args:Array = message.split(" ");
					var dataArray:Array = args.slice(2);
					var json:String = dataArray.join(" ");
					Debug.write("user1 sending message: " + json);
					interface2.callbacks.flashCommand("user1", json);
				}
			};
			
			var interface2:MockExternalInterface = MockExternalInterface(ws2.ext);
			interface2.scope = {
				sendMessage : function(message:String):void {
					var args:Array = message.split(" ");
					var dataArray:Array = args.slice(2);
					var json:String = dataArray.join(" ");
					Debug.write("user2 sending message: " + json);
					interface1.callbacks.flashCommand("user2", json);
				}
			};
		}
		
		protected override function tearDown():void {
		
		}
		
		public function testMessages():void {
			var loadHandler:Function = function(e:Event):void {
				ws2.loadWidget("circle.swf");
			}
			
			ws1.addEventListener(WidgetSpace.WIDGET_LOADED, addAsync(loadHandler));
			ws1.loadWidget("circle.swf");
			
			
		}
	}
}
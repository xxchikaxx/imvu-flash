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
package com.imvu.test {
	import asunit.framework.TestCase;
	import com.imvu.widget.ClientWidget;
	import com.imvu.widget.WidgetSpace;
	import com.imvu.events.*;
	import flash.events.Event;
	import com.imvu.test.MockExternalInterface;
	import com.interactiveAlchemy.utils.Debug;
	import com.imvu.events.WidgetEventData;
	import com.adobe.serialization.json.*;
	
	public class ClientWidgetTest extends TestCase {
		private var _instance:ClientWidget;
		private var _widgetSpace:WidgetSpace;
		
		public function ClientWidgetTest(testMethod:String) {
			super(testMethod);
		}
		
		protected override function setUp():void {
			
			_widgetSpace = new WidgetSpace();
			_widgetSpace.avatarName = "TestUser";
			
			// Attach a listener to verify that the INTERFACE_READY event is fired
			_widgetSpace.addEventListener(WidgetSpace.INTERFACE_READY, function(e:Event):void { Debug.write("Test Interface Ready"); });
			
			// There is no stage, so we need to fire the event manually in order to cause init() to fire
			_widgetSpace.dispatchEvent(new Event(Event.ADDED_TO_STAGE));
			
			_widgetSpace.ext.scope =  {
				sendMessage : function(message:String):void {
					Debug.write("Sent message: " + message);
				}
			};
			
			_instance = new ClientWidget();
			_instance.url = "test.swf";
			_instance.space = _widgetSpace;
			_instance.widgetName = "My Test Widget";
			_widgetSpace.widgets["test.swf"] = _instance;
		}
		
		protected override function tearDown():void {
			_widgetSpace = null;
			_instance = null;
		}
		
		public function testSendEvent():void {
			//{"fromUser":"TestUser","recipients":null,"args":{"data":1},"sourceWidgetName":"Widget","type":"MyTestEvent","sourceWidget":"test.swf","targetWidget":"test.swf"}
			_instance.fireRemoteEvent("MyTestEvent", { data: 1 });
			assertTrue(Debug.messages[0].indexOf('"data":1') > 0);
			assertTrue(Debug.messages[0].indexOf('"type":"MyTestEvent"') > 0);
			assertTrue(Debug.messages[0].indexOf('"recipients":null') > 0);
			assertTrue(Debug.messages[0].indexOf('"sourceWidget":"' + _instance.url + '"') > 0);
			assertTrue(Debug.messages[0].indexOf('"sourceWidgetName":"' + _instance.widgetName + '"') > 0);
			assertTrue(Debug.messages[0].indexOf('"targetWidget":"' + _instance.url + '"') > 0);
			
			_instance.fireRemoteEvent("MyTestEvent", { data: 1 }, ["JohnDoe"], true);
			assertTrue(Debug.messages[0].indexOf('"targetWidget":null') > 0);
			assertTrue(Debug.messages[0].indexOf('"recipients":["JohnDoe"]') > 0);
			
		}		
		
		public function testReceiveEvent():void {
			var event:WidgetEventData = new WidgetEventData();
			event.args = { testData: 1 };
			event.fromUser = "AnotherUser";
			event.sourceWidget = "test.swf";
			event.type = "MyTestEvent";
			
			var handlerFired:Boolean = false;
			
			var testHandler:Function = function(e:WidgetEvent):void {
				handlerFired = true;
			};
			
			_instance.addEventListener(event.type, addAsync(testHandler));
			_instance.receiveEvent(new WidgetEvent(event.type, false, false, event));
			
			assertTrue(handlerFired);
		}

	}
}
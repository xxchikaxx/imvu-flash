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
	import flash.events.MouseEvent;
	import com.imvu.test.MockExternalInterface;
	import com.interactiveAlchemy.utils.Debug;
	import com.imvu.events.WidgetEventData;
	import com.adobe.serialization.json.*;
	
	public class WidgetSpaceTest extends TestCase {
		private var _instance:WidgetSpace;
		
		public function WidgetSpaceTest(testMethod:String) {
			super(testMethod);
		}
		
		protected override function setUp():void {
			_instance = new WidgetSpace();
			_instance.avatarName = "TestUser";
			
			// Attach a listener to verify that the INTERFACE_READY event is fired
			_instance.addEventListener(WidgetSpace.INTERFACE_READY, function(e:Event):void { Debug.write("Test Interface Ready"); });
			
			// There is no stage, so we need to fire the event manually in order to cause init() to fire
			_instance.dispatchEvent(new Event(Event.ADDED_TO_STAGE));
			
			_instance.ext.scope =  {
				sendMessage : function(message:String):void {
					Debug.write("Sent message: " + message);
				}
			};
		}
		
		protected override function tearDown():void {
			_instance = null;
		}
		
		public function testExternalInterfaceSetup():void {
			assertTrue(_instance.ext is MockExternalInterface);
			assertEquals(_instance.ext.callbacks.loadWidget, _instance.loadWidget);
			assertEquals(_instance.ext.callbacks.unloadWidget, _instance.unloadWidget);
		
			assertEquals(Debug.messages[0], "Test Interface Ready");
		}
		
		public function testLoadAndUnloadWidget():void {
			var loadHandler:Function = function(e:Event):void { 
				assertNotNull(_instance.widgets["circle.swf"]);
				var testWidget:ClientWidget = _instance.widgets["circle.swf"];
				assertEquals(testWidget, _instance.getChildByName(testWidget.name));
				
				_instance.unloadWidget("circle.swf");
				assertNull(_instance.widgets["circle.swf"]);
				assertNull(_instance.getChildByName(testWidget.name));
			};
			
			_instance.addEventListener(WidgetSpace.WIDGET_LOADED, addAsync(loadHandler));
			_instance.loadWidget("circle.swf");
			
		}
		
		public function testParsePath():void {
			var path:String = "http://virtual.imvu.products/80/test.swf";
			var parsed:String = WidgetSpace.getWidgetPath(path);
			assertEquals(parsed, "http://virtual.imvu.products/80/");
		}
		
		public function testSendEvent():void {
			_instance.fireRemoteEvent("MyTestEvent", { testData: 1 });
			assertEquals(Debug.messages[0].indexOf('Sent message: *imvu:flashCommand'), 0);
		}		
		
		public function testReceiveEvent():void {
			var event:WidgetEventData = new WidgetEventData();
			event.args = { testData: 1 };
			event.fromUser = "AnotherUser";
			event.sourceWidget = "test.swf";
			event.type = "MyTestEvent";
			
			var eventsFired:Number = 0;
			_instance.addEventListener(event.type, function(e:WidgetEvent):void { eventsFired++; });
			
			// First, dispatch events to WidgetSpace itself:
			// Test an event that was meant for everyone
			_instance.ext.callbacks.flashCommand("AnotherUser", JSON.encode(event));
			
			// Test an event that was meant for someone other than me
			event.recipients = ["NotMeantForYou"];
			_instance.ext.callbacks.flashCommand("AnotherUser", JSON.encode(event));
			
			// Test an event that was meant for me only
			event.recipients = [_instance.avatarName];
			_instance.ext.callbacks.flashCommand("AnotherUser", JSON.encode(event));
			
			assertEquals(eventsFired, 2);	
			
			var loadHandler:Function = function(e:Event):void { 
				assertNotNull(_instance.widgets["circle.swf"]);
				
				var widgetGotEvent:Boolean = false;
				var widget:ClientWidget = _instance.widgets["circle.swf"];
				
				widget.addEventListener(event.type, function(we:WidgetEvent):void { widgetGotEvent=true; });
				
				event.targetWidget = "circle.swf";
				_instance.ext.callbacks.flashCommand("AnotherUser", JSON.encode(event));
				
				assertTrue(widgetGotEvent);
			};			
			
			_instance.addEventListener(WidgetSpace.WIDGET_LOADED, addAsync(loadHandler));
			// Test events get dispatched to loaded widget
			_instance.loadWidget("circle.swf");
		}
		
		public function testFocusAndBlur():void {
			var loadHandler:Function = function(e:Event):void { 
				if (_instance.widgets["circle2.swf"] && _instance.widgets["circle.swf"]) {
					var testWidget1:ClientWidget = _instance.widgets["circle.swf"];
					testWidget1.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
					assertSame(testWidget1, _instance.activeWidget);
					assertNotSame(testWidget2, _instance.activeWidget);
					
					var testWidget2:ClientWidget = _instance.widgets["circle2.swf"];
					testWidget2.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
					assertSame(testWidget2, _instance.activeWidget);
					assertNotSame(testWidget1, _instance.activeWidget);
				}
			};
			
			_instance.addEventListener(WidgetSpace.WIDGET_LOADED, addAsync(loadHandler, 2000));
			_instance.loadWidget("circle.swf");
			_instance.loadWidget("circle2.swf");	
		}
	}
}
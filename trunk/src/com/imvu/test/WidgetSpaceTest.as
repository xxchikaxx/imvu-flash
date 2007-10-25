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
			
			MockExternalInterface.scope =  {
				sendMessage : function(message:String):void {
					Debug.write("Sent message: " + message);
				}
			};
		}
		
		protected override function tearDown():void {
			_instance = null;
		}
		
		public function testExternalInterfaceSetup():void {
			assertEquals(_instance.ext, MockExternalInterface);
			assertEquals(MockExternalInterface.callbacks.loadWidget, _instance.loadWidget);
			assertEquals(MockExternalInterface.callbacks.unloadWidget, _instance.unloadWidget);
		
			assertEquals(Debug.messages[0], "Test Interface Ready");
		}
		
		public function testLoadAndUnloadWidget():void {
			var loadHandler:Function = function(e:Event):void { 
				assertNotNull(_instance.widgets["circle.swf"]);
				var testWidget:ClientWidget = _instance.widgets["circle.swf"];
				assertEquals(testWidget, _instance.getChildByName(testWidget.name));
				Debug.write("PATH: " + _instance.widgets["circle.swf"].path);
				
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
			MockExternalInterface.callbacks.flashCommand("AnotherUser", JSON.encode(event));
			
			// Test an event that was meant for someone other than me
			event.recipients = ["NotMeantForYou"];
			MockExternalInterface.callbacks.flashCommand("AnotherUser", JSON.encode(event));
			
			// Test an event that was meant for me only
			event.recipients = [_instance.avatarName];
			MockExternalInterface.callbacks.flashCommand("AnotherUser", JSON.encode(event));
			
			assertEquals(eventsFired, 2);	
			
			var loadHandler:Function = function(e:Event):void { 
				assertNotNull(_instance.widgets["circle.swf"]);
				
				var widgetGotEvent:Boolean = false;
				var widget:ClientWidget = _instance.widgets["circle.swf"];
				
				widget.addEventListener(event.type, function(we:WidgetEvent):void { widgetGotEvent=true; });
				
				event.targetWidget = "circle.swf";
				MockExternalInterface.callbacks.flashCommand("AnotherUser", JSON.encode(event));
				
				assertTrue(widgetGotEvent);
			};			
			
			_instance.addEventListener(WidgetSpace.WIDGET_LOADED, addAsync(loadHandler));
			// Test events get dispatched to loaded widget
			_instance.loadWidget("circle.swf");
		}

	}
}
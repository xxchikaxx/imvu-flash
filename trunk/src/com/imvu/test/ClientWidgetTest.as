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
			
			MockExternalInterface.scope =  {
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
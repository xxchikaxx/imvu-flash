package com.imvu.widget
{
	import com.adobe.serialization.json.*;
	import com.imvu.widget.*;
	import com.imvu.events.*;
	import com.imvu.test.*;
	
	import com.interactiveAlchemy.utils.Debug;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;

	/**
	* Dispatched when the ExternalInterface is ready to begin receiving messages 
	* from the WidgetSpace.
	*
	* @eventType interfaceReady
	*/
	[Event(name="interfaceReady", type="flash.events.Event")]
	/**
	 * Description of the WidgetSpace class
	 */
	public class WidgetSpace extends MovieClip {
		com.imvu.widget.WidgetAsset;
		
		/**
		 * The WidgetSpace.INTERFACE_READY constant defines the value of the 
		 * <code>type</code> property of the event object 
		 * for a <code>interfaceReady</code> event.
		 *
		 * the <code>data</code> property of the event contains data about
		 * the fired event.
		 * @see com.imvu.events.WidgetEventData WidgetEventData
		 * @eventType interfaceReady
		 */
		public static const INTERFACE_READY:String = "interfaceReady"
		
		public static const WIDGET_LOADED:String = "widgetLoaded";
		
		/**
		 * The list of currently loaded widgets, indexed by the SWF URL of each widget.
		 */
		public var widgets:Object = {};
		
		/**
		 * The avatar name of the user that has loaded the WidgetSpace.
		 */
		public var avatarName:String = "";
		
		/**
		 * The loaded url of the WidgetSpace SWF
		 */
		public var url:String = "";
		
		/**
		 * The ExternalInterface object used to make calls to the chat client
		 */
		public var ext:Object = null;
		
		//public var users:Array = [];
		
		/**
		 * The interface dialog that allows users to confirm whether to load a widget offered 
		 * for sharing by another user in chat.
		 */
		public var dlgLoad:MovieClip;
		
		public function WidgetSpace() {
			Security.allowDomain("*");
			
			if (dlgLoad) {
				dlgLoad.visible = false;
			}
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
				init();
			});
		}
		
		/**
		 * Initializes the WidgetSpace and prepares it for the loading of child widgets.
		 */
		public function init():void {			
			if (this.loaderInfo) {
				this.url = this.loaderInfo.url.split('?', 1)[0];
				Debug.write("WidgetSpace URL: " + this.url);
			}
			
			this.setupInterface();
			
			/*this.addEventListener("joinChat", function(e:WidgetEvent):void {
				Debug.write("Added user " + e.data.fromUser + " to user list", this.avatarName);
				users.push(e.data.fromUser);
			});*/
			
			// Handles the display of the confirm dialog if someone invites you to use a widget
			this.addEventListener("widgetInvite", function(event:WidgetEvent):void { 
				var alreadyLoaded:ClientWidget = widgets[event.data.sourceWidget];
				if (! alreadyLoaded) {
					dlgLoad.txtDialog.text = dlgLoad.txtDialog.text.replace("$avatar", event.data.fromUser);
					dlgLoad.txtDialog.text = dlgLoad.txtDialog.text.replace("$name", event.data.sourceWidgetName);
					dlgLoad.visible = true;
				
					var handleOK:Function = function(e:MouseEvent):void {
						dlgLoad.visible = false;
						loadWidget(event.data.sourceWidget);
						dlgLoad.btnOK.removeEventListener(MouseEvent.CLICK, handleOK);
						dlgLoad.btnCancel.removeEventListener(MouseEvent.CLICK, handleCancel);
					};
					var handleCancel:Function = function(e:MouseEvent):void {
						dlgLoad.visible = false;
						dlgLoad.btnOK.removeEventListener(MouseEvent.CLICK, handleOK);
						dlgLoad.btnCancel.removeEventListener(MouseEvent.CLICK, handleCancel);
					};
	
					dlgLoad.btnOK.addEventListener(MouseEvent.CLICK, handleOK);
					dlgLoad.btnCancel.addEventListener(MouseEvent.CLICK, handleCancel);
				}
			
			});
		}

		/**
		 * Configures the ExternalInterface object used to make calls from Flash to the chat client.
		 */
		private function setupInterface():void {
			if (! ExternalInterface.available) {
				this.ext = MockExternalInterface;
			} else {
				this.avatarName = ExternalInterface.call("getAvatarName"); // See if we're in the IMVU client
				if (this.avatarName) {
					this.ext = ExternalInterface;
					Debug.write("Running in IMVU Client", this.avatarName);
				} else {
					this.ext = MockExternalInterface;
				}
			}
			if (this.ext == MockExternalInterface) {
				Debug.write("NOT Running in IMVU Client! Using MockExternalInterface", this.avatarName);
			}
			
			this.ext.addCallback('flashCommand', this.receiveFlashCommand);
			this.ext.addCallback('loadWidget', this.loadWidget);
			this.ext.addCallback('unloadWidget', this.unloadWidget);
			
			this.dispatchEvent(new Event(WidgetSpace.INTERFACE_READY));
		}

		/**
		 * Broadcasts an event to other users.
		 * @param type The event type to fire on remote clients
		 * @param args An object containg arguments associated with the event
		 * @param targetWidget The URL of the target SWF that should receive the event
		 * @param recipients An optional array of avatar names that should receive the event
		 */
		public function fireRemoteEvent(type:String, args:Object=null, targetWidget:String=null, recipients:Array=null):void {			
			var eventData:WidgetEventData = new WidgetEventData();
			eventData.type = type;
			if (targetWidget) {
				eventData.targetWidget = targetWidget;
			}
			eventData.fromUser = this.avatarName;
			eventData.args = args;
			if (recipients) {
				eventData.recipients = recipients;
			}
			this.sendEvent(eventData);
		}
		
		/**
		 * Sends a JSON-encoded WidgetEventData object other users in the chat session
		 * @param eventData The WidgetEventData object to encode and send to other users
		 */
		public function sendEvent(eventData:WidgetEventData):void {
			var json:String = JSON.encode(eventData);
			this.ext.call("sendMessage", "*imvu:flashCommand " + this.url + " " + json); // Send message using client
		}

		/**
		 * Receives a WidgetEvent object and determines whether it was intended for the current
		 * recipient, and delegates it to the appropriate widget. If no target widget was specified,
		 * the event is dispatched at the WidgetSpace level.
		 * @param event The WidgetEvent object
		 */
		public function receiveEvent(event:WidgetEvent):void {
			var data:WidgetEventData = event.data;
			if (data.recipients) { // This data was intended for certain users only
				if (data.recipients.indexOf(this.avatarName) == -1) {
					Debug.write("Event " + event.type + " was not meant for me!", this.avatarName);
					return; // This wasn't an event for me
				}
			}
			if (! data.targetWidget) { // targetless events get dispatched at the WidgetSpace level and sent to all loaded widgets
				this.dispatchEvent(event);
				Debug.write("Event " + event.type + " dispatched to " + this, this.avatarName);
			} else { // This was meant for a specific widget
				var destination:ClientWidget = this.widgets[data.targetWidget];
				if (destination) {
					Debug.write(destination.toString());
					destination.receiveEvent(event);
					Debug.write("Event " + event.type + " dispatched to " + destination, this.avatarName);
				}
			}
		}
		
		/**
		 * Receives a raw JSON Flash command from the IMVU client and converts it to a WidgetEvent
		 * object for delegation to other widgets or the WidgetSpace itself.
		 * 
		 * @param avatarName The avatar name of the user transmitting the Flash command
		 * @param json The JSON-encoded data string containing the event data
		 */
		private function receiveFlashCommand(avatarName:String, json:String):void {
			// React to the events that we accept from other clients
			Debug.write("Received flashCommand JSON from " + avatarName + ": " + json, this.avatarName);
			var data:WidgetEventData = new WidgetEventData(JSON.decode(json));
			data.fromUser = avatarName;
			if (data.type) {
				var event:WidgetEvent = new WidgetEvent(data.type, false, false, data);
				this.receiveEvent(event);
			}
		}
		
		/**
		 * Loads a widget into the WidgetSpace.
		 * 
		 * @param path The URL of the widget SWF to be loaded
		 */
		public function loadWidget(path:String):void {
			Debug.write("Attempting to load widget: " + path, this.avatarName);
			
			var url:URLRequest = new URLRequest(path);
			
			var me:WidgetSpace = this;
			var loadComplete:Function = function(e:Event):void {
				ldr.content["space"] = me;
				ldr.content["url"] = path;
				ldr.content["path"] = WidgetSpace.getWidgetPath(path);
				
				var fullURL:String = ldr.content.loaderInfo.url;
				Debug.write("Full widget URL: " + fullURL, this.avatarName);
				me.widgets[path] = ldr.content;
				
				me.addChild(ldr.content);
				Debug.write("Added widget to WidgetSpace: " + path, this.avatarName);
				me.dispatchEvent(new Event(WIDGET_LOADED));
			}
			
			var ldr:Loader = new Loader();
			var context:LoaderContext = new LoaderContext();
			context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
			
			if (Security.sandboxType == Security.REMOTE) {
				context.securityDomain = SecurityDomain.currentDomain;
			}
			
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			ldr.load(url, context);
			
		}

		/**
		 * Unloads a widget from the WidgetSpace.
		 * 
		 * @param path The URL of the widget SWF to be unloaded
		 */		
		public function unloadWidget(path:String):void {
			Debug.write("Attempting to unload widget: " + path, this.avatarName);
			var widgetToUnload:MovieClip = this.widgets[path];
			if (widgetToUnload) {
				Debug.write("Removing widget: " + widgetToUnload);
				this.removeChild(widgetToUnload);
				delete this.widgets[path];
			}
		}
		
		public static function getWidgetPath(path:String):String {
			var pathOnly:String = "";
			if (path.indexOf("://") > 0) {
				var urlSegments:Array = path.split("/");
				urlSegments.pop();
				pathOnly = urlSegments.join("/") + "/";
			}
			return pathOnly;
		}
		
	}
}
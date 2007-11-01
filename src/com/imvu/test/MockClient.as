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
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	import com.interactiveAlchemy.utils.Debug;
	import com.imvu.widget.*;
	import com.imvu.events.*;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import fl.controls.Button;
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	
	[ExcludeClass]
	public class MockClient extends MovieClip
	{
		
		public var server:LocalConnection = new LocalConnection();
		public var client:LocalConnection = new LocalConnection();
		public var avatarName:String = "";
		public var connected:Boolean = false;
		public var space:WidgetSpace = null;
		
		public var controls:MovieClip;
		public var btnLoad:Button;
		
		public function MockClient() {
			this.avatarName = "user" + int(100 * Math.random());
			
			this.stage.align = "TL";
			this.stage.scaleMode = "noScale";
			this.stage.addEventListener(Event.RESIZE, function(e:Event) {
				controls.y = stage.stageHeight - controls.height;
				btnLoad.x = stage.stageWidth - 5 - btnLoad.width;
			});
			
			var request:URLRequest = new URLRequest("WidgetSpace.swf");
			
			var loader:Loader = new Loader();
			var context:LoaderContext = new LoaderContext();
			context.applicationDomain = ApplicationDomain.currentDomain;
			
			var me:MockClient = this;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event){ 
				trace("WidgetSpace loaded");
				space=WidgetSpace(loader.content);
				if (! space.ext) {
						space.addEventListener("interfaceReady", function(e:Event) {
							Debug.write("MockExternalInterface ready -- setting scope", me.avatarName);																		  
							space.ext.scope = me;
							space.avatarName = me.avatarName;
						});
				} else {
					Debug.write("MockExternalInterface ready -- setting scope", me.avatarName);																		  
					space.ext.scope = me;
					space.avatarName = me.avatarName;
				}
				
				space.addEventListener("joinChat", function(e:WidgetEvent) {
					controls.txtChatOutput.htmlText += "<i>" + e.data.fromUser + " has joined the chat.</i>\n";  
				});
				
				space.fireRemoteEvent("joinChat");
			});
			
			loader.load(request, context);
			this.addChildAt(loader, 0);

			controls.txtAvatarName.text = this.avatarName;
			
			controls.txtAvatarName.addEventListener(Event.CHANGE, function(e:Event):void { 
				avatarName = controls.txtAvatarName.text;
				connectClient();
				trace(avatarName);
			});
			
			controls.txtChatInput.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
				if (e.keyCode == 13) {
					sendChatInput();
				}
			});
			
			controls.btnSend.addEventListener(MouseEvent.CLICK, sendChatInput);
			
			btnLoad.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) {
				var frl:FileReferenceList = new FileReferenceList();
				frl.browse();
				frl.addEventListener(Event.SELECT, function(e:Event) {
					var fileList:Array = frl.fileList;
					for each(var f:FileReference in fileList) {
						space.loadWidget(f.name);
					}
				});
			});
			
			this.connectClient();
			
			server.addEventListener(StatusEvent.STATUS, function(e:StatusEvent) {
				if (e.level == "error") {
					Debug.write("No connection to server!", me.avatarName);
				}
			});
			
			//this.deliverMessageToServer("init");
		}
		
		public function receiveMessage(avatarName:String, message:String) {
			if (avatarName != this.avatarName) {
				if (message.indexOf("*imvu") == 0) {
					// This was a *imvu command, so we need to do something fun with it
					this.processStarImvuCommand(avatarName, message);
				} else {
					this.outputMessage(avatarName, message);
				}
			}
		}
		
		private function processStarImvuCommand(avatarName:String, message:String) {
			if (message.indexOf("flashCommand") != -1) {
				
				var args:Array = message.split(" ");
				var url:String = args[1];
				var dataArray:Array = args.slice(2);
				var data:String = dataArray.join(" ");
				// Need to send this data to the function that's associated with the flashCommand callback on the widgetspace
				this.space.ext.callbacks.flashCommand(avatarName, data);
			}
		}
		
		public function outputMessage(avatarName:String, message:String):void {
			controls.txtChatOutput.htmlText += "<b>" + avatarName + "</b>: " + message + "\n";
			controls.txtChatOutput.verticalScrollPosition = controls.txtChatOutput.maxVerticalScrollPosition;
		}
		
		public function sendChatInput(e:Event=null):void {
			sendMessage(controls.txtChatInput.text);
			controls.txtChatInput.text = "";
		}
		
		public function sendMessage(message:String) {
			if (message.indexOf("*imvu") != 0) {
				this.outputMessage(this.avatarName, message);
			}
			deliverMessageToServer(message);
		}
		
		public function deliverMessageToServer(message:String) {
			server.send("mockchat", "receiveMessage", this.avatarName, message);
		}
		
		public function connectClient():void {
			try { client.close(); } catch (ex:Error) {}
			try {
				client.connect(this.avatarName);
				client.client = this;
			} catch (ex:Error) {}		
		}
		
		public function getAvatarName():String {
			return this.avatarName;
		}
	}
}
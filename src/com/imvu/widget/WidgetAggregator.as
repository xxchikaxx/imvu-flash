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
package com.imvu.widget
{
    import com.adobe.serialization.json.*;
    import com.imvu.widget.*;
    import com.imvu.events.*;
    import com.imvu.test.*;
    import com.imvu.Logger;

    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.display.Sprite;
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
    * from the WidgetAggregator.
    *
    * @eventType interfaceReady
    */
    [Event(name="interfaceReady", type="flash.events.Event")]
    /**
     * The WidgetAggregator in an empty SWF with no visible interface that is responsible for
     * loading widgets into the IMVU 3D client and dispatching events to and from the 
     * appropriate widgets across the IMVU chat pipeline.
     */
    public class WidgetAggregator extends MovieClip {
        com.imvu.widget.WidgetAsset;
 
        /**
         * The WidgetAggregator.INTERFACE_READY constant defines the value of the 
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
        
        public static const WIDGET_UNLOADED:String = "widgetUnloaded";
        
        public var widgets:Object = {};
        public var avatarName:String = "";
        public var url:String = "";
        public var ext:Object = null;
        
        public var activeWidget:ClientWidget;
 
        public function WidgetAggregator() {
            Security.allowDomain("*");
            this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
                init();
            });
        }
 
        public function init():void {            
            if (this.loaderInfo) {
                this.url = this.loaderInfo.url.split('?', 1)[0];
                Logger.info("WidgetAggregator URL: " + this.url);
            }
            this.setupInterface();
        }

        private function setupInterface():void {
            if(!ExternalInterface.available) {
                this.ext = new MockExternalInterface();
            } else {
                this.avatarName = ExternalInterface.call("getAvatarName"); // See if we're in the IMVU client
                if (this.avatarName) {
                    this.ext = ExternalInterface;
                    Logger.info("Running in IMVU Client", this.avatarName);
                } else {
                    this.ext = new MockExternalInterface();
                }
            }
            if (this.ext is MockExternalInterface) {
                Logger.info("NOT Running in IMVU Client! Using MockExternalInterface", this.avatarName);
            }
 
            this.ext.addCallback('loadWidget', this.loadWidget);
            this.ext.addCallback('unloadWidget', this.unloadWidget);
            this.ext.addCallback('blurAll', this.blurAll);
            this.ext.addCallback('getWidgets', this.getWidgets);
 
            this.dispatchEvent(new Event(WidgetAggregator.INTERFACE_READY));
        }

        /**
         * Loads a widget into the WidgetAggregator.
         * 
         * @param path The URL of the widget SWF to be loaded
         */
        public function loadWidget(path:String):void {
            Logger.info("Attempting to load widget: " + path, this.avatarName);
            
            var url:URLRequest = new URLRequest(path);
            
            var me:WidgetAggregator = this;
            var loadComplete:Function = function(e:Event):void {
                Logger.info("loadWidget(): loadComplete: %r", ldr.content);

                try {
                    var newWidget:ClientWidget = ClientWidget(ldr.content);
                
                    ldr.content["url"] = path.split('?', 1)[0];
                    ldr.content["path"] = WidgetAggregator.getWidgetPath(path);
                
                    newWidget.focus = function(e:MouseEvent=null):void {
                        blurOthers(newWidget);
                        activeWidget = newWidget;
                    };
                
                    newWidget.blur = function(e:MouseEvent=null):void {
                    };
                
                    newWidget.addEventListener(MouseEvent.MOUSE_DOWN, newWidget.focus);
                }
                catch (e:Error) {
                    Logger.info('Error loading widget as ClientWidget: ' + e.toString());
                }
                
                var fullURL:String = ldr.content.loaderInfo.url;
                Logger.info("Full widget URL: " + fullURL, this.avatarName);
                me.widgets[path] = ldr.content;
                
                me.addChild(ldr.content);
                Logger.info("Added widget to WidgetAggregator: " + path, this.avatarName);
                me.dispatchEvent(new Event(WIDGET_LOADED));
            }
            
            var ldr:Loader = new Loader();
            var context:LoaderContext = new LoaderContext();
            context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
            
            if (Security.sandboxType == Security.REMOTE) {
                context.securityDomain = SecurityDomain.currentDomain;
            }
            Logger.info("sandboxType: %r", Security.sandboxType);

            ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
            ldr.load(url, context);
        }

        public function blurOthers(except:ClientWidget):void {
            for each(var widget:ClientWidget in this.widgets) {
                if (widget != except) {
                    widget.blur();
                }
            }
        }

        public function blurAll(e:MouseEvent=null):void {
            for each(var widget:ClientWidget in this.widgets) {
                widget.blur();
            }
            activeWidget = null;
        }

        public function getWidgets():Array {
            var result:Array = new Array();
            for (var path:String in this.widgets) {
                result.push(path);
            }
            return result;
        }
 
        /**
         * Unloads a widget from the WidgetAggregator.
         * 
         * @param path The URL of the widget SWF to be unloaded
         */        
        public function unloadWidget(path:String):void {
            Logger.info("Attempting to unload widget: " + path, this.avatarName);
            var widgetToUnload:ClientWidget = this.widgets[path];
            if (widgetToUnload) {
                Logger.info("Removing widget: " + widgetToUnload);
                this.removeChild(widgetToUnload);
                delete this.widgets[path];
            }
        }
 
        /**
         * Utility function to extract the path of a file from its full URL.
         * 
         * @param path The URL of the widget
         */
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

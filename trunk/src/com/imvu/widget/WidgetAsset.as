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
package com.imvu.widget {
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	/**
	 * Represents a skinnable asset that can be used in a widget. This class provides an easy
	 * way to define a default asset that can be replaced with another external asset at runtime.
	 */
	public class WidgetAsset extends MovieClip {

		/**
		 * The Loader used to retrieve skin assets.
		 */
		private var loader:Loader;
		
		/**
		 * The default asset that always lives at child 0 in the WidgetAsset clip
		 * and will be removed and replaced when an external asset is successfully loaded.
		 */
		private var defaultAsset:DisplayObject;
		
		/**
		 * Loads an external asset to replace the default one defined by defaultAsset. In 
		 * general, due to the way that IMVU products are packaged, it will be most reliable
		 * to use the correct absolute path here, which will be ClientWidget.path plus the 
		 * name of your asset (i.e. myWidget.path + "background.png").
		 * @param url The URL of the skin asset to load.
		 */
		public function load(url:String):void {
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			defaultAsset = getChildAt(0);
			defaultAsset.visible = false;
			addChild(loader);
			loader.load(new URLRequest(url));
		}
		
		private function completeHandler(event:Event):void {
			removeChild(defaultAsset);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			defaultAsset.visible = true;
		}

	}
}
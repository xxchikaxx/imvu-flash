package com.imvu.widget {
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	public class WidgetAsset extends MovieClip {

		private var loader:Loader;
		private var defaultAsset:DisplayObject;
		
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
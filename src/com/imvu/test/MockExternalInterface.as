package com.imvu.test
{
	import flash.net.LocalConnection;
	import com.interactiveAlchemy.utils.Debug;
	
	public class MockExternalInterface
	{
		public static var scope:Object = {};
		public static var callbacks:Object = {};
		
		public static function call(name:String, args:*):void {
			scope[name].call(scope, args);
		}
		
		public static function addCallback(fn:String, callback:Function):void {
			Debug.write("MockExternalInterface: Simulate added callback for " + fn);
			MockExternalInterface.callbacks[fn] = callback;
		}
	}
}
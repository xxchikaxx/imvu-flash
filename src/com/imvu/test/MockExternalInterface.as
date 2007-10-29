package com.imvu.test {

	import com.interactiveAlchemy.utils.Debug;
	
	public class MockExternalInterface {

		public var scope:Object = {};
		public var callbacks:Object = {};
		
		public function call(name:String, args:*):void {
			scope[name].call(scope, args);
		}
		
		public function addCallback(fn:String, callback:Function):void {
			Debug.write("MockExternalInterface: Simulate added callback for " + fn);
			this.callbacks[fn] = callback;
		}
	}
}
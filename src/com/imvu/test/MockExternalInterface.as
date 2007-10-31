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
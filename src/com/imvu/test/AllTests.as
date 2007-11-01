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
package com.imvu.test {
	import asunit.framework.TestSuite;
	
	public class AllTests extends TestSuite {
		
		public function AllTests() {
			super();
			addTest(new WidgetSpaceTest("testExternalInterfaceSetup"));
			addTest(new WidgetSpaceTest("testLoadAndUnloadWidget"));
			addTest(new WidgetSpaceTest("testSendEvent"));
			addTest(new WidgetSpaceTest("testReceiveEvent"));
			addTest(new WidgetSpaceTest("testParsePath"));
			
			addTest(new ClientWidgetTest("testSendEvent"));
			addTest(new ClientWidgetTest("testReceiveEvent"));
			
			addTest(new MultiUserTest("testMessages"));
			
		}
	}
}
package com.imvu.test {
	import asunit.framework.TestSuite;
	
	public class AllTests extends TestSuite {
		
		public function AllTests() {
			super();
			/*addTest(new WidgetSpaceTest("testExternalInterfaceSetup"));
			addTest(new WidgetSpaceTest("testLoadAndUnloadWidget"));
			addTest(new WidgetSpaceTest("testSendEvent"));
			addTest(new WidgetSpaceTest("testReceiveEvent"));
			addTest(new WidgetSpaceTest("testParsePath"));
			
			addTest(new ClientWidgetTest("testSendEvent"));
			addTest(new ClientWidgetTest("testReceiveEvent"));*/
			
			addTest(new MultiUserTest("testMessages"));
			
		}
	}
}
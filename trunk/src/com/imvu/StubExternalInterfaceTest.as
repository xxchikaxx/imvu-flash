package com.imvu {
 	public class StubExternalInterfaceTest extends ImvuTestCase {
        public function StubExternalInterfaceTest(config:Object):void {
            super(config);
        }
        
        public function testReset() : void {
        	var ei = new StubExternalInterface;
        	ei.respond('foo', 'bar');
        	ei.call('foo');
        	ei.reset();
            assertValueEquals(ei.getCalledMethods(), []);
            assertValueEquals(ei.getResponses(), {});
        }
    }
}


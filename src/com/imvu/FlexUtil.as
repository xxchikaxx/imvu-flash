package com.imvu {
    import com.adobe.serialization.json.JSON;
    import flash.events.*;
    import flash.external.ExternalInterface;
    import flash.net.*;
    import mx.core.Application;
    import mx.core.UIComponent;

    public class FlexUtil {
        public static function assert(cond:Boolean, msg:String=''):void {
            if (!cond) {
                mx.core.Application.application.outln(sprintf('Assertion failed: %s', msg));
                throw new AssertionFailure('Assertion failed: ' + msg);
            }
        }

        public static function isChild(parent:UIComponent, child:UIComponent):Boolean {
            for (var i:int = 0; i < parent.numChildren; i++) {
                if (parent.getChildAt(i) == child) {
                    return true;
                }
            }
            return false;
        }
    }
}

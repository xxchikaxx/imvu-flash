package com.imvu {
    public class EI {
        import flash.external.ExternalInterface;

        public static function addCallback(n:String, f:Function):void {
            if(ExternalInterface.available) {
                ExternalInterface.addCallback(n, f);
            }
        }

        public static function call(n:String, ... args):* {
            if(ExternalInterface.available) {
                args.unshift(n);
                return ExternalInterface.call.apply(null, args);
            }
        }
    }
}

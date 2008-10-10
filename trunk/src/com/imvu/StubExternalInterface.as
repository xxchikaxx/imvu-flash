package com.imvu {
    import com.adobe.serialization.json.JSON
    import asunit.errors.AssertionFailedError
    import flash.external.ExternalInterface

    public class StubExternalInterface {
        public var calls:Array = [];
        public var responses:Object = {};
        public var responseCallbacks:Object = {};

        public var callbacks:Array = [];

        public function call(...args):Object {
            calls.push(args.slice());

            var methodName:String = args.shift();
            if (methodName in responseCallbacks) {
                var cb = responseCallbacks[methodName];
                return cb[0].apply(cb[1], args);
            } else if (methodName in responses) {
                return responses[methodName];
            } else {
                return null;
            }
        }

        public function addCallback(name:String, cb:Function):void {
            Util.setDefault(callbacks, name, []).push(cb);
        }

        // Test API
        public function callCallback(name, ...args):void {
            for each (var cb:Function in Util.get(callbacks, name, [])) {
                cb.apply(null, args);
            }
        }

        public function respond(funcName:String, response):void {
            responses[funcName] = response;
        }

        public function setResponseCallback(funcName:String, callback:Function, self=null):void {
            responseCallbacks[funcName] = [callback, self];
        }

        public function getCalledMethods() {
            return calls.map(function (el, i, a) { return el[0] });
        }

        public function getResponses() {
            return responses;
        }
        
        public function reset() {
            calls = [];
            responses = {};
        }
    }
}

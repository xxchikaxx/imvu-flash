package com.imvu {
    import flash.external.ExternalInterface;
    import com.adobe.serialization.json.JSON;
    import com.imvu.Logger;

    public class EventBus {
        public static const ALL_EVENTNAMES:String = "ALL_EVENTNAMES";
        public static const ALL_SENDERS:String = "ALL_SENDERS";
        public static const AVATAR_WINDOW:String = "AvatarWindow";
        public static const PRESENCE_WINDOW:String = "PresenceWindow";

        private static var callbacks:Array = new Array();
    
        private static var hasSetupEI:Boolean = false;
        private static function setupEI():void {
            if(hasSetupEI) return;
            if(ExternalInterface.available) {
                hasSetupEI = true;
                ExternalInterface.addCallback('incomingEvent', incomingEvent);
            }
        }

        public static function register(eventName:String, cb, fromSender:String) {
            setupEI();
            var cbKey:String = callbacks.length.toString();
            callbacks[cbKey] = cb;
            if(ExternalInterface.available) {
                ExternalInterface.call("eventBusRegister", fromSender, eventName, cbKey);
            }
        }

        public static function fire(eventName:String, eventData:Object) {
            setupEI();
            if(ExternalInterface.available) {
                ExternalInterface.call("eventBusFire", eventName, JSON.encode(eventData));
            }
        }

        private static function incomingEvent(cbKey:String, eventName:String, infoStr:String) {
            var cb = callbacks[cbKey];
            if(!cb) return;
            var info = JSON.decode(infoStr);
            cb(eventName, info);
        }
    }
}


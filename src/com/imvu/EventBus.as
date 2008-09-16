package com.imvu {
    import com.imvu.EI;
    import com.adobe.serialization.json.JSON;
    import com.imvu.Logger;

    public class EventBus {
        public static const ALL_EVENTNAMES:String = "ALL_EVENTNAMES";
        public static const ALL_SENDERS:String = "ALL_SENDERS";
        public static const AVATAR_WINDOW:String = "AvatarWindow";
        public static const PRESENCE_WINDOW:String = "PresenceWindow";

        public static function register(eventName:String, cb, fromSender:String) {
            var cbKey:String = callbacks.length.toString();
            callbacks[cbKey] = cb;
            EI.call("eventBusRegister", fromSender, eventName, cbKey);
        }

        public static function fire(eventName:String, eventData:Object) {
            EI.call("eventBusFire", eventName, JSON.encode(eventData));
        }

        private static function incomingEvent(cbKey:String, eventName:String, infoStr:String) {
            var cb = callbacks[cbKey];
            if(!cb) return;
            var info = JSON.decode(infoStr);
            cb(eventName, info);
        }

        private static var callbacks:Array = new Array();
        /*static init */ {
            EI.addCallback('incomingEvent', incomingEvent);
        }
    }
}


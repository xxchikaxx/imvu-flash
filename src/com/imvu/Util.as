package com.imvu
{
    import com.adobe.serialization.json.JSON;
    import flash.events.*;
    import flash.external.ExternalInterface;
    import flash.net.*;

    public class Util {

        public static function min(a, b) {
            return a < b ? a : b;
        }

        public static function max(a, b) {
            return a > b ? a : b;
        }

        public static function objectsFromTable(table:Object):Array {
            var rslt:Array = [];
            for (var key:String in table) {
                var column:Array = table[key] as Array;
                for(var index:int = 0; index < column.length; index++) {
                    if(rslt.length <= index) {
                        rslt.push({});
                    }
                    rslt[index][key] = column[index];
                }
            }
            return rslt;
        }

        public static function arrayColumn(objs:Array, key:Object):Array {
            var result:Array = [];
            for each (var value:Object in objs) {
                result.push(value[key]);
            }
            return result;
        }

        public static function indexObjects(objs:Array, index:String):Object {
            var rslt:Object = {};
            if (index) {
                for each (var value:Object in objs) {
                    if (index in value) {
                        rslt[value[index]] = value;
                    }
                }
            } else {
                for each (var item:* in objs) {
                    rslt[item] = item;
                }
            }
            return rslt;
        }

        public static function login(avatarname:String, password:String, host:String, handler:Function):void {
            var data:URLVariables = new URLVariables();            data.avatarname=avatarname;
            data.password=password;

            var request:URLRequest = new URLRequest("http://" + host + "/catalog/login.php?action=process&sendto=/crossdomain.xml")
                request.method = URLRequestMethod.POST;
            request.contentType = 'application/x-www-form-urlencoded';
            request.data = data;

            var loader:URLLoader = new URLLoader();
            loader.addEventListener(Event.COMPLETE, handler);
            loader.load(request);
        }

        public static function isPrefix(a:Array, b:Array):Boolean {
            if (b.length < a.length) {
                return false;
            }
            for(var i:int = 0; i < a.length; i++) {
                if (a[i] != b[i]) {
                    return false;
                }
            }
            return true;
        }
        
        public static function removeDuplicates(array:Array):Array {
            var result:Array = [];
            var keys:Array = [];
            for (var i:int = 0; i < array.length; i++) {
                var value:* = array[i];
                if (!keys[value]) {
                    keys[value] = true;
                    result.push(value);
                }
            }
            return result;
        }

        public static function deepCompare(a:Object, b:Object):Boolean {
            if (a is Number || a is String || a is Boolean) {
                return a == b;
            } else if (a is Array) {
                if (!(b is Array) || a.length != b.length) {
                    return false;
                }
                for (var i in a) {
                    if (!deepCompare(a[i], b[i])) {
                        return false;
                    }
                }
                return true;
            } else {
                for (var aKey in a) {
                    if (!deepCompare(a[aKey], b[aKey])) {
                        return false;
                    }
                }
                for (var bKey in b) {
                    if (!(bKey in a)) {
                        return false;
                    }
                }
                return true;
            }
        }

        public static function keys(o:Object):Array {
            var result:Array = [];
            for (var k in o) {
                result.push(k);
            }
            return result;
        }

        public static function values(o:Object):Array {
            var result:Array = [];
            for each (var v in o) {
                result.push(v);
            }
            return result;
        }

        public static function setDefault(o:Object, key:Object, _default:Object):Object {
            if (!(key in o)) {
                o[key] = _default;
                return _default;
            } else {
                return o[key];
            }
        }

        public static function get(o:Object, key:Object, _default:Object=null):Object {
            if (key in o) {
                return o[key];
            } else {
                return _default;
            }
        }
        
        public static function navigateToNamedUrl(externalInterface:Object, name:String, params:Object):void {
            externalInterface.call("launchNamedUrlInBrowser", name, params);
        }
        
        public static function logFactForThingsToDoEvent(userId:int, eventName:String, urlLoaderFactory:Object):void {
            var url = "http://www.imvu.com/api/service/thingstodo.php?cid=" + userId.toString() + "&item=" + eventName

            var loader:Object = urlLoaderFactory.createLoader();
            loader.load(urlLoaderFactory.createRequest(url));
        }

        public static function range(a:int, b:int=-1):Array {
            var start:int;
            var end:int;

            if (b == -1) {
                start = 0;
                end = a;
            } else {
                start = a;
                end = b;
            }

            var len:int = end - start;

            var result:Array = new Array(end - start);
            for (var i:int = 0; i < end - start; i++) {
                result[i] = i + start;
            }
            return result;
        }

        public static function last(a:Array):Object {
            return a[a.length - 1];
        }

        public static function intersection(a:Array, b:Array):Array {
            if (a === null) {
                throw new Error("Util.intersection argument 1 must not be null!");
            } else if (b === null) {
                throw new Error("Util.intersection argument 2 must not be null!");
            }

            var result:Array = [];
            for each (var v in a) {
                if (b.indexOf(v) != -1) {
                    result.push(v);
                }
            }
            return result;
        }
    }
}
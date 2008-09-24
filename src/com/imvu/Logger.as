package com.imvu {
    import flash.external.ExternalInterface;
    import com.interactiveAlchemy.utils.Debug;

    public class Logger {
        import sprintf;

        public static const FATAL:int = 7;
        public static const ERROR:int = 6;
        public static const WARN:int = 5;
        public static const INFO:int = 4;
        public static const DEBUG:int = 3;
        public static const TRACE:int = 2;
 
        private static const levelLabels:Array = ['','','TRACE','DEBUG','INFO','WARN','ERROR','FATAL'];

        private static var level_:int = INFO;
        private static var writeFunc_:Function = defaultWriteFunc;

        public static function setLevel(level:int):void { level_ = level; }
        public static function setWriteFunc(writeFunc:Function): void { writeFunc_ = writeFunc; }

        private static function defaultWriteFunc(s:String):void {
            if(ExternalInterface.available) {
                ExternalInterface.call("log", s);
            }
        }

        private static function output(level:int, ...args):void {
            if(level >= level_) {
                var text:String = sprintf.apply(null, args);
                var msg:String = sprintf("%-6s%s", levelLabels[level], text);
                writeFunc_(msg);
                __imvutrace(msg);
                Debug.write(msg);
            }
        }

        public static function fatal(err:String, ...args):void { output.apply(null, [FATAL, err].concat(args)); }
        public static function error(err:String, ...args):void { output.apply(null, [ERROR, err].concat(args)); }
        public static function warn (err:String, ...args):void { output.apply(null, [ WARN, err].concat(args)); }
        public static function info (err:String, ...args):void { output.apply(null, [ INFO, err].concat(args)); }
        public static function debug(err:String, ...args):void { output.apply(null, [DEBUG, err].concat(args)); }
        public static function trace(err:String, ...args):void { output.apply(null, [TRACE, err].concat(args)); }
    }
}

function __imvutrace(...args) {
    trace.apply(null, args);
}

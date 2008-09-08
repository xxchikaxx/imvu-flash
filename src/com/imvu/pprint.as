package com.imvu {
    public function pprint(theObj:Object, indent:String=''):String {
        var output:String = String(theObj) + "\n";
        if (indent == '') {
            indent = '  ';
        } else {
            indent += '  ';
        }

        if (theObj == null) {
            output += 'null';

        } else if (theObj.constructor == Array || theObj.constructor == Object) {
            for (var p in theObj){
                if ('constructor' in theObj &&
                    (theObj[p].constructor == Array || theObj[p].constructor == Object)
                ) {
                    var type = (theObj[p].constructor == Array) ? "Array" : "Object";
                    output += indent + "[" + p + "](" + type + ")=>\n";
                    output += pprint(theObj[p], indent);
                } else {
                    output += indent + "[" + p + "] : " + theObj[p] + "\n";
                }
            }
        }

        return output;
    }
}
